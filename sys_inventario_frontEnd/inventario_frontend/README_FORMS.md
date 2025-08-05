# Formularios de Productos y Categorías - Sistema de Inventario

Este documento explica la implementación de los formularios para gestionar productos y categorías en el Sistema de Inventario.

## 🎯 Funcionalidad Implementada

### ✅ **Formulario de Categorías**
- **Pantalla**: `lib/screens/category_form_screen.dart`
- **Funcionalidades**:
  - Crear nueva categoría
  - Editar categoría existente
  - Validación de campos obligatorios
  - Manejo de errores y estados de carga

### ✅ **Formulario de Productos**
- **Pantalla**: `lib/screens/product_form_screen.dart`
- **Funcionalidades**:
  - Crear nuevo producto
  - Editar producto existente
  - Selección de categoría (opcional)
  - Validación de campos obligatorios y numéricos
  - Control de estado del producto (activo/inactivo)

## 📱 Características de los Formularios

### 🎨 **Diseño y UX**
- **Interfaz moderna** con gradientes y Material Design 3
- **Validación en tiempo real** de campos obligatorios
- **Indicadores de carga** durante operaciones
- **Mensajes de error** descriptivos
- **Navegación intuitiva** con AppBar personalizado

### 🔧 **Validaciones Implementadas**

#### Categorías
- **Nombre**: Obligatorio, mínimo 2 caracteres
- **Descripción**: Opcional, texto libre

#### Productos
- **Nombre**: Obligatorio, mínimo 2 caracteres
- **Descripción**: Opcional, texto libre
- **SKU**: Opcional, código único
- **Categoría**: Opcional, selección desde dropdown
- **Stock**: Obligatorio, número entero positivo
- **Precio**: Obligatorio, número decimal positivo
- **Costo**: Obligatorio, número decimal positivo
- **Estado**: Switch para activar/desactivar producto

## 🗄️ Estructura de Datos

### Modelo Category
```dart
class Category {
  final int id;
  final String name;
  final String? description;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;
}
```

### Modelo Product
```dart
class Product {
  final int id;
  final String name;
  final String? description;
  final String? sku;
  final int? categoryId;
  final String? categoryName;
  final int stockQuantity;
  final double price;
  final double cost;
  final bool status;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;
}
```

## 🔧 Providers y Estado

### CategoryProvider
- **Cargar categorías** desde la API
- **Crear categoría** nueva
- **Actualizar categoría** existente
- **Eliminar categoría**
- **Manejo de estados** (loading, error, success)

### ProductProvider
- **Cargar productos** con paginación
- **Crear producto** nuevo
- **Actualizar producto** existente
- **Eliminar producto**
- **Búsqueda y filtrado** de productos
- **Manejo de estados** (loading, error, success)

## 🚀 Cómo Usar

### 1. Navegar a los Formularios
Desde la pantalla principal (`HomeScreen`):
- Toca **"Productos"** para crear/editar productos
- Toca **"Categorías"** para crear/editar categorías

### 2. Crear Nuevo Elemento
1. Los formularios se abren en modo "crear" por defecto
2. Completa los campos obligatorios
3. Toca **"Crear"** para guardar
4. Se muestra mensaje de éxito y regresa a la pantalla anterior

### 3. Editar Elemento Existente
1. Navega al formulario con el elemento a editar
2. Los campos se llenan automáticamente
3. Modifica los datos necesarios
4. Toca **"Actualizar"** para guardar cambios

## 📋 Campos de los Formularios

### Formulario de Categorías
```
┌─────────────────────────────────────┐
│ 📝 Nombre de la categoría *         │
│ 📄 Descripción (opcional)           │
│                                     │
│ [Crear] [Actualizar]                │
└─────────────────────────────────────┘
```

### Formulario de Productos
```
┌─────────────────────────────────────┐
│ 📦 Nombre del producto *            │
│ 📄 Descripción (opcional)           │
│ 🏷️ SKU (opcional)                  │
│ 📂 Categoría (opcional)             │
│ 📊 Cantidad en stock *              │
│ 💰 Precio de venta *                │
│ 💸 Costo del producto *             │
│ ✅ Producto activo                  │
│                                     │
│ [Crear] [Actualizar]                │
└─────────────────────────────────────┘
```

## 🔍 Logs de Depuración

### Backend
```
🌐 API Request: POST http://localhost:3000/api/categories
📦 Request Body: {"name":"Electrónicos","description":"Productos electrónicos"}
📡 Response Status: 201
📄 Response Body: {"success":true,"data":{...}}
```

### Frontend
```
🌐 API Request: POST http://localhost:3000/api/products
📦 Request Body: {"name":"Laptop","price":999.99,"cost":800.00,...}
📡 Response Status: 201
📄 Response Body: {"success":true,"data":{...}}
```

## 🚨 Solución de Problemas

### Error: "No se pueden cargar categorías"
1. Verificar que el backend esté ejecutándose
2. Comprobar la conexión a la base de datos
3. Verificar que existan categorías en la base de datos

### Error: "SKU ya existe"
1. Cambiar el SKU del producto
2. Dejar el campo SKU vacío para que se genere automáticamente

### Error: "Categoría ya existe"
1. Cambiar el nombre de la categoría
2. Verificar que no exista una categoría similar

### Error: "Campos inválidos"
1. Revisar que todos los campos obligatorios estén completos
2. Verificar que los valores numéricos sean positivos
3. Comprobar que el nombre tenga al menos 2 caracteres

## 📱 Navegación

### Flujo de Navegación
```
HomeScreen
├── ProductFormScreen (Crear)
├── ProductFormScreen (Editar)
├── CategoryFormScreen (Crear)
└── CategoryFormScreen (Editar)
```

### Botones de Acción
- **Crear**: Guarda un nuevo elemento
- **Actualizar**: Modifica un elemento existente
- **Cancelar**: Regresa sin guardar cambios
- **Eliminar**: Elimina el elemento (en desarrollo)

## 🎨 Personalización

### Temas y Colores
- **Color primario**: `#667eea`
- **Gradiente**: `#667eea` → `#764ba2`
- **Bordes redondeados**: 12px
- **Elevación de tarjetas**: 8px

### Iconos Utilizados
- **Productos**: `Icons.inventory`
- **Categorías**: `Icons.category`
- **SKU**: `Icons.qr_code`
- **Precio**: `Icons.attach_money`
- **Stock**: `Icons.inventory_2`

## 🔐 Seguridad

- **Validación de entrada** en el frontend
- **Autenticación requerida** para operaciones CRUD
- **Sanitización de datos** antes de enviar al backend
- **Manejo seguro de errores** sin exponer información sensible

## 📋 Próximas Funcionalidades

- [ ] Lista de productos y categorías
- [ ] Búsqueda y filtrado avanzado
- [ ] Eliminación de elementos
- [ ] Importación/exportación de datos
- [ ] Imágenes de productos
- [ ] Historial de cambios
- [ ] Notificaciones de stock bajo

---

**Formularios implementados y funcionales** 