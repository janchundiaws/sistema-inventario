const pool = require('../config/database');
const { validationResult } = require('express-validator');

// =====================
// COMPRAS
// =====================

/**
 * @swagger
 * /api/purchases:
 *   get:
 *     summary: Obtener lista de compras
 *     description: Retorna una lista paginada de todas las compras registradas
 *     tags: [Compras]
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
 *         description: Lista de compras obtenida exitosamente
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
 *                       supplier_name:
 *                         type: string
 *                       purchase_date:
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
const getPurchases = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;
    const [countResult] = await pool.query('SELECT COUNT(*) as total FROM purchases');
    const total = countResult[0].total;
    const [purchases] = await pool.query(
      `SELECT * FROM purchases ORDER BY created_at DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );
    res.json({ success: true, data: purchases, pagination: { page, limit, total, pages: Math.ceil(total/limit) } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener compras', error });
  }
};

/**
 * @swagger
 * /api/purchases/{id}:
 *   get:
 *     summary: Obtener compra por ID
 *     description: Retorna los detalles de una compra específica
 *     tags: [Compras]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la compra
 *     responses:
 *       200:
 *         description: Compra encontrada exitosamente
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
 *                     supplier_name:
 *                       type: string
 *                     purchase_date:
 *                       type: string
 *                       format: date
 *                     total_amount:
 *                       type: number
 *       404:
 *         description: Compra no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const getPurchaseById = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query('SELECT * FROM purchases WHERE id = ?', [id]);
    if (result.length === 0) return res.status(404).json({ success: false, message: 'Compra no encontrada' });
    res.json({ success: true, data: result[0] });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener compra', error });
  }
};

/**
 * @swagger
 * /api/purchases:
 *   post:
 *     summary: Crear nueva compra
 *     description: Crea una nueva compra en el sistema
 *     tags: [Compras]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - supplier_name
 *               - purchase_date
 *               - total_amount
 *             properties:
 *               supplier_name:
 *                 type: string
 *                 description: Nombre del proveedor
 *                 example: "Proveedor ABC"
 *               purchase_date:
 *                 type: string
 *                 format: date
 *                 description: Fecha de la compra
 *                 example: "2024-01-15"
 *               total_amount:
 *                 type: number
 *                 description: Monto total de la compra
 *                 example: 1500.00
 *     responses:
 *       201:
 *         description: Compra creada exitosamente
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
 *                     supplier_name:
 *                       type: string
 *                     purchase_date:
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
const createPurchase = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });
    const { supplier_name, purchase_date, total_amount } = req.body;
    const userId = req.user.id;
    const [result] = await pool.query(
      'INSERT INTO purchases (supplier_name, purchase_date, total_amount, created_by) VALUES (?, ?, ?, ?)',
      [supplier_name, purchase_date, total_amount, userId]
    );
    res.status(201).json({ success: true, data: { id: result.insertId, supplier_name, purchase_date, total_amount } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al crear compra', error });
  }
};

/**
 * @swagger
 * /api/purchases/{id}:
 *   put:
 *     summary: Actualizar compra
 *     description: Actualiza los datos de una compra existente
 *     tags: [Compras]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la compra
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               supplier_name:
 *                 type: string
 *                 description: Nombre del proveedor
 *               purchase_date:
 *                 type: string
 *                 format: date
 *                 description: Fecha de la compra
 *               total_amount:
 *                 type: number
 *                 description: Monto total de la compra
 *     responses:
 *       200:
 *         description: Compra actualizada exitosamente
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Compra no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const updatePurchase = async (req, res) => {
  try {
    const { id } = req.params;
    const { supplier_name, purchase_date, total_amount } = req.body;
    const userId = req.user.id;
    const [result] = await pool.query(
      'UPDATE purchases SET supplier_name=?, purchase_date=?, total_amount=?, updated_by=?, updated_at=NOW() WHERE id=?',
      [supplier_name, purchase_date, total_amount, userId, id]
    );
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Compra no encontrada' });
    res.json({ success: true, message: 'Compra actualizada' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al actualizar compra', error });
  }
};

/**
 * @swagger
 * /api/purchases/{id}:
 *   delete:
 *     summary: Eliminar compra
 *     description: Elimina una compra del sistema
 *     tags: [Compras]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la compra
 *     responses:
 *       200:
 *         description: Compra eliminada exitosamente
 *       401:
 *         description: No autorizado
 *       404:
 *         description: Compra no encontrada
 *       500:
 *         description: Error interno del servidor
 */
