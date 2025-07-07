# Script de pruebas para servicios desplegados en AWS con Load Balancer

param(
    [string]$AlbDnsName = "",
    [string]$Environment = "dev"
)

# Configuración
if ([string]::IsNullOrEmpty($AlbDnsName)) {
    Write-Host "❌ Error: Debes proporcionar el DNS name del ALB" -ForegroundColor Red
    Write-Host "   Uso: .\test_aws_services.ps1 -AlbDnsName 'tu-alb-dns-name'" -ForegroundColor Yellow
    Write-Host "   Obtén el DNS name ejecutando: terraform output alb_dns_name" -ForegroundColor Cyan
    exit 1
}

$baseUrl = "http://$AlbDnsName"
$timeout = 30

Write-Host "🚀 Iniciando pruebas del sistema de catálogo 3D en AWS" -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta
Write-Host "🌐 Load Balancer: $baseUrl" -ForegroundColor Cyan
Write-Host "🏷️  Environment: $Environment" -ForegroundColor Cyan

# Función para hacer requests HTTP con timeout
function Test-Endpoint {
    param (
        [string]$Method,
        [string]$Url,
        [string]$Body = $null,
        [string]$Description = ""
    )

    $headers = @{
        "Content-Type" = "application/json"
    }

    Write-Host "`n🔍 Probando: $Description" -ForegroundColor Cyan
    Write-Host "   URL: $Url" -ForegroundColor Gray
    Write-Host "   Método: $Method" -ForegroundColor Gray

    try {
        $params = @{
            Method = $Method
            Uri = $Url
            Headers = $headers
            TimeoutSec = $timeout
        }

        if ($Body) {
            $params.Body = $Body
        }

        $response = Invoke-RestMethod @params
        Write-Host "   ✅ Éxito: $($response | ConvertTo-Json -Depth 3)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Función para verificar health check
function Test-HealthCheck {
    param (
        [string]$ServiceName,
        [string]$Url
    )

    Write-Host "`n🏥 Verificando health check de $ServiceName..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-RestMethod -Uri $Url -TimeoutSec 10
        Write-Host "   ✅ $ServiceName está funcionando correctamente" -ForegroundColor Green
        Write-Host "   📊 Status: $($response.status)" -ForegroundColor Gray
        Write-Host "   🔧 Service: $($response.service)" -ForegroundColor Gray
        Write-Host "   📦 Version: $($response.version)" -ForegroundColor Gray
        return $true
    } catch {
        Write-Host "   ❌ $ServiceName no está respondiendo" -ForegroundColor Red
        return $false
    }
}

# Función para verificar Swagger
function Test-Swagger {
    param (
        [string]$ServiceName,
        [string]$Url
    )

    Write-Host "`n📚 Verificando Swagger de $ServiceName..." -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "   ✅ Swagger de $ServiceName está disponible" -ForegroundColor Green
            return $true
        } else {
            Write-Host "   ❌ Swagger de $ServiceName no está disponible" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "   ❌ Error al acceder a Swagger de $ServiceName" -ForegroundColor Red
        return $false
    }
}

# Función para probar load balancer routing
function Test-LoadBalancerRouting {
    Write-Host "`n🔄 Probando routing del Load Balancer..." -ForegroundColor Blue
    
    $routes = @(
        @{Path="/api/v1/productos"; Description="Routing a Productos"},
        @{Path="/api/v1/materiales"; Description="Routing a Materiales"},
        @{Path="/api/v1/buscar"; Description="Routing a Filtros"},
        @{Path="/swagger/index.html"; Description="Routing a Swagger"}
    )
    
    foreach ($route in $routes) {
        $url = "$baseUrl$($route.Path)"
        Test-Endpoint -Method "GET" -Url $url -Description $route.Description
    }
}

# 1. Verificar que el ALB esté respondiendo
Write-Host "`n📋 PASO 1: Verificación del Application Load Balancer" -ForegroundColor Blue

try {
    $response = Invoke-WebRequest -Uri $baseUrl -TimeoutSec 10
    Write-Host "   ✅ ALB está respondiendo (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "   ❌ ALB no está respondiendo" -ForegroundColor Red
    Write-Host "   🔧 Verifica que el ALB esté desplegado y las instancias estén saludables" -ForegroundColor Yellow
    exit 1
}

# 2. Verificar health checks de todos los servicios
Write-Host "`n📋 PASO 2: Verificación de Health Checks" -ForegroundColor Blue

$healthEndpoints = @(
    @{Name="Productos"; Url="$baseUrl/health"},
    @{Name="Materiales"; Url="$baseUrl/health"},
    @{Name="Filtros"; Url="$baseUrl/health"}
)

$allHealthy = $true
foreach ($endpoint in $healthEndpoints) {
    if (-not (Test-HealthCheck -ServiceName $endpoint.Name -Url $endpoint.Url)) {
        $allHealthy = $false
    }
}

if (-not $allHealthy) {
    Write-Host "`n⚠️  Algunos servicios no están saludables" -ForegroundColor Yellow
    Write-Host "   🔧 Verifica los logs de las instancias EC2" -ForegroundColor Cyan
    Write-Host "   🔧 Verifica los target groups en la consola de AWS" -ForegroundColor Cyan
}

# 3. Verificar Swagger
Write-Host "`n📋 PASO 3: Verificación de documentación Swagger" -ForegroundColor Blue

$swaggerUrls = @(
    @{Name="Productos"; Url="$baseUrl/swagger/index.html"},
    @{Name="Materiales"; Url="$baseUrl/swagger/index.html"}
)

foreach ($swagger in $swaggerUrls) {
    Test-Swagger -ServiceName $swagger.Name -Url $swagger.Url
}

