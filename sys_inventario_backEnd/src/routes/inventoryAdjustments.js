const express = require('express');
const router = express.Router();
const {
  getAdjustments,
  createAdjustment,
  getAdjustmentById,
  getAdjustmentsByProduct,
  adjustmentValidation
} = require('../controllers/inventoryAdjustmentController');
const { authenticateToken } = require('../middleware/auth');

// Rutas para ajustes de inventario
// GET /api/inventory-adjustments - Obtener historial de ajustes
router.get('/', authenticateToken, getAdjustments);

// POST /api/inventory-adjustments - Crear nuevo ajuste
router.post('/', authenticateToken, adjustmentValidation, createAdjustment);

// GET /api/inventory-adjustments/:id - Obtener ajuste por ID
router.get('/:id', authenticateToken, getAdjustmentById);

// GET /api/inventory-adjustments/product/:productId - Obtener ajustes de un producto específico
router.get('/product/:productId', authenticateToken, getAdjustmentsByProduct);

module.exports = router; 