const deletePurchase = async (req, res) => {
  try {
    const { id } = req.params;
    const [result] = await pool.query('DELETE FROM purchases WHERE id = ?', [id]);
    if (result.affectedRows === 0) return res.status(404).json({ success: false, message: 'Compra no encontrada' });
    res.json({ success: true, message: 'Compra eliminada' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al eliminar compra', error });
  }
};

// =====================
// ITEMS DE COMPRA
// =====================

/**
 * @swagger
 * /api/purchases/{purchaseId}/items:
 *   get:
 *     summary: Obtener items de una compra
 *     description: Retorna todos los items asociados a una compra específica
 *     tags: [Items de Compra]
 *     parameters:
 *       - in: path
 *         name: purchaseId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la compra
 *     responses:
 *       200:
 *         description: Items de compra obtenidos exitosamente
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
 *                       purchase_id:
 *                         type: integer
 *                       product_id:
 *                         type: integer
 *                       quantity:
 *                         type: integer
 *                       unit_cost:
 *                         type: number
 *       500:
 *         description: Error interno del servidor
 */
const getPurchaseItems = async (req, res) => {
  try {
    const { purchaseId } = req.params;
    const [items] = await pool.query('SELECT * FROM purchase_items WHERE purchase_id = ?', [purchaseId]);
    res.json({ success: true, data: items });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Error al obtener items de compra', error });
  }
};

/**
 * @swagger
 * /api/purchases/{purchaseId}/items:
 *   post:
 *     summary: Agregar item a una compra
 *     description: Agrega un nuevo item a una compra existente
 *     tags: [Items de Compra]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: purchaseId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la compra
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - product_id
 *               - quantity
 *               - unit_cost
 *             properties:
 *               product_id:
 *                 type: integer
 *                 description: ID del producto
 *                 example: 1
 *               quantity:
 *                 type: integer
 *                 description: Cantidad comprada
 *                 example: 10
 *               unit_cost:
 *                 type: number
 *                 description: Costo unitario
 *                 example: 25.50
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
 *                     purchase_id:
 *                       type: integer
 *                     product_id:
 *                       type: integer
 *                     quantity:
 *                       type: integer
 *                     unit_cost:
 *                       type: number
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       500:
 *         description: Error interno del servidor
 */
const addPurchaseItem = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    
    const { purchaseId } = req.params;
    const { product_id, quantity, unit_cost } = req.body;
    
    // Validar que el producto existe
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
    const newStock = currentStock + quantity;
    
    // Insertar el item de compra
    const [result] = await connection.query(
      'INSERT INTO purchase_items (purchase_id, product_id, quantity, unit_cost) VALUES (?, ?, ?, ?)',
      [purchaseId, product_id, quantity, unit_cost]
    );
    
    // Actualizar el stock del producto
    await connection.query(
      'UPDATE products SET stock_quantity = ?, updated_by = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [newStock, req.user.id, product_id]
    );
    
    // Registrar en el log de auditoría
    await connection.query(
      `INSERT INTO audit_logs (user_id, action, table_name, record_id, description) VALUES (?, ?, ?, ?, ?)`,
      [req.user.id, 'PURCHASE_ITEM_ADDED', 'products', product_id, `Compra: +${quantity} unidades de ${product.name}. Stock anterior: ${currentStock}, Stock nuevo: ${newStock}`]
    );
    
    await connection.commit();
    
    res.status(201).json({ 
      success: true, 
      data: { 
        id: result.insertId, 
        purchase_id: purchaseId, 
        product_id, 
        quantity, 
        unit_cost,
        stock_updated: true,
        previous_stock: currentStock,
        new_stock: newStock
      } 
    });
  } catch (error) {
    await connection.rollback();
    console.error('Error al agregar item de compra:', error);
    res.status(500).json({ success: false, message: 'Error al agregar item', error: error.message });
  } finally {
    connection.release();
  }
};

/**
 * @swagger
 * /api/purchases/{purchaseId}/items/{itemId}:
 *   delete:
 *     summary: Eliminar item de una compra
 *     description: Elimina un item específico de una compra
 *     tags: [Items de Compra]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: purchaseId
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID de la compra
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
const deletePurchaseItem = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    
    const { purchaseId, itemId } = req.params;
    
    // Obtener información del item antes de eliminarlo
    const [itemResult] = await connection.query(
      'SELECT product_id, quantity FROM purchase_items WHERE id = ? AND purchase_id = ?',
      [itemId, purchaseId]
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
    const newStock = currentStock - item.quantity; // Revertir la cantidad agregada
    
    // Verificar que no quede stock negativo
    if (newStock < 0) {
      await connection.rollback();
      return res.status(400).json({ 
        success: false, 
        message: 'No se puede eliminar el item. El stock quedaría negativo.',
        data: {
          current_stock: currentStock,
          quantity_to_remove: item.quantity,
          would_result_in: newStock
        }
      });
    }
    
    // Eliminar el item de compra
    const [deleteResult] = await connection.query(
      'DELETE FROM purchase_items WHERE id = ? AND purchase_id = ?', 
      [itemId, purchaseId]
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
      [req.user.id, 'PURCHASE_ITEM_DELETED', 'products', item.product_id, `Eliminación de compra: -${item.quantity} unidades de ${product.name}. Stock anterior: ${currentStock}, Stock nuevo: ${newStock}`]
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
    console.error('Error al eliminar item de compra:', error);
    res.status(500).json({ success: false, message: 'Error al eliminar item', error: error.message });
  } finally {
    connection.release();
  }
};

module.exports = {
  getPurchases,
  getPurchaseById,
  createPurchase,
  updatePurchase,
  deletePurchase,
  getPurchaseItems,
  addPurchaseItem,
  deletePurchaseItem
};