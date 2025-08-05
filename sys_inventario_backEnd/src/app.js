const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
require('dotenv').config();

// Importar rutas
const authRoutes = require('./routes/auth');
const productRoutes = require('./routes/products');
const purchaseRoutes = require('./routes/purchases');
const saleRoutes = require('./routes/sales');
const categoryRoutes = require('./routes/categories');
const roleRoutes = require('./routes/roles');
const inventoryAdjustmentRoutes = require('./routes/inventoryAdjustments');
const reportRoutes = require('./routes/reports');

const app = express();
const PORT = process.env.PORT || 3000;

// Configuración de Swagger
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: process.env.SWAGGER_TITLE || 'Sistema de Inventario API',
      version: process.env.SWAGGER_VERSION || '1.0.0',
      description: process.env.SWAGGER_DESCRIPTION || 'API para gestión de inventario con trazabilidad y usuarios',
      contact: {
        name: 'API Support',
        email: 'support@inventario.com'
      }
    },
    servers: [
      {
        url: `http://localhost:${PORT}`,
        description: 'Servidor de desarrollo'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        }
      }
    },
    security: [
      {
        bearerAuth: []
      }
    ]
  },
  apis: ['./src/controllers/*.js', './src/routes/*.js']
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Middleware de seguridad
app.use(helmet());

// Configuración de CORS
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? ['https://tu-dominio.com'] 
    : [
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

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por ventana
  message: {
    success: false,
    message: 'Demasiadas solicitudes desde esta IP, intenta de nuevo en 15 minutos'
  }
});
app.use('/api/', limiter);

// Middleware para parsing JSON
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));

// Middleware para logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Ruta de salud
app.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Sistema de Inventario API funcionando correctamente',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Documentación Swagger
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'Sistema de Inventario - API Documentation'
}));

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/products', productRoutes);
app.use('/api/purchases', purchaseRoutes);
app.use('/api/sales', saleRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/roles', roleRoutes);
app.use('/api/inventory-adjustments', inventoryAdjustmentRoutes);
app.use('/api/reports', reportRoutes);

// Middleware para manejo de errores 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Ruta no encontrada',
    path: req.originalUrl
  });
});

// Middleware para manejo de errores globales
app.use((error, req, res, next) => {
  console.error('Error:', error);
  
  res.status(error.status || 500).json({
    success: false,
    message: error.message || 'Error interno del servidor',
    ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
  console.log(`📚 Documentación disponible en: http://localhost:${PORT}/api-docs`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health`);
  console.log(`🌍 Ambiente: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app; 