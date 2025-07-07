# 🚀 Sistema de Catálogo 3D - Microservicios Distribuidos

## 📋 Descripción del Dominio

Sistema distribuido para la gestión integral de productos y materiales de impresión 3D, compuesto por microservicios independientes que trabajan en conjunto para proporcionar un catálogo completo y funcional. El sistema permite gestionar productos 3D, materiales de impresión (filamentos y resinas), y realizar búsquedas avanzadas con filtros personalizados.

## 🏗️ Arquitectura del Sistema

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   catalogo-     │    │   catalogo-     │    │   catalogo-     │
│   productos     │    │   materiales    │    │   filtros       │
│   (Puerto 8081) │    │   (Puerto 8082) │    │   (Puerto 8083) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Load Balancer │
                    │   (AWS ALB)     │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Cliente Web   │
                    │   / API Client  │
                    └─────────────────┘
```

### 🔧 Tecnologías Utilizadas

- **Backend**: Go (Gin Framework)
- **Documentación**: Swagger/OpenAPI 3.0
- **Contenedores**: Docker & Docker Compose
- **Infraestructura**: AWS (EC2, ALB, EIP)
- **Orquestación**: Terraform
- **Red**: Subnet personalizada (172.20.0.0/16)

## 📦 Microservicios

### 1. 🎯 **catalogo-productos** (Puerto 8081)

**Descripción**: Gestiona el catálogo de productos 3D, incluyendo información detallada de dimensiones, precios y categorías.

**Funcionalidades**:
- CRUD completo de productos 3D
- Gestión de dimensiones (ancho, alto, profundo)
- Categorización por tipo de producto
- Control de estado (disponible, agotado, etc.)

**Endpoints Principales**:
```bash
GET    /api/v1/productos          # Listar todos los productos
GET    /api/v1/productos/:id      # Obtener producto específico
POST   /api/v1/productos          # Crear nuevo producto
PUT    /api/v1/productos/:id      # Actualizar producto
DELETE /api/v1/productos/:id      # Eliminar producto
GET    /health                    # Health check
GET    /swagger/index.html        # Documentación Swagger
```

**Ejemplo de Producto**:
```json
{
  "id": "p001",
  "nombre": "Pieza de Soporte",
  "descripcion": "Soporte para impresión 3D",
  "precio_base": 15.99,
  "dimensiones": {
    "ancho": 10.0,
    "alto": 5.0,
    "profundo": 3.0
  },
  "categoria": "Soportes",
  "estado": "disponible"
}
```

**Documentación Swagger**: http://localhost:8081/swagger/index.html

---

### 2. 🧪 **catalogo-materiales** (Puerto 8082)

**Descripción**: Administra materiales de impresión 3D, incluyendo filamentos y resinas con características técnicas detalladas.

**Funcionalidades**:
- Gestión de filamentos (PLA, ABS, PETG, etc.)
- Gestión de resinas (UV, estándar, etc.)
- Control de stock y disponibilidad
- Características técnicas específicas por tipo

**Tipos de Materiales**:
- **Filamentos**: PLA, ABS, PETG, TPU
- **Resinas**: UV, estándar, flexibles

**Endpoints Principales**:
```bash
GET    /api/v1/materiales                    # Listar todos los materiales
GET    /api/v1/materiales/:id                # Obtener material específico
GET    /api/v1/materiales/tipo/:tipo         # Filtrar por tipo (filamento/resina)
POST   /api/v1/materiales                    # Crear nuevo material
PUT    /api/v1/materiales/:id                # Actualizar material
DELETE /api/v1/materiales/:id                # Eliminar material
PUT    /api/v1/materiales/:id/stock          # Actualizar stock
GET    /health                               # Health check
GET    /swagger/index.html                   # Documentación Swagger
```

**Ejemplo de Material (Filamento)**:
```json
{
  "id": "m001",
  "nombre": "PLA Premium",
  "tipo": "filamento",
  "fabricante": "XYZ Filaments",
  "disponible": true,
  "stock": 1000.0,
  "precio_por_unidad": 25.99,
  "caracteristicas": {
    "color": "Natural",
    "temperatura_impresion": 200,
    "temperatura_plataforma": 60,
    "resistencia_tensil": 70.0,
    "diametro_filamento": 1.75,
    "densidad": 1.25
  }
}
```

**Ejemplo de Material (Resina)**:
```json
{
  "id": "m002",
  "nombre": "Resina Standard",
  "tipo": "resina",
  "fabricante": "UV Resins",
  "disponible": true,
  "stock": 5000.0,
  "precio_por_unidad": 45.99,
  "caracteristicas": {
    "color": "Transparente",
    "temperatura_impresion": 25,
    "temperatura_plataforma": 25,
    "resistencia_tensil": 75.0,
    "dureza": 70,
    "viscosidad": 1000,
    "tiempo_cura": 6,
    "tolerancia": 0.05
  }
}
```

**Documentación Swagger**: http://localhost:8082/swagger/index.html

---

### 3. 🔍 **catalogo-filtros** (Puerto 8083)

**Descripción**: Proporciona funcionalidades avanzadas de búsqueda y filtrado para productos y materiales.

**Funcionalidades**:
- Búsqueda por categoría
- Filtrado por rango de precios
- Filtrado por dimensiones
- Filtrado por tipo de material
- Búsqueda combinada

**Endpoints Principales**:
```bash
GET    /api/v1/buscar                        # Endpoint básico de búsqueda
GET    /api/v1/buscar/:id                    # Obtener búsqueda específica
POST   /api/v1/buscar                        # Aplicar filtros avanzados
GET    /health                               # Health check
```

**Ejemplo de Filtros**:
```json
{
  "categoria": "impresion_3d",
  "precio_max": 1000,
  "dimensiones": {
    "min_ancho": 5.0,
    "max_ancho": 20.0,
    "min_alto": 3.0,
    "max_alto": 15.0,
    "min_profundo": 2.0,
    "max_profundo": 10.0
  },
  "tipo_material": "filamento"
}
```

---

## 🚀 Despliegue y Configuración

### Requisitos Previos

- Docker Desktop
- Docker Compose
- Go 1.23+ (para desarrollo local)
- AWS CLI (para despliegue en la nube)

### Despliegue Local

```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd CatalogDM-Proyect

