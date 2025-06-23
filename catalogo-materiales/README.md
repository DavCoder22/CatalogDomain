# Catálogo de Materiales

## Descripción

Microservicio encargado de la gestión de materiales para impresión 3D en el dominio de catálogo. Permite gestionar diferentes tipos de materiales como filamentos y resinas, con sus respectivas características técnicas.

## Lenguaje

- **Lenguaje**: Go (Golang)
- **Framework**: Gin

## Características

- Gestión de materiales de impresión 3D
- Soporte para diferentes tipos de materiales (filamentos, resinas)
- Control de inventario y disponibilidad
- Características técnicas detalladas por material
- API RESTful

## Estructura del Proyecto

- `main.go`: Punto de entrada de la aplicación
- `Dockerfile`: Configuración para contenerizar el servicio

## Uso

1. Configurar las variables de entorno necesarias
2. Ejecutar `go run main.go`
3. El servicio estará disponible en el puerto configurado (por defecto 8081)

## Endpoints

- `GET /materiales`: Obtener todos los materiales
- `GET /materiales/:id`: Obtener un material por ID
- `POST /materiales`: Crear un nuevo material
- `PUT /materiales/:id`: Actualizar un material existente
- `DELETE /materiales/:id`: Eliminar un material
- `PATCH /materiales/:id/stock`: Actualizar el stock de un material
