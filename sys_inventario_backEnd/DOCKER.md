# Docker - Sistema de Inventario

Este documento explica cómo usar Docker para ejecutar el Sistema de Inventario.

## Prerrequisitos

- Docker instalado en tu sistema
- Docker Compose instalado

## Opciones de Despliegue

### 1. Despliegue Completo con Docker Compose (Recomendado)

Este método despliega tanto la aplicación como la base de datos MySQL.

```bash
# Construir y ejecutar todos los servicios
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Detener todos los servicios
docker-compose down

# Detener y eliminar volúmenes (¡CUIDADO! Esto eliminará todos los datos)
docker-compose down -v
```

### 2. Solo la Aplicación con Docker

Si ya tienes MySQL ejecutándose localmente:

```bash
# Construir la imagen
docker build -t sys-inventario .

# Ejecutar el contenedor
docker run -d \
  --name sys-inventario-app \
  -p 3000:3000 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=3306 \
  -e DB_NAME=sys_inventario \
  -e DB_USER=root \
  -e DB_PASSWORD=tu_password \
  -e JWT_SECRET=tu_jwt_secret \
  sys-inventario
```

## Variables de Entorno

### Para Docker Compose

Las variables están configuradas en el archivo `docker-compose.yml`:

```yaml
environment:
  NODE_ENV: production
  PORT: 3000
  DB_HOST: mysql
  DB_PORT: 3306
  DB_NAME: sys_inventario
  DB_USER: root
  DB_PASSWORD: root123
  JWT_SECRET: tu_jwt_secret_super_seguro_aqui
  SWAGGER_TITLE: Sistema de Inventario API
  SWAGGER_DESCRIPTION: API para gestión de inventario
  SWAGGER_VERSION: 1.0.0
```

### Para Docker Run

```bash
-e NODE_ENV=production
-e PORT=3000
-e DB_HOST=tu_host
-e DB_PORT=3306
-e DB_NAME=sys_inventario
-e DB_USER=tu_usuario
-e DB_PASSWORD=tu_password
-e JWT_SECRET=tu_jwt_secret
```

## Puertos

- **3000**: API de la aplicación
- **3306**: Base de datos MySQL (solo en Docker Compose)

## URLs de Acceso

Una vez ejecutado:

- **API**: http://localhost:3000
- **Documentación Swagger**: http://localhost:3000/api-docs
- **Health Check**: http://localhost:3000/health

## Comandos Útiles

### Docker Compose

```bash
# Ver estado de los servicios
docker-compose ps

# Ver logs de un servicio específico
docker-compose logs app
docker-compose logs mysql

# Reiniciar un servicio
docker-compose restart app

# Ejecutar comandos dentro del contenedor
docker-compose exec app sh
docker-compose exec mysql mysql -u root -p -d sys_inventario

# Reconstruir y reiniciar
docker-compose up -d --build
```

### Docker

```bash
# Ver contenedores ejecutándose
docker ps

# Ver logs del contenedor
docker logs sys-inventario-app

# Ejecutar comandos dentro del contenedor
docker exec -it sys-inventario-app sh

# Parar y eliminar contenedor
docker stop sys-inventario-app
docker rm sys-inventario-app
```

## Volúmenes y Persistencia

### Docker Compose

Los datos de MySQL se almacenan en un volumen persistente:
- `mysql_data`: Datos de la base de datos

### Backup y Restore

```bash
# Backup de la base de datos
docker-compose exec mysql mysqldump -u root -p sys_inventario > backup.sql

# Restore de la base de datos
docker-compose exec -T mysql mysql -u root -p sys_inventario < backup.sql
```

## Troubleshooting

### Problemas Comunes

1. **Puerto 3000 ocupado**:
   ```bash
   # Cambiar puerto en docker-compose.yml
   ports:
     - "3001:3000"  # Usar puerto 3001 en lugar de 3000
   ```

2. **Error de conexión a la base de datos**:
   ```bash
   # Verificar que MySQL esté ejecutándose
   docker-compose logs mysql
   
   # Verificar conectividad
   docker-compose exec app ping mysql
   ```

3. **Permisos de archivos**:
   ```bash
   # Reconstruir imagen
   docker-compose build --no-cache
   ```

### Logs Detallados

```bash
# Ver logs con timestamps
docker-compose logs -f --timestamps

# Ver logs de los últimos 100 líneas
docker-compose logs --tail=100 app
```

## Desarrollo con Docker

### Modo Desarrollo

```bash
# Usar target de desarrollo
docker build --target deps-dev -t sys-inventario-dev .

# Ejecutar con nodemon
docker run -d \
  --name sys-inventario-dev \
  -p 3000:3000 \
  -v $(pwd)/src:/app/src \
  -e NODE_ENV=development \
  sys-inventario-dev \
  npm run dev
```

### Hot Reload

Para desarrollo con hot reload, monta el código fuente como volumen:

```yaml
# En docker-compose.yml
volumes:
  - ./src:/app/src
```

## Seguridad

### Producción

1. **Cambiar contraseñas por defecto**:
   ```yaml
   environment:
     POSTGRES_PASSWORD: tu_password_seguro
     JWT_SECRET: tu_jwt_secret_super_seguro
   ```

2. **Usar secrets de Docker**:
   ```bash
   echo "tu_password_seguro" | docker secret create db_password -
   ```

3. **Limitar acceso a la red**:
   ```yaml
   networks:
     inventario_network:
       driver: bridge
       internal: true  # Solo acceso interno
   ```

## Monitoreo

### Health Checks

Los servicios incluyen health checks automáticos:

- **App**: Verifica endpoint `/health`
- **MySQL**: Verifica conectividad con `mysqladmin ping`

### Métricas

```bash
# Ver estadísticas de uso
docker stats

# Ver uso de recursos
docker system df
```

## Limpieza

```bash
# Eliminar contenedores, redes e imágenes no utilizadas
docker system prune

# Eliminar todo (¡CUIDADO!)
docker system prune -a --volumes
``` 