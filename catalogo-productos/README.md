# Catálogo de Productos

## Descripción

Microservicio encargado de la gestión de productos 3D en el dominio de catálogo. Permite realizar operaciones CRUD sobre los productos, incluyendo sus dimensiones, precios y categorías.

## Lenguaje

- **Lenguaje**: Go (Golang)
- **Framework**: Gin
- **Base de datos**: PostgreSQL

## Características

- Gestión completa de productos 3D
- Búsqueda y filtrado de productos
- Documentación con Swagger
- Integración con base de datos PostgreSQL

## Estructura del Proyecto

- `main.go`: Punto de entrada de la aplicación
- `Dockerfile`: Configuración para contenerizar el servicio
- `docs/`: Documentación de la API (Swagger)

## Variables de Entorno

- `POSTGRES_ENDPOINT`: Cadena de conexión a PostgreSQL
- `PORT`: Puerto en el que se ejecutará el servicio (opcional, por defecto 8080)

## Uso

1. Configurar las variables de entorno
2. Ejecutar `go run main.go`
3. Acceder a la documentación en `/swagger/index.html`
