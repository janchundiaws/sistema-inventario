const pool = require('../config/database');
const { body, validationResult } = require('express-validator');

/**
 * @swagger
 * components:
 *   schemas:
 *     Product:
 *       type: object
 *       required:
 *         - name
 *         - price
 *         - cost
 *       properties:
 *         name:
 *           type: string
 *           description: Nombre del producto
 *         description:
 *           type: string
 *           description: Descripción del producto
 *         sku:
 *           type: string
 *           description: Código SKU único
 *         category_id:
 *           type: integer
 *           description: ID de la categoría
 *         stock_quantity:
 *           type: integer
 *           description: Cantidad en stock
 *         price:
 *           type: number
 *           format: float
 *           description: Precio de venta
 *         cost:
 *           type: number
 *           format: float
 *           description: Costo del producto
 *         status:
 *           type: boolean
 *           description: Estado del producto
 */

// Validaciones para productos
const productValidation = [
  body('name').notEmpty().withMessage('El nombre es requerido'),
  body('price').isFloat({ min: 0 }).withMessage('El precio debe ser un número positivo'),
  body('cost').isFloat({ min: 0 }).withMessage('El costo debe ser un número positivo'),
  body('sku').optional().isString().withMessage('SKU debe ser una cadena de texto'),
  body('category_id').optional().isInt().withMessage('Category ID debe ser un número entero'),
  body('stock_quantity').optional().isInt({ min: 0 }).withMessage('Stock debe ser un número entero no negativo')
];

/**
 * @swagger
 * /api/products:
 *   get:
 *     summary: Obtener todos los productos
 *     tags: [Productos]
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
 *         name: search
 *         schema:
 *           type: string
 *         description: Término de búsqueda
 *       - in: query
 *         name: category_id
 *         schema:
 *           type: integer
 *         description: Filtrar por categoría
 *     responses:
 *       200:
 *         description: Lista de productos
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
 *                     $ref: '#/components/schemas/Product'
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
const getProducts = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const search = req.query.search || '';
    const categoryId = req.query.category_id;

    let whereClause = 'WHERE p.status = true';
    let params = [];
    let paramCount = 0;

    if (search) {
      paramCount++;
      whereClause += ` AND (LOWER(p.name) LIKE LOWER(?) OR LOWER(p.sku) LIKE LOWER(?))`;
      params.push(`%${search}%`, `%${search}%`);
    }

    if (categoryId) {
      paramCount++;
      whereClause += ` AND p.category_id = ?`;
      params.push(categoryId);
    }

    // Obtener total de registros
    const countQuery = `
      SELECT COUNT(*) 
      FROM products p 
      ${whereClause}
    `;
    const [countResult] = await pool.query(countQuery, params);
    const total = parseInt(countResult[0]['COUNT(*)']);

    // Obtener productos
    const query = `
      SELECT p.*, c.name as category_name, u.name as created_by_name
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN users u ON p.created_by = u.id
      ${whereClause}
      ORDER BY p.created_at DESC
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
    console.error('Error al obtener productos:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

/**
 * @swagger
 * /api/products/{id}:
 *   get:
 *     summary: Obtener un producto por ID
 *     tags: [Productos]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del producto
 *     responses:
 *       200:
 *         description: Producto encontrado
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/Product'
 *       404:
 *         description: Producto no encontrado
 */
const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await pool.query(
      `SELECT p.*, c.name as category_name, u.name as created_by_name
       FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       LEFT JOIN users u ON p.created_by = u.id
       WHERE p.id = ?`,
      [id]
    );

    if (result.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    res.json({
      success: true,
      data: result[0]
    });

  } catch (error) {
    console.error('Error al obtener producto:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

/**
 * @swagger
 * /api/products:
 *   post:
 *     summary: Crear un nuevo producto
 *     tags: [Productos]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Product'
 *     responses:
 *       201:
 *         description: Producto creado exitosamente
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
 *                   $ref: '#/components/schemas/Product'
 *       400:
 *         description: Datos inválidos
 */
const createProduct = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Datos inválidos',
        errors: errors.array()
      });
    }

    const { name, description, sku, category_id, stock_quantity, price, cost } = req.body;

    // Verificar si el SKU ya existe
    if (sku) {
      const [existingSku] = await pool.query(
        'SELECT id FROM products WHERE sku = ?',
        [sku]
      );

      if (existingSku.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'El SKU ya existe'
        });
      }
    }

    const [result] = await pool.query(
      `INSERT INTO products (name, description, sku, category_id, stock_quantity, price, cost, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, description, sku, category_id, stock_quantity || 0, price, cost, req.user.id]
    );

    // Obtener el producto creado
    const [productResult] = await pool.query(
      'SELECT * FROM products WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Producto creado exitosamente',
      data: productResult[0]
    });

  } catch (error) {
    console.error('Error al crear producto:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

/**
 * @swagger
 * /api/products/{id}:
 *   put:
 *     summary: Actualizar un producto
 *     tags: [Productos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del producto
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Product'
 *     responses:
 *       200:
 *         description: Producto actualizado exitosamente
 *       404:
 *         description: Producto no encontrado
 */
const updateProduct = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Datos inválidos',
        errors: errors.array()
      });
    }

    const { id } = req.params;
    const { name, description, sku, category_id, stock_quantity, price, cost, status } = req.body;

    // Verificar si el producto existe
    const [existingProduct] = await pool.query(
      'SELECT id FROM products WHERE id = ?',
      [id]
    );

    if (existingProduct.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    // Verificar si el SKU ya existe (excluyendo el producto actual)
    if (sku) {
      const [existingSku] = await pool.query(
        'SELECT id FROM products WHERE sku = ? AND id != ?',
        [sku, id]
      );

      if (existingSku.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'El SKU ya existe'
        });
      }
    }

    await pool.query(
      `UPDATE products 
       SET name = ?, description = ?, sku = ?, category_id = ?, 
           stock_quantity = ?, price = ?, cost = ?, status = ?, 
           updated_by = ?, updated_at = CURRENT_TIMESTAMP
       WHERE id = ?`,
      [name, description, sku, category_id, stock_quantity, price, cost, status, req.user.id, id]
    );

    // Obtener el producto actualizado
    const [productResult] = await pool.query(
      'SELECT * FROM products WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Producto actualizado exitosamente',
      data: productResult[0]
    });

  } catch (error) {
    console.error('Error al actualizar producto:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

/**
 * @swagger
 * /api/products/{id}:
 *   delete:
 *     summary: Eliminar un producto (cambiar estado a inactivo)
 *     tags: [Productos]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del producto
 *     responses:
 *       200:
 *         description: Producto eliminado exitosamente
 *       404:
 *         description: Producto no encontrado
 */
const deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const [result] = await pool.query(
      'UPDATE products SET status = false, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [req.user.id, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }

    res.json({
      success: true,
      message: 'Producto eliminado exitosamente'
    });

  } catch (error) {
    console.error('Error al eliminar producto:', error);
    res.status(500).json({
      success: false,
      message: 'Error interno del servidor'
    });
  }
};

module.exports = {
  getProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
  productValidation
}; 