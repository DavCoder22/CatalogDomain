# Script de prueba para los microservicios

# Función para hacer requests HTTP
function Test-Endpoint {
    param (
        [string]$Method,
        [string]$Url,
        [string]$Body = $null
    )

    $headers = @{
        "Content-Type" = "application/json"
    }

    try {
        if ($Method -eq "GET") {
            $response = Invoke-RestMethod -Method $Method -Uri $Url -Headers $headers
        } else {
            $response = Invoke-RestMethod -Method $Method -Uri $Url -Headers $headers -Body $Body
        }
        Write-Host "Response: $($response | ConvertTo-Json)"
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}

# Pruebas para catalogo-productos
Write-Host "Testing catalogo-productos..."
Test-Endpoint -Method "GET" -Url "http://localhost:8081/api/v1/productos"

# Pruebas para catalogo-materiales
Write-Host "Testing catalogo-materiales..."
Test-Endpoint -Method "GET" -Url "http://localhost:8082/api/v1/materiales"

# Pruebas para catalogo-filtros
Write-Host "Testing catalogo-filtros..."
Test-Endpoint -Method "GET" -Url "http://localhost:8084/api/v1/buscar"

Write-Host "Testing POST search..."
$body = @{
    "categoria" = "impresion_3d"
    "precio_max" = 1000
} | ConvertTo-Json
Test-Endpoint -Method "POST" -Url "http://localhost:8084/api/v1/buscar" -Body $body
