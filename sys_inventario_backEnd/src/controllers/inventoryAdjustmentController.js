const pool = require('../config/database');
const { body, validationResult } = require('express-validator');

/**
 * @swagger
 * components:
 *   schemas:
 *     InventoryAdjustment:
 *       type: object
 *       required:
 *         - product_id
 *         - adjustment_type
 *         - quantity
 *       properties:
 *         product_id:
 *           type: integer
 *           description: ID del producto
 *         adjustment_type:
 *           type: string
 *           enum: [ADD, REMOVE]
 *           description: Tipo de ajuste (agregar o remover)
 *         quantity:
 *           type: integer
 *           description: Cantidad a ajustar
 *         reason:
 *           type: string
 *           description: Razón del ajuste
 */

// Validaciones para ajustes de inventario
const adjustmentValidation = [
  body('product_id').isInt({ min: 1 }).withMessage('Product ID debe ser un número entero positivo'),
  body('adjustment_type').isIn(['ADD', 'REMOVE']).withMessage('Tipo de ajuste debe ser ADD o REMOVE'),
  body('quantity').isInt({ min: 1 }).withMessage('La cantidad debe ser un número entero positivo'),
  body('reason').optional().isString().withMessage('La razón debe ser una cadena de texto')
];

/**
 * @swagger
 * /api/inventory-adjustments:
 *   get:
 *     summary: Obtener historial de ajustes de inventario
 *     tags: [Ajustes de Inventario]
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Número de página
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Elementos por página
 *       - in: query
 *         name: product_id
 *         schema:
 *           type: integer
 *         description: Filtrar por producto
 *       - in: query
 *         name: adjustment_type
 *         schema:
 *           type: string
 *           enum: [ADD, REMOVE]
 *         description: Filtrar por tipo de ajuste
 *     responses:
 *       200:
 *         description: Lista de ajustes de inventario
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/InventoryAdjustment'
 *                 pagination:
 *                   type: object
 *                   properties:
 *                     page:
 *                       type: integer
 *                     limit:
 *                       type: integer
 *                     total:
 *                       type: integer
 *                     pages:
 *                       type: integer
 */
