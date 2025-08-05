const pool = require('../config/database');
const { validationResult } = require('express-validator');

// =====================
// VENTAS
// =====================

/**
 * @swagger
 * /api/sales:
 *   get:
 *     summary: Obtener lista de ventas
 *     description: Retorna una lista paginada de todas las ventas registradas
 *     tags: [Ventas]
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
 *     responses:
 *       200:
 *         description: Lista de ventas obtenida exitosamente
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
 *                       customer_name:
 *                         type: string
 *                       sale_date:
 *                         type: string
 *                         format: date
 *                       total_amount:
 *                         type: number
 *                       created_by:
 *                         type: integer
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
const getSales = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM sales');
    const total = countResult[0].total;
    const [sales] = await pool.query(
      `SELECT * FROM sales ORDER BY created_at DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );
    res.json({ success: true, data: sales, pagination: { page, limit, total, pages: Math.ceil(total/limit) } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener ventas', error });
  }
};

/**
 * @swagger
 * /api/sales/{id}:
 *   get:
 *     summary: Obtener venta por ID
 *     description: Retorna los detalles de una venta específica
 *     tags: [Ventas]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la venta
 *     responses:
 *       200:
 *         description: Venta encontrada exitosamente
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
 *                     customer_name:
 *                       type: string
 *                     sale_date:
 *                       type: string
 *                       format: date
 *                     total_amount:
 *                       type: number
 *       404:
 *         description: Venta no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const getSaleById = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query('SELECT * FROM sales WHERE id = ?', [id]);
    if (result.length === 0) return res.status(404).json({ success: false, message: 'Venta no encontrada' });
    res.json({ success: true, data: result[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener venta', error });
  }
};

/**
 * @swagger
 * /api/sales:
 *   post:
 *     summary: Crear nueva venta
 *     description: Crea una nueva venta en el sistema
 *     tags: [Ventas]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - customer_name
 *               - sale_date
 *               - total_amount
 *             properties:
 *               customer_name:
 *                 type: string
 *                 description: Nombre del cliente
 *                 example: "Cliente XYZ"
 *               sale_date:
 *                 type: string
 *                 format: date
 *                 description: Fecha de la venta
 *                 example: "2024-01-15"
 *               total_amount:
 *                 type: number
 *                 description: Monto total de la venta
 *                 example: 2500.00
 *     responses:
 *       201:
 *         description: Venta creada exitosamente
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
 *                     customer_name:
 *                       type: string
 *                     sale_date:
 *                       type: string
 *                     total_amount:
 *                       type: number
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error interno del servidor
 */
const createSale = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });
    const { customer_name, sale_date, total_amount } = req.body;
    const userId = req.user.id;
    const [result] = await pool.query(
      'INSERT INTO sales (customer_name, sale_date, total_amount, created_by) VALUES (?, ?, ?, ?)',
      [customer_name, sale_date, total_amount, userId]
    );
    res.status(201).json({ success: true, data: { id: result.insertId, customer_name, sale_date, total_amount } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al crear venta', error });
  }
};

/**
 * @swagger
 * /api/sales/{id}:
 *   put:
 *     summary: Actualizar venta
 *     description: Actualiza los datos de una venta existente
 *     tags: [Ventas]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la venta
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               customer_name:
 *                 type: string
 *                 description: Nombre del cliente
 *               sale_date:
 *                 type: string
 *                 format: date
 *                 description: Fecha de la venta
 *               total_amount:
 *                 type: number
 *                 description: Monto total de la venta
 *     responses:
 *       200:
 *         description: Venta actualizada exitosamente
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Venta no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const updateSale = async (req, res) => {
  try {
    const { id } = req.params;
    const { customer_name, sale_date, total_amount } = req.body;
    const userId = req.user.id;
    const [result] = await pool.query(
      'UPDATE sales SET customer_name=?, sale_date=?, total_amount=?, updated_by=?, updated_at=NOW() WHERE id=?',
      [customer_name, sale_date, total_amount, userId, id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Venta no encontrada' });
    res.json({ success: true, message: 'Venta actualizada' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al actualizar venta', error });
  }
};

/**
 * @swagger
 * /api/sales/{id}:
 *   delete:
 *     summary: Eliminar venta
 *     description: Elimina una venta del sistema
 *     tags: [Ventas]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la venta
 *     responses:
 *       200:
 *         description: Venta eliminada exitosamente
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Venta no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const deleteSale = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query('DELETE FROM sales WHERE id = ?', [id]);
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Venta no encontrada' });
    res.json({ success: true, message: 'Venta eliminada' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al eliminar venta', error });
  }
};

// =====================
// ITEMS DE VENTA
// =====================

/**
 * @swagger
 * /api/sales/{saleId}/items:
 *   get:
 *     summary: Obtener items de una venta
 *     description: Retorna todos los items asociados a una venta específica
 *     tags: [Items de Venta]
 *     parameters:
 *       - in: path
 *         name: saleId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la venta
 *     responses:
 *       200:
 *         description: Items de venta obtenidos exitosamente
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
 *                       sale_id:
 *                         type: integer
 *                       product_id:
 *                         type: integer
 *                       quantity:
 *                         type: integer
 *                       unit_price:
 *                         type: number
 *       500:
 *         description: Error interno del servidor
 */
const getSaleItems = async (req, res) => {
  try {
    const { saleId } = req.params;
    const [items] = await pool.query('SELECT * FROM sale_items WHERE sale_id = ?', [saleId]);
    res.json({ success: true, data: items });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener items de venta', error });
  }
};

