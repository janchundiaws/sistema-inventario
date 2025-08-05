# Configuración de CORS y Puertos - Sistema de Inventario

Este documento explica la configuración de CORS y puertos para resolver problemas de conexión entre el frontend y backend.

## 🔧 Configuración de Puertos

### Backend (Node.js)
- **Puerto**: 3000
- **URL**: http://localhost:3000
- **API Base**: http://localhost:3000/api
- **Documentación**: http://localhost:3000/api-docs
- **Health Check**: http://localhost:3000/health

### Frontend (Flutter Web)
- **Puerto**: 8080
- **URL**: http://localhost:8080
- **Backend API**: http://localhost:3000/api

## 🚀 Inicio Rápido

### 1. Iniciar Backend (Windows)
```bash
cd sys_inventario_backEnd
start-dev.bat
```

### 2. Iniciar Frontend (Windows)
```bash
cd sys_inventario_frontEnd
start-frontend.bat
```

### 3. Verificar Conexión
- Backend: http://localhost:3000/health
- Frontend: http://localhost:8080
- API Docs: http://localhost:3000/api-docs

## 🔒 Configuración de CORS

### Backend CORS Configuration
El backend está configurado para permitir conexiones desde:

```javascript
// En src/app.js
app.use(cors({
  origin: [
    'http://localhost:3000',  // Frontend Flutter Web
    'http://localhost:3001',  // Backend API
    'http://localhost:8080',  // Flutter Web por defecto
    'http://localhost:9090',  // Flutter Web alternativo
    'http://127.0.0.1:3000',  // Frontend Flutter Web (IP)
    'http://127.0.0.1:8080',  // Flutter Web (IP)
    'http://127.0.0.1:9090',  // Flutter Web alternativo (IP)
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  optionsSuccessStatus: 200
}));
```

### Frontend API Configuration
El frontend está configurado para conectarse al backend:

```dart
// En lib/config/app_config.dart
class AppConfig {
  static const String backendUrl = 'http://localhost:3001';
  static const String apiBaseUrl = '$backendUrl/api';
}
```

## 🐛 Solución de Problemas de CORS

### Error: "Access to XMLHttpRequest has been blocked by CORS policy"

**Solución:**
1. Verificar que el backend esté ejecutándose en el puerto 3001
2. Verificar que el frontend esté ejecutándose en el puerto 8080
3. Asegurarse de que ambos servicios estén activos

### Error: "Failed to load resource: net::ERR_CONNECTION_REFUSED"

**Solución:**
1. Verificar que el backend esté iniciado
2. Comprobar que no haya conflictos de puertos
3. Verificar la configuración de firewall

### Error: "Request timeout"

**Solución:**
1. Verificar la conexión a MySQL
2. Comprobar que las credenciales de la base de datos sean correctas
3. Verificar que el archivo .env esté configurado correctamente

## 📋 Verificación de Configuración

### 1. Verificar Backend
```bash
# Verificar que el backend esté ejecutándose
curl http://localhost:3001/health

# Respuesta esperada:
{
  "success": true,
  "message": "Sistema de Inventario API funcionando correctamente",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "development"
}
```

### 2. Verificar Frontend
```bash
# Verificar que el frontend esté ejecutándose
curl http://localhost:8080

# Debería devolver la página HTML de Flutter Web
```

### 3. Verificar Conexión API
```bash
# Probar endpoint de autenticación
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"password"}'
```

## 🔧 Configuración Manual

### Cambiar Puerto del Backend
1. Editar `sys_inventario_backEnd/config-local.env`:
   ```
   PORT=3001
   ```

2. Actualizar CORS en `sys_inventario_backEnd/src/app.js`:
   ```javascript
   origin: ['http://localhost:8080', 'http://localhost:3001']
   ```

### Cambiar Puerto del Frontend
1. Ejecutar Flutter con puerto específico:
   ```bash
   flutter run -d web-server --web-port 8080
   ```

2. Actualizar configuración en `lib/config/app_config.dart`:
   ```dart
   static const String backendUrl = 'http://localhost:3001';
   ```

## 📱 Configuración para Dispositivos Móviles

### Para Android Emulator
- Backend: http://10.0.2.2:3001
- Frontend: http://10.0.2.2:8080

### Para iOS Simulator
- Backend: http://localhost:3001
- Frontend: http://localhost:8080

### Para Dispositivo Físico
- Backend: http://[IP-DE-TU-PC]:3001
- Frontend: http://[IP-DE-TU-PC]:8080

## 🔍 Logs de Depuración

### Backend Logs
El backend muestra logs detallados de cada request:
```
2024-01-01T00:00:00.000Z - POST /api/auth/login
```

### Frontend Logs
El frontend muestra logs de API en la consola:
```
🌐 API Request: POST http://localhost:3001/api/auth/login
📦 Request Body: {"email":"test@test.com","password":"password"}
📡 Response Status: 200
📄 Response Body: {"success":true,"token":"..."}
```

## 🚨 Problemas Comunes

### 1. Puerto 3001 ya está en uso
```bash
# Encontrar proceso que usa el puerto
netstat -ano | findstr :3001

# Terminar proceso
taskkill /PID [PID] /F
```

### 2. Puerto 8080 ya está en uso
```bash
# Encontrar proceso que usa el puerto
netstat -ano | findstr :8080

# Terminar proceso
taskkill /PID [PID] /F
```

### 3. MySQL no está ejecutándose
```bash
# Verificar estado de MySQL
mysqladmin ping -h"host.docker.internal" -P"3306" -u"root" -p"tu_password_mysql_local"
```

## 📞 Soporte

Si continúas teniendo problemas:

1. Verifica que todos los servicios estén ejecutándose
2. Revisa los logs de error en la consola
3. Comprueba la configuración de firewall
4. Verifica que las versiones de Node.js y Flutter sean compatibles

---

**Configuración actualizada para resolver problemas de CORS** 