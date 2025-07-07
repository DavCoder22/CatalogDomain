# Script de pruebas completo para los microservicios del catálogo 3D

# Configuración
$baseUrl = "http://localhost"
$timeout = 30

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

# Inicio de pruebas
Write-Host "🚀 Iniciando pruebas completas del sistema de catálogo 3D" -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta

# 1. Verificar que los servicios estén ejecutándose
Write-Host "`n📋 PASO 1: Verificación de servicios" -ForegroundColor Blue

$services = @(
    @{Name="Productos"; Port="8081"},
    @{Name="Materiales"; Port="8082"},
    @{Name="Filtros"; Port="8083"}
)

$allServicesRunning = $true
foreach ($service in $services) {
    $healthUrl = "$baseUrl`:$($service.Port)/api/v1/health"
    if (-not (Test-HealthCheck -ServiceName $service.Name -Url $healthUrl)) {
        $allServicesRunning = $false
    }
}

if (-not $allServicesRunning) {
    Write-Host "`n⚠️  Algunos servicios no están ejecutándose. Iniciando con Docker Compose..." -ForegroundColor Yellow
    Write-Host "   Ejecuta: docker-compose up -d" -ForegroundColor Cyan
    exit 1
}

# 2. Verificar Swagger
Write-Host "`n📋 PASO 2: Verificación de documentación Swagger" -ForegroundColor Blue

$swaggerUrls = @(
    @{Name="Productos"; Url="$baseUrl`:8081/swagger/index.html"},
    @{Name="Materiales"; Url="$baseUrl`:8082/swagger/index.html"}
)

foreach ($swagger in $swaggerUrls) {
    Test-Swagger -ServiceName $swagger.Name -Url $swagger.Url
}

# 3. Pruebas de API - Productos
Write-Host "`n📋 PASO 3: Pruebas de API - Catálogo de Productos" -ForegroundColor Blue

# GET todos los productos
Test-Endpoint -Method "GET" -Url "$baseUrl`:8081/api/v1/productos" -Description "Obtener todos los productos"

# GET producto específico
Test-Endpoint -Method "GET" -Url "$baseUrl`:8081/api/v1/productos/p001" -Description "Obtener producto específico"

# POST crear nuevo producto
$newProduct = @{
    nombre = "Nuevo Producto Test"
    descripcion = "Producto de prueba para testing"
    precio_base = 29.99
    dimensiones = @{
        ancho = 15.0
        alto = 10.0
        profundo = 5.0
    }
    categoria = "Test"
    estado = "disponible"
} | ConvertTo-Json

Test-Endpoint -Method "POST" -Url "$baseUrl`:8081/api/v1/productos" -Body $newProduct -Description "Crear nuevo producto"

# 4. Pruebas de API - Materiales
Write-Host "`n📋 PASO 4: Pruebas de API - Catálogo de Materiales" -ForegroundColor Blue

# GET todos los materiales
Test-Endpoint -Method "GET" -Url "$baseUrl`:8082/api/v1/materiales" -Description "Obtener todos los materiales"

# GET materiales por tipo
Test-Endpoint -Method "GET" -Url "$baseUrl`:8082/api/v1/materiales/tipo/filamento" -Description "Obtener materiales por tipo (filamento)"

# POST crear nuevo material
$newMaterial = @{
    nombre = "PLA Test"
    tipo = "filamento"
    fabricante = "Test Manufacturer"
    disponible = $true
    stock = 500.0
    precio_por_unidad = 30.99
    caracteristicas = @{
        color = "Verde"
        temperatura_impresion = 210
        temperatura_plataforma = 65
        resistencia_tensil = 65.0
        diametro_filamento = 1.75
        densidad = 1.24
    }
} | ConvertTo-Json

Test-Endpoint -Method "POST" -Url "$baseUrl`:8082/api/v1/materiales" -Body $newMaterial -Description "Crear nuevo material"

# 5. Pruebas de API - Filtros
Write-Host "`n📋 PASO 5: Pruebas de API - Filtros y Búsqueda" -ForegroundColor Blue

# GET endpoint básico
Test-Endpoint -Method "GET" -Url "$baseUrl`:8083/api/v1/buscar" -Description "Endpoint básico de búsqueda"

# POST búsqueda con filtros
$searchFilters = @{
    categoria = "impresion_3d"
    precio_max = 1000
    dimensiones = @{
        min_ancho = 5.0
        max_ancho = 20.0
        min_alto = 3.0
        max_alto = 15.0
        min_profundo = 2.0
        max_profundo = 10.0
    }
} | ConvertTo-Json

Test-Endpoint -Method "POST" -Url "$baseUrl`:8083/api/v1/buscar" -Body $searchFilters -Description "Búsqueda con filtros"

# 6. Pruebas de rendimiento básicas
Write-Host "`n📋 PASO 6: Pruebas de rendimiento básicas" -ForegroundColor Blue

$endpoints = @(
    "$baseUrl`:8081/api/v1/productos",
    "$baseUrl`:8082/api/v1/materiales",
    "$baseUrl`:8083/api/v1/buscar"
)

foreach ($endpoint in $endpoints) {
    Write-Host "`n⏱️  Probando rendimiento de: $endpoint" -ForegroundColor Cyan
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $success = Test-Endpoint -Method "GET" -Url $endpoint -Description "Prueba de rendimiento"
    $stopwatch.Stop()
    
    if ($success) {
        Write-Host "   ⏱️  Tiempo de respuesta: $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Green
    }
}

# 7. Resumen final
Write-Host "`n📋 PASO 7: Resumen de pruebas" -ForegroundColor Blue
Write-Host "==================================================" -ForegroundColor Magenta

Write-Host "✅ Pruebas completadas" -ForegroundColor Green
Write-Host "📊 Para ver la documentación completa:" -ForegroundColor Cyan
Write-Host "   - Productos: $baseUrl`:8081/swagger/index.html" -ForegroundColor White
Write-Host "   - Materiales: $baseUrl`:8082/swagger/index.html" -ForegroundColor White

Write-Host "`n🔧 Comandos útiles:" -ForegroundColor Yellow
Write-Host "   - Reiniciar servicios: docker-compose restart" -ForegroundColor White
Write-Host "   - Ver logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   - Detener servicios: docker-compose down" -ForegroundColor White

Write-Host "`n🎉 ¡Pruebas completadas exitosamente!" -ForegroundColor Green 