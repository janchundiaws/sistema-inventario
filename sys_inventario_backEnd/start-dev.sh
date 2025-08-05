#!/bin/bash

# Script para iniciar el backend en modo desarrollo
echo "🚀 Iniciando Sistema de Inventario Backend en modo desarrollo..."

# Verificar si existe el archivo .env
if [ ! -f .env ]; then
    echo "📝 Copiando configuración de desarrollo..."
    cp config-local.env .env
    echo "✅ Archivo .env creado desde config-local.env"
fi

# Instalar dependencias si no existen
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
fi

# Verificar que MySQL esté ejecutándose
echo "🔍 Verificando conexión a MySQL..."
if ! mysqladmin ping -h"host.docker.internal" -P"3306" -u"root" -p"tu_password_mysql_local" --silent; then
    echo "⚠️  Advertencia: No se pudo conectar a MySQL"
    echo "   Asegúrate de que MySQL esté ejecutándose y la configuración sea correcta"
    echo "   Revisa el archivo .env y ajusta las credenciales si es necesario"
fi

# Iniciar el servidor
echo "🌐 Iniciando servidor en puerto 3001..."
echo "📚 Documentación: http://localhost:3001/api-docs"
echo "🏥 Health Check: http://localhost:3001/health"
echo "🔗 API Base URL: http://localhost:3001/api"
echo ""
echo "Presiona Ctrl+C para detener el servidor"
echo ""

# Iniciar el servidor
npm start 