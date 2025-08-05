const { validationResult } = require('express-validator');
const pool = require('../config/database');

/**
 * Obtiene reporte de productos vendidos y comprados por rango de fechas
 * @route GET /api/reports/product-movement
 * @access Private
 */
const getProductMovementReport = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        success: false, 
        message: 'Datos inválidos', 
        errors: errors.array() 
      });
    }

    const { start_date, end_date, product_id } = req.query;
    
    // Construir la consulta base
    let whereClause = '';
    let params = [];
    
    if (start_date && end_date) {
      whereClause = 'WHERE p.purchase_date BETWEEN ? AND ? OR s.sale_date BETWEEN ? AND ?';
      params = [start_date, end_date, start_date, end_date];
    } else if (start_date) {
      whereClause = 'WHERE p.purchase_date >= ? OR s.sale_date >= ?';
      params = [start_date, start_date];
    } else if (end_date) {
      whereClause = 'WHERE p.purchase_date <= ? OR s.sale_date <= ?';
      params = [end_date, end_date];
    }

    // Si se especifica un producto específico
    if (product_id) {
      if (whereClause) {
        whereClause += ' AND (prod.id = ?)';
      } else {
        whereClause = 'WHERE prod.id = ?';
      }
      params.push(product_id);
    }

    // Consulta para productos comprados
    const purchasesQuery = `
      SELECT 
        'PURCHASE' as movement_type,
        p.id as transaction_id,
        p.purchase_date as transaction_date,
        p.supplier_name,
        prod.id as product_id,
        prod.name as product_name,
        prod.sku as product_sku,
        c.name as category_name,
        pi.quantity,
        pi.unit_cost,
        pi.subtotal,
        u.name as created_by_name,
        p.created_at
      FROM purchases p
      INNER JOIN purchase_items pi ON p.id = pi.purchase_id
      INNER JOIN products prod ON pi.product_id = prod.id
      LEFT JOIN categories c ON prod.category_id = c.id
      LEFT JOIN users u ON p.created_by = u.id
      ${whereClause.replace('s.sale_date', 'p.purchase_date').replace('OR s.sale_date', '')}
    `;

    // Consulta para productos vendidos
    const salesQuery = `
      SELECT 
        'SALE' as movement_type,
        s.id as transaction_id,
        s.sale_date as transaction_date,
        s.customer_name,
        prod.id as product_id,
        prod.name as product_name,
        prod.sku as product_sku,
        c.name as category_name,
        si.quantity,
        si.unit_price,
        si.subtotal,
        u.name as created_by_name,
        s.created_at
      FROM sales s
      INNER JOIN sale_items si ON s.id = si.sale_id
      INNER JOIN products prod ON si.product_id = prod.id
      LEFT JOIN categories c ON prod.category_id = c.id
      LEFT JOIN users u ON s.created_by = u.id
      ${whereClause.replace('p.purchase_date', 's.sale_date').replace('OR p.purchase_date', '')}
    `;

    // Ejecutar ambas consultas
    const [purchases] = await pool.query(purchasesQuery, params);
    const [sales] = await pool.query(salesQuery, params);

    // Combinar y ordenar resultados
    const allMovements = [...purchases, ...sales].sort((a, b) => 
      new Date(a.transaction_date) - new Date(b.transaction_date)
    );

    // Calcular totales
    const totals = {
      total_purchases: purchases.reduce((sum, item) => sum + parseFloat(item.subtotal), 0),
      total_sales: sales.reduce((sum, item) => sum + parseFloat(item.subtotal), 0),
      total_purchase_quantity: purchases.reduce((sum, item) => sum + item.quantity, 0),
      total_sale_quantity: sales.reduce((sum, item) => sum + item.quantity, 0),
      total_movements: allMovements.length
    };

    // Agrupar por producto para resumen
    const productSummary = {};
    
    purchases.forEach(item => {
      if (!productSummary[item.product_id]) {
        productSummary[item.product_id] = {
          product_id: item.product_id,
          product_name: item.product_name,
          product_sku: item.product_sku,
          category_name: item.category_name,
          total_purchased: 0,
          total_sold: 0,
          total_purchase_amount: 0,
          total_sale_amount: 0
        };
      }
      productSummary[item.product_id].total_purchased += item.quantity;
      productSummary[item.product_id].total_purchase_amount += parseFloat(item.subtotal);
    });

    sales.forEach(item => {
      if (!productSummary[item.product_id]) {
        productSummary[item.product_id] = {
          product_id: item.product_id,
          product_name: item.product_name,
          product_sku: item.product_sku,
          category_name: item.category_name,
          total_purchased: 0,
          total_sold: 0,
          total_purchase_amount: 0,
          total_sale_amount: 0
        };
      }
      productSummary[item.product_id].total_sold += item.quantity;
      productSummary[item.product_id].total_sale_amount += parseFloat(item.subtotal);
    });

    const productSummaryArray = Object.values(productSummary);

    res.json({
      success: true,
      message: 'Reporte generado exitosamente',
      data: {
        movements: allMovements,
        summary: {
          totals,
          products: productSummaryArray
        },
        filters: {
          start_date: start_date || null,
          end_date: end_date || null,
          product_id: product_id || null
        }
      }
    });

  } catch (error) {
    console.error('Error al generar reporte de movimiento de productos:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error interno del servidor' 
    });
  }
};

