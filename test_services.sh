#!/bin/bash

# Función para hacer peticiones HTTP
function test_endpoint() {
    echo "\nTesting $1"
    curl -X $2 $3 -H "Content-Type: application/json" $4
}

echo "\n=== Testing Productos Service ==="
test_endpoint "GET all products" "GET" "http://localhost:8081/api/v1/productos"
test_endpoint "POST new product" "POST" "http://localhost:8081/api/v1/productos" -d '{"nombre": "Prueba", "descripcion": "Producto de prueba", "precio_base": 99.99, "dimensiones": {"ancho": 5.0, "alto": 5.0, "profundo": 5.0}, "categoria": "pruebas", "estado": "disponible"}'

echo "\n=== Testing Materiales Service ==="
test_endpoint "GET all materials" "GET" "http://localhost:8082/api/v1/materiales"
test_endpoint "POST new material" "POST" "http://localhost:8082/api/v1/materiales" -d '{"nombre": "PLA Prueba", "tipo": "filamento", "fabricante": "Test", "disponible": true, "stock": 1000.0, "precio_por_unidad": 25.99, "caracteristicas": {"color": "rojo", "temperatura_impresion": 200, "temperatura_plataforma": 60, "resistencia_tensil": 70.0, "diametro_filamento": 1.75, "densidad": 1.25}}'

echo "\n=== Testing Filtros Service ==="
test_endpoint "POST search" "POST" "http://localhost:8083/api/v1/busqueda" -d '{"query": "prueba", "dimensiones": {"min_ancho": 1.0, "max_ancho": 10.0, "min_alto": 1.0, "max_alto": 10.0, "min_profundo": 1.0, "max_profundo": 10.0}, "precio_min": 0, "precio_max": 100, "tipo_material": "filamento"}'
