const pool = require('../config/database');
const { validationResult } = require('express-validator');

/**
 * @swagger
 * /api/categories:
 *   get:
 *     summary: Obtener lista de categorías
 *     description: Retorna una lista paginada de todas las categorías registradas
 *     tags: [Categorías]
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
 *         description: Número de elementos por página
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Término de búsqueda por nombre
 *     responses:
 *       200:
 *         description: Lista de categorías obtenida exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       description:
 *                         type: string
 *                       created_at:
 *                         type: string
 *                         format: date-time
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
 *       500:
 *         description: Error interno del servidor
 */
const getCategories = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    const offset = (page - 1) * limit;

    let whereClause = '';
    let params = [];

    if (search) {
      whereClause = 'WHERE name LIKE ? OR description LIKE ?';
      params = [`%${search}%`, `%${search}%`];
    }

    // Obtener total de registros
    const countQuery = `SELECT COUNT(*) as total FROM categories ${whereClause}`;
    const [countResult] = await pool.query(countQuery, params);
    const total = countResult[0].total;

    // Obtener categorías
    const query = `
      SELECT * FROM categories 
      ${whereClause}
      ORDER BY name ASC 
      LIMIT ? OFFSET ?
    `;
    params.push(limit, offset);
    const [categories] = await pool.query(query, params);

    const pages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: categories,
      pagination: {
        page,
        limit,
        total,
        pages
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener categorías', error });
  }
};

/**
 * @swagger
 * /api/categories/{id}:
 *   get:
 *     summary: Obtener categoría por ID
 *     description: Retorna los detalles de una categoría específica
 *     tags: [Categorías]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la categoría
 *     responses:
 *       200:
 *         description: Categoría encontrada exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     name:
 *                       type: string
 *                     description:
 *                       type: string
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *       404:
 *         description: Categoría no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const getCategoryById = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query(
      `SELECT c.*, COUNT(p.id) as product_count
       FROM categories c
       LEFT JOIN products p ON c.id = p.category_id
       WHERE c.id = ?
       GROUP BY c.id`,
      [id]
    );

    if (result.length === 0) {
      return res.status(404).json({ success: false, message: 'Categoría no encontrada' });
    }

    res.json({ success: true, data: result[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener categoría', error });
  }
};

/**
 * @swagger
 * /api/categories:
 *   post:
 *     summary: Crear nueva categoría
 *     description: Crea una nueva categoría en el sistema
 *     tags: [Categorías]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: Nombre de la categoría
 *                 example: "Electrónicos"
 *               description:
 *                 type: string
 *                 description: Descripción de la categoría
 *                 example: "Productos electrónicos y tecnología"
 *     responses:
 *       201:
 *         description: Categoría creada exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     name:
 *                       type: string
 *                     description:
 *                       type: string
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       409:
 *         description: La categoría ya existe
 *       500:
 *         description: Error interno del servidor
 */
const createCategory = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ success: false, errors: errors.array() });
    }

    const { name, description } = req.body;

    // Verificar si la categoría ya existe
    const [existingCategory] = await pool.query(
      'SELECT id FROM categories WHERE name = ?',
      [name]
    );

    if (existingCategory.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Ya existe una categoría con ese nombre'
      });
    }

    // Crear categoría
    const [result] = await pool.query(
      'INSERT INTO categories (name, description) VALUES (?, ?)',
      [name, description]
    );

    // Obtener la categoría creada
    const [categoryResult] = await pool.query(
      'SELECT * FROM categories WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Categoría creada exitosamente',
      data: categoryResult[0]
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al crear categoría', error });
  }
};

/**
 * @swagger
 * /api/categories/{id}:
 *   put:
 *     summary: Actualizar categoría
 *     description: Actualiza los datos de una categoría existente
 *     tags: [Categorías]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la categoría
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *                 description: Nombre de la categoría
 *               description:
 *                 type: string
 *                 description: Descripción de la categoría
 *     responses:
 *       200:
 *         description: Categoría actualizada exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                     name:
 *                       type: string
 *                     description:
 *                       type: string
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Categoría no encontrada
 *       409:
 *         description: Ya existe una categoría con ese nombre
 *       500:
 *         description: Error interno del servidor
 */
const updateCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description } = req.body;

    // Verificar si la categoría existe
    const [existingCategory] = await pool.query(
      'SELECT id FROM categories WHERE id = ?',
      [id]
    );

    if (existingCategory.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Categoría no encontrada'
      });
    }

    // Verificar si el nuevo nombre ya existe (excluyendo la categoría actual)
    if (name) {
      const [duplicateName] = await pool.query(
        'SELECT id FROM categories WHERE name = ? AND id != ?',
        [name, id]
      );

      if (duplicateName.length > 0) {
        return res.status(409).json({
          success: false,
          message: 'Ya existe una categoría con ese nombre'
        });
      }
    }

    // Actualizar categoría
    await pool.query(
      'UPDATE categories SET name = ?, description = ? WHERE id = ?',
      [name, description, id]
    );

    // Obtener la categoría actualizada
    const [categoryResult] = await pool.query(
      'SELECT * FROM categories WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Categoría actualizada exitosamente',
      data: categoryResult[0]
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al actualizar categoría', error });
  }
};

/**
 * @swagger
 * /api/categories/{id}:
 *   delete:
 *     summary: Eliminar categoría
 *     description: Elimina una categoría del sistema (solo si no tiene productos asociados)
 *     tags: [Categorías]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la categoría
 *     responses:
 *       200:
 *         description: Categoría eliminada exitosamente
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Categoría no encontrada
 *       409:
 *         description: No se puede eliminar la categoría porque tiene productos asociados
 *       500:
 *         description: Error interno del servidor
 */
const deleteCategory = async (req, res) => {
  try {
    const { id } = req.params;

    // Verificar si la categoría existe
    const [existingCategory] = await pool.query(
      'SELECT id FROM categories WHERE id = ?',
      [id]
    );

    if (existingCategory.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Categoría no encontrada'
      });
    }

    // Verificar si hay productos asociados
    const [productsCount] = await pool.query(
      'SELECT COUNT(*) as count FROM products WHERE category_id = ?',
      [id]
    );

    if (productsCount[0].count > 0) {
      return res.status(409).json({
        success: false,
        message: 'No se puede eliminar la categoría porque tiene productos asociados'
      });
    }

    // Eliminar categoría
    const [result] = await pool.query(
      'DELETE FROM categories WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Categoría no encontrada'
      });
    }

    res.json({
      success: true,
      message: 'Categoría eliminada exitosamente'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al eliminar categoría', error });
  }
};

/**
 * @swagger
 * /api/categories/{id}/products:
 *   get:
 *     summary: Obtener productos de una categoría
 *     description: Retorna todos los productos asociados a una categoría específica
 *     tags: [Categorías]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la categoría
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
 *         description: Número de elementos por página
 *     responses:
 *       200:
 *         description: Productos de la categoría obtenidos exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                       name:
 *                         type: string
 *                       sku:
 *                         type: string
 *                       stock_quantity:
 *                         type: integer
 *                       price:
 *                         type: number
 *       404:
 *         description: Categoría no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const getCategoryProducts = async (req, res) => {
  try {
    const { id } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    // Verificar si la categoría existe
    const [categoryExists] = await pool.query(
      'SELECT id FROM categories WHERE id = ?',
      [id]
    );

    if (categoryExists.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Categoría no encontrada'
      });
    }

    // Obtener total de productos
    const [countResult] = await pool.query(
      'SELECT COUNT(*) as total FROM products WHERE category_id = ?',
      [id]
    );
    const total = countResult[0].total;

    // Obtener productos
    const [products] = await pool.query(
      `SELECT id, name, sku, stock_quantity, price, status, created_at
       FROM products 
       WHERE category_id = ? 
       ORDER BY name ASC 
       LIMIT ? OFFSET ?`,
      [id, limit, offset]
    );

    const pages = Math.ceil(total / limit);

    res.json({
      success: true,
      data: products,
      pagination: {
        page,
        limit,
        total,
        pages
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener productos de la categoría', error });
  }
};

module.exports = {
  getCategories,
  getCategoryById,
  createCategory,
  updateCategory,
  deleteCategory,
  getCategoryProducts
}; 