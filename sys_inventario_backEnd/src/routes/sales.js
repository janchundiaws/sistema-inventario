const express = require('express');
const router = express.Router();
const {
  getSales,
  getSaleById,
  createSale,
  updateSale,
  deleteSale,
  getSaleItems,
  addSaleItem,
  deleteSaleItem
} = require('../controllers/saleController');
const { authenticateToken } = require('../middleware/auth');
const { logAudit } = require('../middleware/audit');

// Ventas
router.get('/', getSales);
router.get('/:id', getSaleById);
router.post('/', authenticateToken, logAudit, createSale);
router.put('/:id', authenticateToken, logAudit, updateSale);
router.delete('/:id', authenticateToken, logAudit, deleteSale);

// Items de venta
router.get('/:saleId/items', getSaleItems);
router.post('/:saleId/items', authenticateToken, logAudit, addSaleItem);
router.delete('/:saleId/items/:itemId', authenticateToken, logAudit, deleteSaleItem);

module.exports = router;