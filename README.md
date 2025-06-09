# Cotizador 3D - Microservicios

Este proyecto contiene los microservicios para el sistema de cotización de impresión 3D.

## Microservicios

1. **catalogo-productos**: Manejo de productos para cotización
2. **catalogo-materiales**: Gestión de materiales disponibles
3. **catalogo-filtros**: Búsqueda y filtrado de productos y materiales

## Requisitos

- Go 1.21 o superior
- Docker (opcional para despliegue)

## Instalación

1. Clonar el repositorio
2. Ejecutar `go mod download` para instalar dependencias
3. Configurar las variables de entorno en `.env`

## Uso

Cada microservicio se ejecuta de forma independiente:

```bash
go run catalogo-productos/main.go
```

## Estructura del Proyecto

```
cotizador3d/
├── catalogo-productos/
├── catalogo-materiales/
└── catalogo-filtros/
```