/**
 * @swagger
 * /api/sales/{saleId}/items:
 *   post:
 *     summary: Agregar item a una venta
 *     description: Agrega un nuevo item a una venta existente
 *     tags: [Items de Venta]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: saleId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la venta
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - product_id
 *               - quantity
 *               - unit_price
 *             properties:
 *               product_id:
 *                 type: integer
 *                 description: ID del producto
 *                 example: 1
 *               quantity:
 *                 type: integer
 *                 description: Cantidad vendida
 *                 example: 5
 *               unit_price:
 *                 type: number
 *                 description: Precio unitario
 *                 example: 45.00
 *     responses:
 *       201:
 *         description: Item agregado exitosamente
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
 *                     sale_id:
 *                       type: integer
 *                     product_id:
 *                       type: integer
 *                     quantity:
 *                       type: integer
 *                     unit_price:
 *                       type: number
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error interno del servidor
 */
const addSaleItem = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    
    const { saleId } = req.params;
    const { product_id, quantity, unit_price } = req.body;
    
    // Validar que el producto existe y tiene stock suficiente
    const [productResult] = await connection.query(
      'SELECT id, name, stock_quantity FROM products WHERE id = ? AND status = true',
      [product_id]
    );
    
    if (productResult.length === 0) {
      await connection.rollback();
      return res.status(404).json({ 
        success: false, 
        message: 'Producto no encontrado o inactivo' 
      });
    }
    
    const product = productResult[0];
    const currentStock = product.stock_quantity;
    
    // Validar que hay suficiente stock
    if (currentStock < quantity) {
      await connection.rollback();
      return res.status(400).json({ 
        success: false, 
        message: `Stock insuficiente. Disponible: ${currentStock}, Solicitado: ${quantity}`,
        data: {
          available_stock: currentStock,
          requested_quantity: quantity,
          product_name: product.name
        }
      });
    }
    
    const newStock = currentStock - quantity;
    
    // Insertar el item de venta
    const [result] = await connection.query(
      'INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)',
      [saleId, product_id, quantity, unit_price]
    );
    
    // Actualizar el stock del producto
    await connection.query(
      'UPDATE products SET stock_quantity = ?, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [newStock, req.user.id, product_id]
    );
    
    // Registrar en el log de auditoría
    await connection.query(
      `INSERT INTO audit_logs (user_id, action, table_name, record_id, description) VALUES (?, ?, ?, ?, ?)`,
      [req.user.id, 'SALE_ITEM_ADDED', 'products', product_id, `Venta: -${quantity} unidades de ${product.name}. Stock anterior: ${currentStock}, Stock nuevo: ${newStock}`]
    );
    
    await connection.commit();
    
    res.status(201).json({ 
      success: true, 
      data: { 
        id: result.insertId, 
        sale_id: saleId, 
        product_id, 
        quantity, 
        unit_price,
        stock_updated: true,
        previous_stock: currentStock,
        new_stock: newStock
      } 
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error al agregar item de venta:', error);
    res.status(500).json({ success: false, message: 'Error al agregar item', error: error.message });
  } finally {
    connection.release();
  }
};

/**
 * @swagger
 * /api/sales/{saleId}/items/{itemId}:
 *   delete:
 *     summary: Eliminar item de una venta
 *     description: Elimina un item específico de una venta
 *     tags: [Items de Venta]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: saleId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la venta
 *       - in: path
 *         name: itemId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del item
 *     responses:
 *       200:
 *         description: Item eliminado exitosamente
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Item no encontrado
 *       500:
 *         description: Error interno del servidor
 */
const deleteSaleItem = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    
    const { saleId, itemId } = req.params;
    
    // Obtener información del item antes de eliminarlo
    const [itemResult] = await connection.query(
      'SELECT product_id, quantity FROM sale_items WHERE id = ? AND sale_id = ?',
      [itemId, saleId]
    );
    
    if (itemResult.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Item no encontrado' });
    }
    
    const item = itemResult[0];
    
    // Obtener información del producto
    const [productResult] = await connection.query(
      'SELECT id, name, stock_quantity FROM products WHERE id = ? AND status = true',
      [item.product_id]
    );
    
    if (productResult.length === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Producto no encontrado' });
    }
    
    const product = productResult[0];
    const currentStock = product.stock_quantity;
    const newStock = currentStock + item.quantity; // Revertir la cantidad vendida
    
    // Eliminar el item de venta
    const [deleteResult] = await connection.query(
      'DELETE FROM sale_items WHERE id = ? AND sale_id = ?', 
      [itemId, saleId]
    );
    
    if (deleteResult.affectedRows === 0) {
      await connection.rollback();
      return res.status(404).json({ success: false, message: 'Item no encontrado' });
    }
    
    // Actualizar el stock del producto
    await connection.query(
      'UPDATE products SET stock_quantity = ?, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [newStock, req.user.id, item.product_id]
    );
    
    // Registrar en el log de auditoría
    await connection.query(
      `INSERT INTO audit_logs (user_id, action, table_name, record_id, description) VALUES (?, ?, ?, ?, ?)`,
      [req.user.id, 'SALE_ITEM_DELETED', 'products', item.product_id, `Eliminación de venta: +${item.quantity} unidades de ${product.name}. Stock anterior: ${currentStock}, Stock nuevo: ${newStock}`]
    );
    
    await connection.commit();
    
    res.json({ 
      success: true, 
      message: 'Item eliminado',
      data: {
        stock_updated: true,
        previous_stock: currentStock,
        new_stock: newStock
      }
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error al eliminar item de venta:', error);
    res.status(500).json({ success: false, message: 'Error al eliminar item', error: error.message });
  } finally {
    connection.release();
  }
};

module.exports = {
  getSales,
  getSaleById,
  createSale,
  updateSale,
  deleteSale,
  getSaleItems,
  addSaleItem,
  deleteSaleItem
};