/**
 * Obtiene reporte resumido de productos por categoría
 * @route GET /api/reports/category-summary
 * @access Private
 */
const getCategorySummaryReport = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        success: false, 
        message: 'Datos inválidos', 
        errors: errors.array() 
      });
    }

    const { start_date, end_date } = req.query;
    
    let whereClause = '';
    let params = [];
    
    if (start_date && end_date) {
      whereClause = 'WHERE p.purchase_date BETWEEN ? AND ? OR s.sale_date BETWEEN ? AND ?';
      params = [start_date, end_date, start_date, end_date];
    } else if (start_date) {
      whereClause = 'WHERE p.purchase_date >= ? OR s.sale_date >= ?';
      params = [start_date, start_date];
    } else if (end_date) {
      whereClause = 'WHERE p.purchase_date <= ? OR s.sale_date <= ?';
      params = [end_date, end_date];
    }

    const query = `
      SELECT 
        c.id as category_id,
        c.name as category_name,
        COUNT(DISTINCT CASE WHEN p.id IS NOT NULL THEN p.id END) as total_purchases,
        COUNT(DISTINCT CASE WHEN s.id IS NOT NULL THEN s.id END) as total_sales,
        COALESCE(SUM(CASE WHEN p.id IS NOT NULL THEN pi.quantity ELSE 0 END), 0) as total_purchase_quantity,
        COALESCE(SUM(CASE WHEN s.id IS NOT NULL THEN si.quantity ELSE 0 END), 0) as total_sale_quantity,
        COALESCE(SUM(CASE WHEN p.id IS NOT NULL THEN pi.subtotal ELSE 0 END), 0) as total_purchase_amount,
        COALESCE(SUM(CASE WHEN s.id IS NOT NULL THEN si.subtotal ELSE 0 END), 0) as total_sale_amount
      FROM categories c
      LEFT JOIN products prod ON c.id = prod.category_id
      LEFT JOIN purchase_items pi ON prod.id = pi.product_id
      LEFT JOIN purchases p ON pi.purchase_id = p.id ${whereClause.includes('p.purchase_date') ? 'AND ' + whereClause.split('OR')[0].replace('WHERE ', '') : ''}
      LEFT JOIN sale_items si ON prod.id = si.product_id
      LEFT JOIN sales s ON si.sale_id = s.id ${whereClause.includes('s.sale_date') ? 'AND ' + whereClause.split('OR')[1] : ''}
      GROUP BY c.id, c.name
      ORDER BY total_sale_amount DESC
    `;

    const [results] = await pool.query(query, params);

    // Calcular totales generales
    const totals = results.reduce((acc, item) => {
      acc.total_purchase_quantity += item.total_purchase_quantity;
      acc.total_sale_quantity += item.total_sale_quantity;
      acc.total_purchase_amount += parseFloat(item.total_purchase_amount);
      acc.total_sale_amount += parseFloat(item.total_sale_amount);
      acc.total_purchases += item.total_purchases;
      acc.total_sales += item.total_sales;
      return acc;
    }, {
      total_purchase_quantity: 0,
      total_sale_quantity: 0,
      total_purchase_amount: 0,
      total_sale_amount: 0,
      total_purchases: 0,
      total_sales: 0
    });

    res.json({
      success: true,
      message: 'Reporte por categorías generado exitosamente',
      data: {
        categories: results,
        totals,
        filters: {
          start_date: start_date || null,
          end_date: end_date || null
        }
      }
    });

  } catch (error) {
    console.error('Error al generar reporte por categorías:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error interno del servidor' 
    });
  }
};

module.exports = {
  getProductMovementReport,
  getCategorySummaryReport
}; 