# 4. Probar routing del Load Balancer
Test-LoadBalancerRouting

# 5. Pruebas de API - Productos
Write-Host "`n📋 PASO 4: Pruebas de API - Catálogo de Productos" -ForegroundColor Blue

# GET todos los productos
Test-Endpoint -Method "GET" -Url "$baseUrl/api/v1/productos" -Description "Obtener todos los productos"

# GET producto específico
Test-Endpoint -Method "GET" -Url "$baseUrl/api/v1/productos/p001" -Description "Obtener producto específico"

# POST crear nuevo producto
$newProduct = @{
    nombre = "Producto AWS Test"
    descripcion = "Producto de prueba en AWS"
    precio_base = 39.99
    dimensiones = @{
        ancho = 20.0
        alto = 15.0
        profundo = 8.0
    }
    categoria = "AWS-Test"
    estado = "disponible"
} | ConvertTo-Json

Test-Endpoint -Method "POST" -Url "$baseUrl/api/v1/productos" -Body $newProduct -Description "Crear nuevo producto en AWS"

# 6. Pruebas de API - Materiales
Write-Host "`n📋 PASO 5: Pruebas de API - Catálogo de Materiales" -ForegroundColor Blue

# GET todos los materiales
Test-Endpoint -Method "GET" -Url "$baseUrl/api/v1/materiales" -Description "Obtener todos los materiales"

# GET materiales por tipo
Test-Endpoint -Method "GET" -Url "$baseUrl/api/v1/materiales/tipo/filamento" -Description "Obtener materiales por tipo (filamento)"

# POST crear nuevo material
$newMaterial = @{
    nombre = "PLA AWS Test"
    tipo = "filamento"
    fabricante = "AWS Test Manufacturer"
    disponible = $true
    stock = 750.0
    precio_por_unidad = 35.99
    caracteristicas = @{
        color = "Azul"
        temperatura_impresion = 215
        temperatura_plataforma = 70
        resistencia_tensil = 68.0
        diametro_filamento = 1.75
        densidad = 1.26
    }
} | ConvertTo-Json

Test-Endpoint -Method "POST" -Url "$baseUrl/api/v1/materiales" -Body $newMaterial -Description "Crear nuevo material en AWS"

# 7. Pruebas de API - Filtros
Write-Host "`n📋 PASO 6: Pruebas de API - Filtros y Búsqueda" -ForegroundColor Blue

# GET endpoint básico
Test-Endpoint -Method "GET" -Url "$baseUrl/api/v1/buscar" -Description "Endpoint básico de búsqueda"

# POST búsqueda con filtros
$searchFilters = @{
    categoria = "aws_test"
    precio_max = 1500
    dimensiones = @{
        min_ancho = 10.0
        max_ancho = 25.0
        min_alto = 5.0
        max_alto = 20.0
        min_profundo = 3.0
        max_profundo = 12.0
    }
} | ConvertTo-Json

Test-Endpoint -Method "POST" -Url "$baseUrl/api/v1/buscar" -Body $searchFilters -Description "Búsqueda con filtros en AWS"

# 8. Pruebas de rendimiento y latencia
Write-Host "`n📋 PASO 7: Pruebas de rendimiento y latencia" -ForegroundColor Blue

$endpoints = @(
    "$baseUrl/api/v1/productos",
    "$baseUrl/api/v1/materiales",
    "$baseUrl/api/v1/buscar"
)

foreach ($endpoint in $endpoints) {
    Write-Host "`n⏱️  Probando rendimiento de: $endpoint" -ForegroundColor Cyan
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $success = Test-Endpoint -Method "GET" -Url $endpoint -Description "Prueba de rendimiento AWS"
    $stopwatch.Stop()
    
    if ($success) {
        Write-Host "   ⏱️  Tiempo de respuesta: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Green
        
        # Evaluar latencia
        if ($stopwatch.ElapsedMilliseconds -lt 500) {
            Write-Host "   🟢 Latencia excelente (< 500ms)" -ForegroundColor Green
        } elseif ($stopwatch.ElapsedMilliseconds -lt 1000) {
            Write-Host "   🟡 Latencia buena (< 1s)" -ForegroundColor Yellow
        } else {
            Write-Host "   🔴 Latencia alta (> 1s)" -ForegroundColor Red
        }
    }
}

# 9. Resumen final
Write-Host "`n📋 PASO 8: Resumen de pruebas AWS" -ForegroundColor Blue
Write-Host "==================================================" -ForegroundColor Magenta

Write-Host "✅ Pruebas completadas en AWS" -ForegroundColor Green
Write-Host "🌐 Load Balancer DNS: $AlbDnsName" -ForegroundColor Cyan
Write-Host "📊 URLs de acceso:" -ForegroundColor Cyan
Write-Host "   - Productos: $baseUrl/api/v1/productos" -ForegroundColor White
Write-Host "   - Materiales: $baseUrl/api/v1/materiales" -ForegroundColor White
Write-Host "   - Filtros: $baseUrl/api/v1/buscar" -ForegroundColor White
Write-Host "   - Swagger: $baseUrl/swagger/index.html" -ForegroundColor White

Write-Host "`n🔧 Comandos útiles para AWS:" -ForegroundColor Yellow
Write-Host "   - Ver logs de EC2: aws logs describe-log-groups" -ForegroundColor White
Write-Host "   - Verificar ALB: aws elbv2 describe-load-balancers" -ForegroundColor White
Write-Host "   - Ver target groups: aws elbv2 describe-target-groups" -ForegroundColor White
Write-Host "   - Verificar health: aws elbv2 describe-target-health" -ForegroundColor White

Write-Host "`n🎉 ¡Pruebas en AWS completadas exitosamente!" -ForegroundColor Green 