# Sistema de Inventario - Backend API

Backend completo en Node.js para gestión de inventario con trazabilidad, autenticación JWT y documentación Swagger.

## 🚀 Características

- **Autenticación JWT** con roles de usuario
- **Gestión de productos** con categorías
- **Trazabilidad completa** con logs de auditoría
- **Documentación automática** con Swagger
- **Validación de datos** con express-validator
- **Seguridad** con helmet, rate limiting y CORS
- **Base de datos MySQL** con pool de conexiones
- **Middleware de auditoría** para todas las operaciones

## 📋 Requisitos Previos

### Para Ejecución Local
- Node.js (v14 o superior)
- MySQL (v8.0 o superior)
- npm o yarn

### Para Ejecución con Docker
- Docker
- Docker Compose

## 🛠️ Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <tu-repositorio>
   cd sys_inventario
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   ```

3. **Configurar base de datos**
   - Crear una base de datos MySQL llamada `sys_inventario`
   - Ejecutar el script `bd_mysql.sql` para crear las tablas

4. **Configurar variables de entorno**
   ```bash
   cp env.example .env
   ```
   
   Editar el archivo `.env` con tus configuraciones:
   ```env
   DB_HOST=localhost
   DB_PORT=3306
   DB_NAME=sys_inventario
   DB_USER=root
   DB_PASSWORD=tu_password
   JWT_SECRET=tu_jwt_secret_super_seguro
   ```

5. **Inicializar datos de ejemplo**
   ```bash
   node src/scripts/initDb.js
   ```

## 🚀 Ejecución

### Opción 1: Ejecución Local

#### Desarrollo
```bash
npm run dev
```

#### Producción
```bash
npm start
```

### Opción 2: Ejecución con Docker (Recomendado)

#### Despliegue Completo
```bash
# Construir y ejecutar con Docker Compose
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener servicios
docker-compose down
```

#### Solo la Aplicación
```bash
# Construir imagen
docker build -t sys-inventario .

# Ejecutar contenedor
docker run -d \
  --name sys-inventario-app \
  -p 3000:3000 \
     -e DB_HOST=host.docker.internal \
   -e DB_PORT=3306 \
   -e DB_NAME=sys_inventario \
   -e DB_USER=root \
   -e DB_PASSWORD=tu_password \
  -e JWT_SECRET=tu_jwt_secret \
  sys-inventario
```

📖 **Documentación completa de Docker**: Ver [DOCKER.md](./DOCKER.md)

## 📚 Documentación de la API

Una vez que el servidor esté corriendo, puedes acceder a la documentación Swagger en:

**http://localhost:3000/api-docs**

## 🔐 Autenticación

### Credenciales por defecto
- **Email:** admin@inventario.com
- **Password:** admin123

### Flujo de autenticación
1. Registrar usuario: `POST /api/auth/register`
2. Iniciar sesión: `POST /api/auth/login`
3. Usar el token JWT en el header: `Authorization: Bearer <token>`

## 📊 Endpoints Principales

### Autenticación
- `POST /api/auth/register` - Registrar usuario
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/auth/profile` - Obtener perfil (requiere autenticación)

### Productos
- `GET /api/products` - Listar productos (con paginación y filtros)
- `GET /api/products/:id` - Obtener producto por ID
- `POST /api/products` - Crear producto (requiere autenticación)
- `PUT /api/products/:id` - Actualizar producto (requiere autenticación)
- `DELETE /api/products/:id` - Eliminar producto (requiere autenticación)

### Utilidades
- `GET /health` - Health check del servidor

## 🏗️ Estructura del Proyecto

```
sys_inventario/
├── src/
│   ├── config/
│   │   └── database.js          # Configuración de PostgreSQL
│   ├── controllers/
│   │   ├── authController.js    # Controlador de autenticación
│   │   └── productController.js # Controlador de productos
│   ├── middleware/
│   │   ├── auth.js              # Middleware de autenticación
│   │   └── audit.js             # Middleware de auditoría
│   ├── routes/
│   │   ├── auth.js              # Rutas de autenticación
│   │   └── products.js          # Rutas de productos
│   ├── scripts/
│   │   └── initDb.js            # Script de inicialización
│   └── app.js                   # Aplicación principal
├── bd.sql                       # Script de base de datos
├── package.json                 # Dependencias y scripts
├── env.example                  # Variables de entorno de ejemplo
└── README.md                    # Documentación
```

## 🔒 Seguridad

- **JWT Tokens** para autenticación
- **Helmet** para headers de seguridad
- **Rate Limiting** para prevenir ataques
- **CORS** configurado para desarrollo/producción
- **Validación de datos** en todos los endpoints
- **Auditoría completa** de todas las operaciones

## 📝 Logs de Auditoría

Todas las operaciones se registran automáticamente en la tabla `audit_logs` con:
- Usuario que realizó la acción
- Tipo de operación (GET, POST, PUT, DELETE)
- Tabla afectada
- ID del registro
- IP del cliente
- User Agent
- Timestamp

## 🧪 Testing

```bash
npm test
```

## 📦 Scripts Disponibles

- `npm start` - Iniciar en producción
- `npm run dev` - Iniciar en desarrollo con nodemon
- `npm test` - Ejecutar tests
- `node src/scripts/initDb.js` - Inicializar base de datos

## 🌍 Variables de Entorno

| Variable | Descripción | Default |
|----------|-------------|---------|
| `DB_HOST` | Host de MySQL | localhost |
| `DB_PORT` | Puerto de MySQL | 3306 |
| `DB_NAME` | Nombre de la base de datos | sys_inventario |
| `DB_USER` | Usuario de MySQL | root |
| `DB_PASSWORD` | Contraseña de MySQL | - |
| `JWT_SECRET` | Secret para JWT | - |
| `PORT` | Puerto del servidor | 3000 |
| `NODE_ENV` | Ambiente (development/production) | development |

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. Revisa la documentación Swagger en `/api-docs`
2. Verifica los logs del servidor
3. Asegúrate de que la base de datos esté configurada correctamente
4. Contacta al equipo de desarrollo

---

**¡Disfruta usando el Sistema de Inventario! 🎉** 