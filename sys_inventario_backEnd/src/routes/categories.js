const express = require('express');
const router = express.Router();
const {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  getCategoryProducts
} = require('../controllers/categoryController');
const { authenticateToken } = require('../middleware/auth');
const { logAudit } = require('../middleware/audit');

// Categorías
router.get('/', getCategories);
router.get('/:id', getCategoryById);
router.post('/', authenticateToken, logAudit, createCategory);
router.put('/:id', authenticateToken, logAudit, updateCategory);
router.delete('/:id', authenticateToken, logAudit, deleteCategory);

// Productos de una categoría
router.get('/:id/products', getCategoryProducts);

module.exports = router; 