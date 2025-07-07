# Servicio de Configuraciones de Impresión

Este servicio maneja las configuraciones de impresión 3D para diferentes materiales en el sistema de catálogo.

## Características

- Gestión de perfiles de impresión
- Configuraciones recomendadas por material
- Parámetros de impresión personalizables
- Integración con base de datos PostgreSQL

## Variables de Entorno

```bash
# Configuración de la base de datos
POSTGRES_ENDPOINT=localhost
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres123
POSTGRES_DB=configuraciones
```

## Endpoints

### GET /api/v1/perfiles-impresion
Obtiene todos los perfiles de impresión.

### GET /api/v1/perfiles-impresion/:id
Obtiene un perfil de impresión por ID.

### GET /api/v1/perfiles-impresion/material/:materialId
Obtiene los perfiles de impresión para un material específico.

### GET /api/v1/perfiles-impresion/recomendados
Obtiene los perfiles de impresión recomendados.

### POST /api/v1/perfiles-impresion
Crea un nuevo perfil de impresión.

**Body:**
```json
{
  "material_id": 1,
  "nombre": "PLA Estándar",
  "descripcion": "Configuración estándar para PLA",
  "temperatura_nozzle": 200,
  "temperatura_cama": 60,
  "velocidad_impresion": 60,
  "altura_capa": 0.2,
  "relleno": 20,
  "velocidad_retraccion": 25,
  "distancia_retraccion": 6.5,
  "velocidad_ventilador": 100,
  "es_recomendado": true
}
```

### PUT /api/v1/perfiles-impresion/:id
Actualiza un perfil de impresión existente.

### DELETE /api/v1/perfiles-impresion/:id
Elimina un perfil de impresión.

## Desarrollo

### Requisitos

- Go 1.21 o superior
- PostgreSQL

### Ejecutar localmente

1. Configura las variables de entorno
2. Ejecuta las migraciones:
   ```bash
   go run main.go
   ```

### Construir con Docker

```bash
docker build -t catalogo-configuraciones .
docker run -p 8083:8083 catalogo-configuraciones
```

## Estructura del Modelo

### PerfilImpresion

| Campo                 | Tipo    | Descripción                             |
|-----------------------|---------|-----------------------------------------|
| ID                    | uint    | Identificador único                     |
| MaterialID            | uint    | ID del material relacionado             |
| Nombre                | string  | Nombre del perfil                       |
| Descripcion           | string  | Descripción detallada                   |
| TemperaturaNozzle     | int     | Temperatura del nozzle en °C            |
| TemperaturaCama       | int     | Temperatura de la cama en °C            |
| VelocidadImpresion    | int     | Velocidad de impresión en mm/s          |
| AlturaCapa            | float64 | Altura de capa en mm                    |
| Relleno               | int     | Porcentaje de relleno                   |
| VelocidadRetraccion   | int     | Velocidad de retracción en mm/s         |
| DistanciaRetraccion   | float64 | Distancia de retracción en mm           |
| VelocidadVentilador   | int     | Velocidad del ventilador en %           |
| EsRecomendado         | bool    | Si es una configuración recomendada     |
| CreatedAt             | time.Time | Fecha de creación                      |
| UpdatedAt             | time.Time | Fecha de última actualización          |
| DeletedAt             | gorm.DeletedAt | Fecha de eliminación (soft delete)  |