const getAdjustments = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const productId = req.query.product_id;
    const adjustmentType = req.query.adjustment_type;

    let whereClause = '';
    let params = [];

    if (productId) {
      whereClause += ' WHERE ia.product_id = ?';
      params.push(productId);
    }

    if (adjustmentType) {
      if (whereClause) {
        whereClause += ' AND ia.adjustment_type = ?';
      } else {
        whereClause += ' WHERE ia.adjustment_type = ?';
      }
      params.push(adjustmentType);
    }

    // Obtener total de registros
    const countQuery = `
      SELECT COUNT(*) 
      FROM inventory_adjustments ia
      ${whereClause}
    `;
    const [countResult] = await pool.query(countQuery, params);
    const total = parseInt(countResult[0]['COUNT(*)']);

    // Obtener ajustes
    const query = `
      SELECT ia.*, p.name as product_name, p.sku as product_sku, u.name as created_by_name
      FROM inventory_adjustments ia
      LEFT JOIN products p ON ia.product_id = p.id
      LEFT JOIN users u ON ia.created_by = u.id
      ${whereClause}
      ORDER BY ia.created_at DESC
      LIMIT ? OFFSET ?
    `;
    
    params.push(limit, offset);
    const [result] = await pool.query(query, params);

    const pages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: result,
      pagination: {
        page,
        limit,
        total,
        pages
      }
    });

  } catch (error) {
    console.error('Error al obtener ajustes de inventario:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

/**
 * @swagger
 * /api/inventory-adjustments:
 *   post:
 *     summary: Crear un nuevo ajuste de inventario
 *     tags: [Ajustes de Inventario]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/InventoryAdjustment'
 *     responses:
 *       201:
 *         description: Ajuste de inventario creado exitosamente
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
 *                   $ref: '#/components/schemas/InventoryAdjustment'
 *       400:
 *         description: Datos inválidos
 *       404:
 *         description: Producto no encontrado
 */
const createAdjustment = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Datos inválidos',
        errors: errors.array()
      });
    }

    const { product_id, adjustment_type, quantity, reason } = req.body;

    // Verificar si el producto existe
    const [productResult] = await pool.query(
      'SELECT id, name, stock_quantity FROM products WHERE id = ? AND status = true',
      [product_id]
    );

    if (productResult.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    const product = productResult[0];
    const currentStock = product.stock_quantity;
    let newStock;

    // Calcular nuevo stock
    if (adjustment_type === 'ADD') {
      newStock = currentStock + quantity;
    } else if (adjustment_type === 'REMOVE') {
      if (currentStock < quantity) {
        return res.status(400).json({
          success: false,
          message: 'Stock insuficiente para realizar el ajuste'
        });
      }
      newStock = currentStock - quantity;
    }

    // Iniciar transacción
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // Crear el registro de ajuste
      const [adjustmentResult] = await connection.query(
        `INSERT INTO inventory_adjustments (product_id, adjustment_type, quantity, reason, created_by)
         VALUES (?, ?, ?, ?, ?)`,
        [product_id, adjustment_type, quantity, reason, req.user.id]
      );

      // Actualizar el stock del producto
      await connection.query(
        'UPDATE products SET stock_quantity = ?, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
        [newStock, req.user.id, product_id]
      );

      // Registrar en el log de auditoría
      await connection.query(
        `INSERT INTO audit_logs (user_id, action, table_name, record_id, description)
         VALUES (?, ?, ?, ?, ?)`,
        [
          req.user.id,
          'INVENTORY_ADJUSTMENT',
          'products',
          product_id,
          `Ajuste de inventario: ${adjustment_type} ${quantity} unidades. Stock anterior: ${currentStock}, Stock nuevo: ${newStock}. Razón: ${reason || 'No especificada'}`
        ]
      );

      await connection.commit();

      // Obtener el ajuste creado
      const [newAdjustment] = await pool.query(
        `SELECT ia.*, p.name as product_name, p.sku as product_sku, u.name as created_by_name
         FROM inventory_adjustments ia
         LEFT JOIN products p ON ia.product_id = p.id
         LEFT JOIN users u ON ia.created_by = u.id
         WHERE ia.id = ?`,
        [adjustmentResult.insertId]
      );

      res.status(201).json({
        success: true,
        message: 'Ajuste de inventario creado exitosamente',
        data: newAdjustment[0]
      });

    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }

  } catch (error) {
    console.error('Error al crear ajuste de inventario:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

/**
 * @swagger
 * /api/inventory-adjustments/{id}:
 *   get:
 *     summary: Obtener un ajuste de inventario por ID
 *     tags: [Ajustes de Inventario]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del ajuste
 *     responses:
 *       200:
 *         description: Ajuste encontrado
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/InventoryAdjustment'
 *       404:
 *         description: Ajuste no encontrado
 */
const getAdjustmentById = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await pool.query(
      `SELECT ia.*, p.name as product_name, p.sku as product_sku, u.name as created_by_name
       FROM inventory_adjustments ia
       LEFT JOIN products p ON ia.product_id = p.id
       LEFT JOIN users u ON ia.created_by = u.id
       WHERE ia.id = ?`,
      [id]
    );

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Ajuste de inventario no encontrado'
      });
    }

    res.json({
      success: true,
      data: result[0]
    });

  } catch (error) {
    console.error('Error al obtener ajuste de inventario:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

/**
 * @swagger
 * /api/inventory-adjustments/product/{productId}:
 *   get:
 *     summary: Obtener historial de ajustes de un producto específico
 *     tags: [Ajustes de Inventario]
 *     parameters:
 *       - in: path
 *         name: productId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del producto
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Número de página
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Elementos por página
 *     responses:
 *       200:
 *         description: Historial de ajustes del producto
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/InventoryAdjustment'
 *                 pagination:
 *                   type: object
 *       404:
 *         description: Producto no encontrado
 */
const getAdjustmentsByProduct = async (req, res) => {
  try {
    const { productId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Verificar si el producto existe
    const [productResult] = await pool.query(
      'SELECT id, name, sku FROM products WHERE id = ?',
      [productId]
    );

    if (productResult.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    // Obtener total de registros
    const [countResult] = await pool.query(
      'SELECT COUNT(*) FROM inventory_adjustments WHERE product_id = ?',
      [productId]
    );
    const total = parseInt(countResult[0]['COUNT(*)']);

    // Obtener ajustes del producto
    const [result] = await pool.query(
      `SELECT ia.*, p.name as product_name, p.sku as product_sku, u.name as created_by_name
       FROM inventory_adjustments ia
       LEFT JOIN products p ON ia.product_id = p.id
       LEFT JOIN users u ON ia.created_by = u.id
       WHERE ia.product_id = ?
       ORDER BY ia.created_at DESC
       LIMIT ? OFFSET ?`,
      [productId, limit, offset]
    );

    const pages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: result,
      pagination: {
        page,
        limit,
        total,
        pages
      }
    });

  } catch (error) {
    console.error('Error al obtener ajustes del producto:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

module.exports = {
  getAdjustments,
  createAdjustment,
  getAdjustmentById,
  getAdjustmentsByProduct,
  adjustmentValidation
}; 