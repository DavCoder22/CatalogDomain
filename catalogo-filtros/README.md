# Catálogo de Filtros

## Descripción

Microservicio encargado de la gestión de búsquedas y filtros en el dominio de catálogo. Permite realizar búsquedas avanzadas en el catálogo de productos 3D con diferentes criterios de filtrado.

## Lenguaje

- **Lenguaje**: Go (Golang)
- **Framework**: Gin

## Características

- Búsqueda de productos por múltiples criterios
- Filtrado por dimensiones (ancho, alto, profundidad)
- Filtrado por categorías
- Historial de búsquedas

## Estructura del Proyecto

- `main.go`: Punto de entrada de la aplicación
- `Dockerfile`: Configuración para contenerizar el servicio

## Uso

1. Ejecutar `go run main.go`
2. El servicio estará disponible en el puerto configurado (por defecto 8082)

## Endpoints

- `POST /buscar`: Realizar una nueva búsqueda
- `GET /busquedas/:id`: Obtener los resultados de una búsqueda específica
- `POST /filtros`: Aplicar filtros adicionales a una búsqueda existente
