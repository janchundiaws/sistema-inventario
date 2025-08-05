@echo off
chcp 65001 >nul

echo 🚀 Iniciando Sistema de Inventario Backend en modo desarrollo...

REM Verificar si existe el archivo .env
if not exist .env (
    echo 📝 Copiando configuración de desarrollo...
    copy config-local.env .env
    echo ✅ Archivo .env creado desde config-local.env
)

REM Instalar dependencias si no existen
if not exist node_modules (
    echo 📦 Instalando dependencias...
    npm install
)

echo 🌐 Iniciando servidor en puerto 3001...
echo 📚 Documentación: http://localhost:3001/api-docs
echo 🏥 Health Check: http://localhost:3001/health
echo 🔗 API Base URL: http://localhost:3001/api
echo.
echo Presiona Ctrl+C para detener el servidor
echo.

REM Iniciar el servidor
npm start 