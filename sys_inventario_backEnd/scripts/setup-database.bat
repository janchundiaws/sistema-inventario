@echo off
chcp 65001 >nul

echo 🗄️ Configurando base de datos del Sistema de Inventario...
echo.

REM Verificar si MySQL está disponible
mysql --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: MySQL no está instalado o no está en el PATH
    echo    Instala MySQL o asegúrate de que esté en el PATH del sistema
    pause
    exit /b 1
)

echo ✅ MySQL encontrado
echo.

REM Leer configuración del archivo .env
if exist .env (
    echo 📝 Usando configuración existente...
) else (
    echo 📝 Copiando configuración de desarrollo...
    copy config-local.env .env
)

echo.
echo 🔧 Configurando base de datos...

REM Ejecutar script de inserción de roles
echo 📋 Insertando roles por defecto...
mysql -h"host.docker.internal" -P"3306" -u"root" -p"tu_password_mysql_local" < scripts/insert-default-roles.sql

if errorlevel 1 (
    echo ❌ Error al insertar roles por defecto
    echo    Verifica las credenciales de MySQL en el archivo .env
    pause
    exit /b 1
)

echo ✅ Roles insertados correctamente
echo.
echo 🎉 Base de datos configurada exitosamente!
echo.
echo 📋 Roles disponibles:
echo    - Administrador
echo    - Gerente  
echo    - Vendedor
echo    - Almacén
echo    - Usuario
echo.
pause 