const express = require('express');
const router = express.Router();
const { 
  getProducts, 
  getProductById, 
  createProduct, 
  updateProduct, 
  deleteProduct, 
  productValidation 
} = require('../controllers/productController');
const { authenticateToken, requireRole } = require('../middleware/auth');
const { logAudit } = require('../middleware/audit');

// Rutas públicas (solo lectura)
router.get('/', getProducts);
router.get('/:id', getProductById);

// Rutas protegidas (requieren autenticación)
router.post('/', authenticateToken, logAudit, productValidation, createProduct);
router.put('/:id', authenticateToken, logAudit, productValidation, updateProduct);
router.delete('/:id', authenticateToken, logAudit, deleteProduct);

module.exports = router; 