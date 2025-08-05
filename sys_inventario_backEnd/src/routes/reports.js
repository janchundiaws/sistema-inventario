const express = require('express');
const router = express.Router();
const {
  getProductMovementReport,
  getCategorySummaryReport
} = require('../controllers/reportController');
const { reportValidation } = require('../middleware/reportValidation');
const { authenticateToken } = require('../middleware/auth');

/**
 * @swagger
 * /api/reports/product-movement:
 *   get:
 *     summary: Obtiene reporte de productos vendidos y comprados por rango de fechas
 *     tags: [Reports]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: start_date
 *         schema:
 *           type: string
 *           format: date
 *         description: Fecha de inicio (YYYY-MM-DD)
 *       - in: query
 *         name: end_date
 *         schema:
 *           type: string
 *           format: date
 *         description: Fecha de fin (YYYY-MM-DD)
 *       - in: query
 *         name: product_id
 *         schema:
 *           type: integer
 *         description: ID del producto específico (opcional)
 *     responses:
 *       200:
 *         description: Reporte generado exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     movements:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           movement_type:
 *                             type: string
 *                             enum: [PURCHASE, SALE]
 *                           transaction_id:
 *                             type: integer
 *                           transaction_date:
 *                             type: string
 *                             format: date
 *                           product_name:
 *                             type: string
 *                           quantity:
 *                             type: integer
 *                           subtotal:
 *                             type: number
 *                     summary:
 *                       type: object
 *                       properties:
 *                         totals:
 *                           type: object
 *                         products:
 *                           type: array
 *       400:
 *         description: Datos inválidos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error interno del servidor
 */
router.get('/product-movement', authenticateToken, reportValidation, getProductMovementReport);

/**
 * @swagger
 * /api/reports/category-summary:
 *   get:
 *     summary: Obtiene reporte resumido de productos por categoría
 *     tags: [Reports]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: start_date
 *         schema:
 *           type: string
 *           format: date
 *         description: Fecha de inicio (YYYY-MM-DD)
 *       - in: query
 *         name: end_date
 *         schema:
 *           type: string
 *           format: date
 *         description: Fecha de fin (YYYY-MM-DD)
 *     responses:
 *       200:
 *         description: Reporte por categorías generado exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     categories:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           category_id:
 *                             type: integer
 *                           category_name:
 *                             type: string
 *                           total_purchases:
 *                             type: integer
 *                           total_sales:
 *                             type: integer
 *                           total_purchase_quantity:
 *                             type: integer
 *                           total_sale_quantity:
 *                             type: integer
 *                           total_purchase_amount:
 *                             type: number
 *                           total_sale_amount:
 *                             type: number
 *                     totals:
 *                       type: object
 *       400:
 *         description: Datos inválidos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error interno del servidor
 */
router.get('/category-summary', authenticateToken, reportValidation, getCategorySummaryReport);

module.exports = router; 