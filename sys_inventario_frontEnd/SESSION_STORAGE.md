# Sistema de Almacenamiento de Sesiones - localStorage

## Descripción General

El sistema de inventario implementa un mecanismo robusto de almacenamiento de sesiones que utiliza `localStorage` cuando se ejecuta en la versión web de Flutter, y `SharedPreferences` para las versiones móviles.

## Características Principales

### 🔐 Almacenamiento Automático de Sesión
- **Token de autenticación**: Se guarda automáticamente al hacer login/registro
- **Información del usuario**: Datos del perfil del usuario
- **Información de sesión**: Timestamp de login, user agent, plataforma
- **Preferencias**: Opción "Recordar sesión"

### 🌐 Compatibilidad Web
- **localStorage**: Utilizado automáticamente en la versión web
- **Persistencia**: La sesión se mantiene entre recargas del navegador
- **Seguridad**: Los datos se almacenan localmente en el navegador

### 📱 Compatibilidad Móvil
- **SharedPreferences**: Utilizado en versiones Android/iOS
- **Almacenamiento nativo**: Integración con el sistema de archivos del dispositivo

## Estructura de Datos Almacenados

### Claves de Almacenamiento
```dart
static const String _tokenKey = 'auth_token';        // JWT Token
static const String _userKey = 'user_data';          // Datos del usuario
static const String _sessionKey = 'session_info';    // Información de sesión
static const String _lastLoginKey = 'last_login';    // Último login
static const String _rememberMeKey = 'remember_me';  // Preferencia "recordar"
```

### Información de Sesión
```json
{
  "login_time": "2024-01-15T10:30:00.000Z",
  "user_agent": "Flutter Web",
  "platform": "web",
  "remember_me": true
}
```

## Flujo de Autenticación

### 1. Login/Registro
```dart
// Al hacer login exitoso
await StorageService.saveToken(response['token']);
await StorageService.saveUser(user);
await StorageService.saveSessionInfo(
  loginTime: DateTime.now(),
  userAgent: 'Flutter Web',
  rememberMe: rememberMe,
);
```

### 2. Verificación de Sesión
```dart
// Al iniciar la aplicación
final isAuth = await StorageService.isAuthenticated();
if (isAuth) {
  final user = await StorageService.getUser();
  // Restaurar sesión automáticamente
}
```

### 3. Logout
```dart
// Al cerrar sesión
await StorageService.clearSession();
// Limpia todos los datos de sesión
```

## Funcionalidades Implementadas

### ✅ Características Completadas
- [x] Almacenamiento automático de token JWT
- [x] Persistencia de datos del usuario
- [x] Información detallada de sesión
- [x] Opción "Recordar sesión"
- [x] Restauración automática de sesión
- [x] Limpieza completa en logout
- [x] Compatibilidad web/móvil
- [x] Logs detallados para debugging

### 🎯 Funcionalidades Específicas para Web
- [x] Uso automático de localStorage
- [x] Persistencia entre recargas
- [x] Información de plataforma web
- [x] User agent específico para web

## Uso en la Aplicación

### Pantalla de Login
- Checkbox "Recordar sesión" disponible
- Al hacer login se guarda la sesión automáticamente
- Logs en consola indican el almacenamiento

### Pantalla de Inicio
- Menú de usuario con "Información de Sesión"
- Muestra detalles de la sesión actual
- Incluye plataforma, último login, etc.

### Inicialización
- `SplashScreen` verifica sesión automáticamente
- Redirección automática según estado de autenticación

## Verificación en el Navegador

### Inspeccionar localStorage
1. Abrir DevTools (F12)
2. Ir a la pestaña "Application" (Chrome) o "Storage" (Firefox)
3. En "Local Storage" encontrar el dominio de la aplicación
4. Verificar las claves almacenadas:
   - `auth_token`
   - `user_data`
   - `session_info`
   - `last_login`
   - `remember_me`

### Logs en Consola
Los siguientes mensajes aparecen en la consola del navegador:
```
🔐 Token guardado en localStorage (Web)
👤 Usuario guardado en localStorage (Web): [Nombre]
💾 Información de sesión guardada en localStorage (Web)
🔍 Verificación de autenticación en localStorage (Web): Autenticado
```

## Seguridad

### Consideraciones
- Los datos se almacenan localmente en el navegador
- El token JWT tiene tiempo de expiración
- No se almacenan contraseñas en texto plano
- Los datos se limpian completamente al hacer logout

### Recomendaciones
- Usar HTTPS en producción
- Implementar refresh tokens para mayor seguridad
- Considerar encriptación adicional para datos sensibles
- Validar tokens en el servidor en cada request

## Troubleshooting

### Problemas Comunes
1. **Sesión no persiste**: Verificar que localStorage esté habilitado
2. **Token expirado**: El backend debe validar y renovar tokens
3. **Datos corruptos**: Usar `clearSession()` para limpiar y reiniciar

### Debugging
- Revisar logs en consola del navegador
- Inspeccionar localStorage en DevTools
- Verificar que el backend esté funcionando
- Comprobar que CORS esté configurado correctamente

## Archivos Relacionados

- `lib/services/storage_service.dart` - Servicio principal de almacenamiento
- `lib/services/api_service.dart` - Integración con API
- `lib/providers/auth_provider.dart` - Gestión de estado de autenticación
- `lib/screens/login_screen.dart` - Interfaz de login con "Recordar sesión"
- `lib/screens/home_screen.dart` - Información de sesión en menú de usuario 