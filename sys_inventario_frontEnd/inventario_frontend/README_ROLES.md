# Sistema de Roles - Sistema de Inventario

Este documento explica la implementación del sistema de roles en el Sistema de Inventario.

## 🎯 Funcionalidad Implementada

### ✅ Backend (Node.js)
- **Controlador de Roles**: `src/controllers/roleController.js`
- **Rutas de Roles**: `src/routes/roles.js`
- **Endpoints disponibles**:
  - `GET /api/roles` - Obtener lista de roles
  - `GET /api/roles/:id` - Obtener rol por ID
  - `POST /api/roles` - Crear nuevo rol (requiere autenticación)

### ✅ Frontend (Flutter)
- **Modelo de Role**: `lib/models/role.dart`
- **Provider de Roles**: `lib/providers/role_provider.dart`
- **Campo de selección de roles** en el formulario de registro
- **Validación** de selección de rol obligatorio

## 🗄️ Estructura de Base de Datos

### Tabla `roles`
```sql
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Tabla `users` (actualizada)
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role_id INT,
    status BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);
```

## 🚀 Configuración Inicial

### 1. Configurar Base de Datos
```bash
cd sys_inventario_backEnd
setup-database.bat
```

### 2. Verificar Roles Insertados
```sql
SELECT * FROM roles ORDER BY id;
```

### 3. Roles por Defecto
- **Administrador**: Acceso completo al sistema
- **Gerente**: Gestión de productos, categorías, compras y ventas
- **Vendedor**: Procesamiento de ventas y consulta de productos
- **Almacén**: Gestión de productos, categorías y compras
- **Usuario**: Acceso básico limitado

## 📱 Uso en el Frontend

### Formulario de Registro
El formulario de registro ahora incluye:

1. **Campo de selección de roles** con dropdown
2. **Descripción del rol** visible en la selección
3. **Validación obligatoria** del rol
4. **Carga automática** de roles al abrir el formulario

### Código de Ejemplo
```dart
// En el formulario de registro
Consumer<RoleProvider>(
  builder: (context, roleProvider, child) {
    return DropdownButtonFormField<Role>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Rol de usuario',
        prefixIcon: Icon(Icons.work_outline),
      ),
      items: roleProvider.roles.map((Role role) {
        return DropdownMenuItem<Role>(
          value: role,
          child: Column(
            children: [
              Text(role.name, style: TextStyle(fontWeight: FontWeight.bold)),
              if (role.description != null)
                Text(role.description!, style: TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
      onChanged: (Role? newValue) {
        setState(() {
          _selectedRole = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor selecciona un rol';
        }
        return null;
      },
    );
  },
)
```

## 🔧 API Endpoints

### Obtener Roles
```http
GET /api/roles
```

**Respuesta:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Administrador",
      "description": "Rol con acceso completo al sistema",
      "created_at": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

### Crear Rol
```http
POST /api/roles
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Nuevo Rol",
  "description": "Descripción del nuevo rol"
}
```

## 🎨 Características del Frontend

### Provider de Roles
- **Carga automática** de roles desde la API
- **Manejo de estados** (loading, error, success)
- **Métodos de utilidad** para buscar roles por ID o nombre
- **Notificación de cambios** para actualizar la UI

### Validaciones
- **Rol obligatorio** en el registro
- **Manejo de errores** de carga de roles
- **Indicador de carga** mientras se obtienen los roles
- **Mensajes de error** descriptivos

## 🔍 Logs de Depuración

### Backend
```
🌐 API Request: GET http://localhost:3001/api/roles
📡 Response Status: 200
📄 Response Body: {"success":true,"data":[...]}
```

### Frontend
```
🌐 API Request: GET http://localhost:3001/api/roles
📦 Request Body: null
📡 Response Status: 200
📄 Response Body: {"success":true,"data":[...]}
```

## 🚨 Solución de Problemas

### Error: "No se pueden cargar roles"
1. Verificar que el backend esté ejecutándose
2. Comprobar que la base de datos tenga roles insertados
3. Verificar la conexión a la base de datos

### Error: "Rol no encontrado"
1. Verificar que el role_id enviado existe en la base de datos
2. Comprobar que la tabla roles tenga datos

### Error: "Campo role_id requerido"
1. Asegurarse de que se seleccione un rol en el formulario
2. Verificar que el formulario tenga validación de rol

## 📋 Próximas Funcionalidades

- [ ] Gestión de permisos por rol
- [ ] Interfaz para crear/editar roles
- [ ] Validación de permisos en el frontend
- [ ] Roles dinámicos con permisos personalizables
- [ ] Auditoría de cambios de roles

## 🔐 Seguridad

- **Validación de entrada** en el backend
- **Sanitización de datos** antes de guardar
- **Verificación de permisos** para crear roles
- **Logs de auditoría** para cambios de roles

---

**Sistema de roles implementado y funcional** 