# 2. Levantar servicios con Docker Compose
docker-compose up -d

# 3. Verificar que los servicios estén funcionando
docker-compose ps

# 4. Ejecutar pruebas locales
.\test_services_comprehensive.ps1
```

### Despliegue en AWS

```bash
# 1. Configurar AWS CLI
aws configure

# 2. Desplegar con Terraform
cd terraform/catalogo
terraform init
terraform plan
terraform apply

# 3. Obtener DNS del Load Balancer
terraform output alb_dns_name

# 4. Ejecutar pruebas en AWS
.\test_aws_services.ps1 -AlbDnsName "tu-alb-dns-name.amazonaws.com"
```

## 🧪 Pruebas y Validación

### Scripts de Pruebas Disponibles

1. **test_services_comprehensive.ps1** - Pruebas locales completas
2. **test_aws_services.ps1** - Pruebas en AWS con Load Balancer
3. **test_services.ps1** - Pruebas básicas

### Health Checks

Todos los microservicios exponen endpoints de health check:

```bash
curl http://localhost:8081/health  # Productos
curl http://localhost:8082/health  # Materiales  
curl http://localhost:8083/health  # Filtros
```

Respuesta esperada:
```json
{
  "status": "healthy",
  "service": "nombre-del-servicio",
  "version": "1.0.0"
}
```

## 📚 Documentación Adicional

- **[Guía Completa de Pruebas y Deployment](./GUIA_PRUEBAS_Y_DEPLOYMENT.md)** - Instrucciones detalladas
- **[Documentación Swagger Productos](http://localhost:8081/swagger/index.html)** - API de productos
- **[Documentación Swagger Materiales](http://localhost:8082/swagger/index.html)** - API de materiales

## 🔧 Configuración de Red

### IPs Estáticas (Docker Compose)
- **Productos**: 172.20.0.10
- **Materiales**: 172.20.0.11
- **Filtros**: 172.20.0.12

### IPs Estáticas (AWS)
- **Productos**: EIP asignado automáticamente
- **Materiales**: EIP asignado automáticamente

## 🛡️ Seguridad y Monitoreo

### Security Groups (AWS)
- **ALB**: Puertos 80, 443 (HTTP/HTTPS)
- **EC2**: Puertos 8081, 8082, 8083 (microservicios)

### Monitoreo
- Health checks automáticos cada 30 segundos
- Logs centralizados en CloudWatch
- Métricas de latencia y disponibilidad

## 🔄 Flujo de Trabajo y Git

### Estructura de Ramas
- **develop**: Desarrollo activo
- **test**: QA y validación
- **main**: Producción (solo PRs aprobados)

### GitHub Actions
- **deploy-develop.yml**: Despliegue automático a desarrollo
- **deploy-test.yml**: Despliegue a ambiente de pruebas
- **deploy-prod.yml**: Despliegue a producción (aprobación manual)

## 🎯 Próximos Pasos

- [ ] Implementar **catalogo-auth** con JWT
- [ ] Agregar base de datos PostgreSQL
- [ ] Implementar cache Redis
- [ ] Configurar SSL/TLS con ACM
- [ ] Implementar auto-scaling groups
- [ ] Agregar métricas con CloudWatch

## 📞 Soporte

Para problemas o preguntas:
1. Revisar logs: `docker-compose logs -f`
2. Verificar health checks
3. Consultar documentación Swagger
4. Revisar [Guía de Pruebas](./GUIA_PRUEBAS_Y_DEPLOYMENT.md)

---

**¡Sistema listo para producción! 🚀**

*Desarrollado con ❤️ para la gestión eficiente de catálogos 3D*
