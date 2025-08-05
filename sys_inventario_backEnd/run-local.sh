#!/bin/bash

# Script para ejecutar Sistema de Inventario con MySQL Local
echo "🚀 Iniciando Sistema de Inventario con MySQL Local..."

# Verificar que MySQL esté corriendo localmente
echo "🔍 Verificando conexión a MySQL local..."
if ! nc -z localhost 3306; then
    echo "❌ Error: MySQL no está corriendo en localhost:3306"
    echo "💡 Asegúrate de que MySQL esté iniciado en tu máquina local"
    exit 1
fi
echo "✅ MySQL local está disponible"

# Construir la imagen
echo "🔨 Construyendo imagen Docker..."
docker build -t sys-inventario-local .

# Ejecutar el contenedor
echo "🐳 Ejecutando contenedor..."
docker run -d \
  --name sys-inventario-app \
  -p 3000:3000 \
  -e DB_HOST=host.docker.internal \
  -e DB_PORT=3306 \
  -e DB_NAME=sys_inventario \
  -e DB_USER=root \
  -e DB_PASSWORD=${DB_PASSWORD:-tu_password_mysql_local} \
  -e JWT_SECRET=${JWT_SECRET:-tu_jwt_secret_super_seguro_aqui} \
  --add-host=host.docker.internal:host-gateway \
  sys-inventario-local

echo "✅ Aplicación iniciada!"
echo "🌐 API disponible en: http://localhost:3000"
echo "📚 Documentación en: http://localhost:3000/api-docs"
echo "🏥 Health check en: http://localhost:3000/health"

# Mostrar logs
echo "📋 Mostrando logs (Ctrl+C para salir)..."
docker logs -f sys-inventario-app 