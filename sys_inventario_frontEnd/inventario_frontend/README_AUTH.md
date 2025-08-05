# Sistema de Autenticación - Flutter Frontend

Este proyecto implementa un sistema completo de autenticación en Flutter que se conecta con el backend Node.js del Sistema de Inventario.

## 🚀 Características Implementadas

### ✅ Autenticación Completa
- **Login de usuarios** con validación de formularios
- **Registro de nuevos usuarios** con confirmación de contraseña
- **Persistencia de sesión** usando SharedPreferences
- **Logout** con confirmación
- **Verificación automática** de token al iniciar la app

### 🎨 Interfaz de Usuario
- **Diseño moderno** con gradientes y Material Design 3
- **Pantalla de splash** con animaciones
- **Formularios validados** con mensajes de error
- **Indicadores de carga** durante las operaciones
- **Navegación fluida** entre pantallas

### 🔧 Arquitectura
- **Provider Pattern** para gestión de estado
- **Separación de responsabilidades** (services, models, providers, screens)
- **Manejo de errores** centralizado
- **Configuración de tema** consistente

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── models/
│   └── user.dart            # Modelo de usuario
├── providers/
│   └── auth_provider.dart   # Provider para gestión de autenticación
├── screens/
│   ├── splash_screen.dart   # Pantalla de carga inicial
│   ├── login_screen.dart    # Pantalla de login
│   ├── register_screen.dart # Pantalla de registro
│   └── home_screen.dart     # Pantalla principal (post-login)
└── services/
    └── api_service.dart     # Servicio para comunicación con el backend
```

## 🛠️ Configuración

### 1. Dependencias Agregadas
```yaml
dependencies:
  http: ^1.1.0              # Para requests HTTP
  shared_preferences: ^2.2.2 # Para almacenamiento local
  provider: ^6.1.1          # Para gestión de estado
  form_validator: ^2.1.1    # Para validación de formularios
```

### 2. Configuración del Backend
El frontend está configurado para conectarse al backend en:
- **URL Base**: `http://localhost:3000/api`
- **Endpoints**:
  - `POST /auth/login` - Login de usuario
  - `POST /auth/register` - Registro de usuario
  - `GET /auth/profile` - Obtener perfil (requiere token)

## 🚀 Cómo Usar

### 1. Iniciar el Backend
```bash
cd sys_inventario_backEnd
npm install
npm start
```

### 2. Iniciar el Frontend
```bash
cd sys_inventario_frontEnd/inventario_frontend
flutter pub get
flutter run
```

### 3. Flujo de Uso
1. **Al abrir la app**: Se muestra la pantalla de splash
2. **Verificación automática**: Se verifica si hay un token guardado
3. **Si no hay token**: Se redirige a la pantalla de login
4. **Login/Registro**: El usuario puede iniciar sesión o registrarse
5. **Post-autenticación**: Se redirige a la pantalla principal
6. **Logout**: Disponible desde el menú de usuario

## 🔐 Funcionalidades de Seguridad

### Validaciones de Formularios
- **Email**: Formato válido requerido
- **Contraseña**: Mínimo 6 caracteres
- **Nombre**: Mínimo 2 caracteres
- **Confirmación**: Las contraseñas deben coincidir

### Manejo de Tokens
- **Almacenamiento seguro** en SharedPreferences
- **Inclusión automática** en headers de requests
- **Verificación de validez** al iniciar la app
- **Limpieza automática** en logout

### Manejo de Errores
- **Mensajes descriptivos** para el usuario
- **Validación de respuestas** del servidor
- **Fallback graceful** en caso de errores de red

## 🎯 Pantallas Implementadas

### Splash Screen
- Animaciones de entrada
- Verificación de autenticación
- Redirección automática

### Login Screen
- Formulario de email y contraseña
- Validación en tiempo real
- Enlace a registro
- Manejo de errores

### Register Screen
- Formulario completo de registro
- Validación de contraseñas
- Enlace de regreso a login
- Confirmación de datos

### Home Screen
- Dashboard principal
- Información del usuario
- Menú de funciones (placeholder)
- Opciones de perfil y logout

## 🔧 Personalización

### Cambiar URL del Backend
Editar en `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://tu-servidor:puerto/api';
```

### Modificar Tema
Editar en `lib/main.dart` en la sección `ThemeData`:
```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFFtu-color),
  brightness: Brightness.light,
),
```

### Agregar Nuevas Funciones
1. Crear nuevos endpoints en el backend
2. Agregar métodos en `ApiService`
3. Crear providers específicos si es necesario
4. Implementar pantallas correspondientes

## 🐛 Solución de Problemas

### Error de Conexión
- Verificar que el backend esté corriendo en el puerto correcto
- Comprobar la URL en `api_service.dart`
- Verificar configuración de CORS en el backend

### Error de Dependencias
```bash
flutter clean
flutter pub get
```

### Error de Compilación
- Verificar que todas las importaciones estén correctas
- Comprobar que las dependencias estén en `pubspec.yaml`

## 📱 Próximas Funcionalidades

- [ ] Gestión de productos
- [ ] Gestión de categorías
- [ ] Gestión de compras
- [ ] Gestión de ventas
- [ ] Reportes y estadísticas
- [ ] Configuración del sistema
- [ ] Recuperación de contraseña
- [ ] Verificación de email
- [ ] Roles y permisos

## 🤝 Contribución

Para agregar nuevas funcionalidades:
1. Crear la rama correspondiente
2. Implementar la funcionalidad
3. Agregar validaciones y manejo de errores
4. Probar en diferentes dispositivos
5. Crear pull request con documentación

---

**Desarrollado con ❤️ para el Sistema de Inventario** 