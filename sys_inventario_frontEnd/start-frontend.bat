@echo off
chcp 65001 >nul

echo 🚀 Iniciando Sistema de Inventario Frontend...

cd inventario_frontend

REM Verificar si Flutter está instalado
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Flutter no está instalado o no está en el PATH
    echo    Instala Flutter desde: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Obtener dependencias
echo 📦 Obteniendo dependencias...
flutter pub get

REM Verificar que el backend esté ejecutándose
echo 🔍 Verificando conexión al backend...
curl -s http://localhost:3001/health >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Advertencia: No se pudo conectar al backend
    echo    Asegúrate de que el backend esté ejecutándose en http://localhost:3000
    echo    Ejecuta el script start-dev.bat en la carpeta del backend
    echo.
)

echo 🌐 Iniciando aplicación Flutter...
echo 📱 Frontend URL: http://localhost:8080 (Flutter Web)
echo 🔗 Backend URL: http://localhost:3000
echo.
echo Presiona Ctrl+C para detener la aplicación
echo.

REM Iniciar Flutter Web
flutter run -d web-server --web-port 8080 