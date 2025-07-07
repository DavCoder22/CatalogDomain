# 🚀 Guía Completa de Pruebas y Deployment - Sistema de Catálogo 3D

## 📋 Índice
1. [Revisión del Funcionamiento](#revisión-del-funcionamiento)
2. [Configuración de Swagger](#configuración-de-swagger)
3. [Pruebas Locales](#pruebas-locales)
4. [Deployment en AWS](#deployment-en-aws)
5. [Pruebas en AWS](#pruebas-en-aws)
6. [Load Balancer y Security Groups](#load-balancer-y-security-groups)
7. [Troubleshooting](#troubleshooting)

## 🔍 Revisión del Funcionamiento

### Estado Actual de los Microservicios

| Servicio | Puerto | Swagger | Health Check | Estado |
|----------|--------|---------|--------------|--------|
| **catalogo-productos** | 8081 | ✅ | ✅ | Funcionando |
| **catalogo-materiales** | 8082 | ✅ | ✅ | Funcionando |
| **catalogo-filtros** | 8083 | ❌ | ✅ | Básico |
| **catalogo-auth** | - | ❌ | ❌ | No implementado |

### Problemas Identificados y Solucionados

✅ **Corregido**: Inconsistencia de puertos en filtros (8084 → 8083)  
✅ **Agregado**: Swagger a catalogo-materiales  
✅ **Agregado**: Health checks a todos los servicios  
✅ **Configurado**: Load balancer con target groups  
✅ **Creado**: Scripts de pruebas completos  

## 📚 Configuración de Swagger

### Acceso a la Documentación

Una vez que los servicios estén ejecutándose:

- **Productos**: http://localhost:8081/swagger/index.html
- **Materiales**: http://localhost:8082/swagger/index.html

### Generar Documentación Swagger

```bash
# Para catalogo-productos
cd catalogo-productos
swag init

# Para catalogo-materiales
cd catalogo-materiales
swag init
```

## 🧪 Pruebas Locales

### 1. Iniciar Servicios

```bash
# Opción 1: Docker Compose (Recomendado)
docker-compose up -d

# Opción 2: Individual
cd catalogo-productos && go run main.go
cd catalogo-materiales && go run main.go
cd catalogo-filtros && go run main.go
```

### 2. Ejecutar Pruebas Completas

```powershell
# Windows PowerShell
.\test_services_comprehensive.ps1

# Linux/Mac
./test_services.sh
```

### 3. Pruebas Manuales

```bash
# Health Checks
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health

# Productos
curl http://localhost:8081/api/v1/productos
curl http://localhost:8081/api/v1/productos/p001

# Materiales
curl http://localhost:8082/api/v1/materiales
curl http://localhost:8082/api/v1/materiales/tipo/filamento

# Filtros
curl http://localhost:8083/api/v1/buscar
```

## ☁️ Deployment en AWS

### 1. Configurar AWS CLI

```bash
aws configure
# Ingresa tu Access Key ID, Secret Access Key, región (us-east-1)
```

### 2. Desplegar con Terraform

```bash
cd terraform/catalogo

# Inicializar Terraform
terraform init

# Planificar el deployment
terraform plan

# Aplicar la configuración
terraform apply

# Verificar outputs
terraform output
```

### 3. Verificar Recursos Creados

```bash
# Verificar ALB
aws elbv2 describe-load-balancers --names catalogo-alb

# Verificar Target Groups
aws elbv2 describe-target-groups

# Verificar EC2 Instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=catalogo-*"
```

## 🧪 Pruebas en AWS

### 1. Obtener DNS del Load Balancer

```bash
terraform output alb_dns_name
```

### 2. Ejecutar Pruebas AWS

```powershell
# Windows PowerShell
.\test_aws_services.ps1 -AlbDnsName "tu-alb-dns-name.amazonaws.com"

# Ejemplo:
.\test_aws_services.ps1 -AlbDnsName "catalogo-alb-123456789.us-east-1.elb.amazonaws.com"
```

### 3. Pruebas Manuales AWS

```bash
# Reemplaza con tu DNS del ALB
ALB_DNS="tu-alb-dns-name.amazonaws.com"

# Health Checks
curl http://$ALB_DNS/health

# APIs
curl http://$ALB_DNS/api/v1/productos
curl http://$ALB_DNS/api/v1/materiales
curl http://$ALB_DNS/api/v1/buscar

# Swagger
curl http://$ALB_DNS/swagger/index.html
```

## ⚖️ Load Balancer y Security Groups

### Arquitectura Configurada

```
Internet → ALB (puerto 80) → Target Groups → EC2 Instances
                ↓
        Security Groups:
        - ALB: puertos 80, 443
        - EC2: puertos 8081, 8082, 8083
```

### Target Groups

| Servicio | Puerto | Health Check Path | Protocol |
|----------|--------|-------------------|----------|
| **productos** | 8081 | `/health` | HTTP |
| **materiales** | 8082 | `/health` | HTTP |
| **filtros** | 8083 | `/health` | HTTP |

### Routing Rules

| Path Pattern | Target Group | Priority |
|--------------|--------------|----------|
| `/api/v1/productos*` | productos | Default |
| `/api/v1/materiales*` | materiales | 100 |
| `/api/v1/buscar*` | filtros | 200 |
| `/swagger*` | productos | 300 |

### Security Groups

**ALB Security Group:**
- Ingress: 80, 443 (HTTP/HTTPS)
- Egress: All traffic

**EC2 Security Group:**
- Ingress: 8081, 8082, 8083 (microservicios)
- Egress: All traffic

## 🔧 Troubleshooting

### Problemas Comunes

#### 1. Servicios no inician

```bash
# Verificar logs de Docker
docker-compose logs

# Verificar puertos ocupados
netstat -an | grep 808

# Reiniciar servicios
docker-compose restart
```

#### 2. Health Checks fallan

```bash
# Verificar que los servicios respondan
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health

# Verificar logs de la aplicación
docker-compose logs productos
docker-compose logs materiales
docker-compose logs filtros
```

#### 3. Load Balancer no responde

```bash
# Verificar estado del ALB
aws elbv2 describe-load-balancers --names catalogo-alb

# Verificar target health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Verificar security groups
aws ec2 describe-security-groups --group-names catalogo-alb-sg
```

#### 4. Swagger no carga

```bash
# Verificar que swag esté instalado
go install github.com/swaggo/swag/cmd/swag@latest

# Regenerar documentación
swag init

# Verificar archivos generados
ls -la docs/
```

### Comandos de Diagnóstico

```bash
# Verificar conectividad
ping localhost
telnet localhost 8081

# Verificar procesos
ps aux | grep go
docker ps

# Verificar recursos AWS
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' --output table
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,DNSName,State.Code]' --output table
```

## 📊 Monitoreo y Métricas

### Health Check Endpoints

Todos los servicios exponen un endpoint `/health` que retorna:

```json
{
  "status": "healthy",
  "service": "nombre-del-servicio",
  "version": "1.0.0"
}
```

### Métricas Recomendadas

- **Latencia**: < 500ms (excelente), < 1s (buena)
- **Disponibilidad**: > 99.9%
- **Throughput**: Monitorear requests/segundo
- **Error Rate**: < 1%

### Logs

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs -f productos

# Ver logs en AWS
aws logs describe-log-groups
aws logs tail /aws/ec2/catalogo-productos --follow
```

## 🎯 Próximos Pasos

1. **Implementar catalogo-auth** con JWT
2. **Agregar base de datos** PostgreSQL
3. **Implementar cache** Redis
4. **Configurar CI/CD** con GitHub Actions
5. **Agregar métricas** con CloudWatch
6. **Implementar SSL/TLS** con ACM
7. **Configurar auto-scaling** groups

## 📞 Soporte

Para problemas o preguntas:

1. Revisar logs de la aplicación
2. Verificar configuración de red
3. Consultar documentación de AWS
4. Revisar issues en el repositorio

---

**¡Sistema listo para producción! 🚀** 