#!/bin/bash

# Script de inicio para Sistema de Inventario
echo "🚀 Iniciando Sistema de Inventario..."

# Verificar si estamos en Docker
if [ -f /.dockerenv ]; then
    echo "📦 Ejecutando en contenedor Docker"
    
    # Esperar a que MySQL esté disponible
    echo "⏳ Esperando conexión a MySQL..."
    while ! nc -z $DB_HOST $DB_PORT; do
        echo "Esperando MySQL en $DB_HOST:$DB_PORT..."
        sleep 2
    done
    echo "✅ MySQL está disponible"
else
    echo "🖥️  Ejecutando localmente"
fi

# Iniciar la aplicación
echo "🎯 Iniciando aplicación Node.js..."
exec node src/app.js 