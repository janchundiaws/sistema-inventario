const express = require('express');
const router = express.Router();
const {
  getPurchases,
  getPurchaseById,
  createPurchase,
  updatePurchase,
  deletePurchase,
  getPurchaseItems,
  addPurchaseItem,
  deletePurchaseItem
} = require('../controllers/purchaseController');
const { authenticateToken } = require('../middleware/auth');
const { logAudit } = require('../middleware/audit');

// Compras
router.get('/', getPurchases);
router.get('/:id', getPurchaseById);
router.post('/', authenticateToken, logAudit, createPurchase);
router.put('/:id', authenticateToken, logAudit, updatePurchase);
router.delete('/:id', authenticateToken, logAudit, deletePurchase);

// Items de compra
router.get('/:purchaseId/items', getPurchaseItems);
router.post('/:purchaseId/items', authenticateToken, logAudit, addPurchaseItem);
router.delete('/:purchaseId/items/:itemId', authenticateToken, logAudit, deletePurchaseItem);

module.exports = router;