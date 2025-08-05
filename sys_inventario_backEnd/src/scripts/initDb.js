const pool = require('../config/database');

const initializeDatabase = async () => {
  try {
    console.log('🔄 Inicializando base de datos...');

    // Insertar roles
    const roles = [
      { name: 'admin', description: 'Administrador del sistema' },
      { name: 'user', description: 'Usuario estándar' },
      { name: 'manager', description: 'Gerente de inventario' }
    ];

    for (const role of roles) {
      await pool.query(
        'INSERT INTO roles (name, description) VALUES (?, ?) ON DUPLICATE KEY UPDATE name = name',
        [role.name, role.description]
      );
    }
    console.log('✅ Roles insertados');

    // Insertar categorías
    const categories = [
      { name: 'Electrónicos', description: 'Productos electrónicos y tecnología' },
      { name: 'Ropa', description: 'Vestimenta y accesorios' },
      { name: 'Hogar', description: 'Artículos para el hogar' },
      { name: 'Deportes', description: 'Equipos y ropa deportiva' },
      { name: 'Libros', description: 'Libros y material educativo' }
    ];

    for (const category of categories) {
      await pool.query(
        'INSERT INTO categories (name, description) VALUES (?, ?) ON DUPLICATE KEY UPDATE name = name',
        [category.name, category.description]
      );
    }
    console.log('✅ Categorías insertadas');

    // Insertar usuario administrador
    const bcrypt = require('bcryptjs');
    const adminPassword = await bcrypt.hash('admin123', 10);
    
    await pool.query(
      `INSERT INTO users (name, email, password_hash, role_id) 
       VALUES (?, ?, ?, ?) 
       ON DUPLICATE KEY UPDATE email = email`,
      ['Administrador', 'admin@inventario.com', adminPassword, 1]
    );
    console.log('✅ Usuario administrador creado (admin@inventario.com / admin123)');

    // Insertar productos de ejemplo
    const products = [
      {
        name: 'Laptop HP Pavilion',
        description: 'Laptop de 15 pulgadas con procesador Intel i5',
        sku: 'LAP001',
        category_id: 1,
        stock_quantity: 10,
        price: 899.99,
        cost: 650.00
      },
      {
        name: 'Camiseta Básica',
        description: 'Camiseta de algodón 100%',
        sku: 'CAM001',
        category_id: 2,
        stock_quantity: 50,
        price: 19.99,
        cost: 12.00
      },
      {
        name: 'Sofá de 3 Plazas',
        description: 'Sofá moderno para sala',
        sku: 'SOF001',
        category_id: 3,
        stock_quantity: 5,
        price: 599.99,
        cost: 400.00
      },
      {
        name: 'Balón de Fútbol',
        description: 'Balón oficial tamaño 5',
        sku: 'BAL001',
        category_id: 4,
        stock_quantity: 20,
        price: 29.99,
        cost: 18.00
      },
      {
        name: 'Libro de Programación',
        description: 'Guía completa de JavaScript',
        sku: 'LIB001',
        category_id: 5,
        stock_quantity: 15,
        price: 39.99,
        cost: 25.00
      }
    ];

    for (const product of products) {
      await pool.query(
        `INSERT INTO products (name, description, sku, category_id, stock_quantity, price, cost, created_by) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?) 
         ON DUPLICATE KEY UPDATE sku = sku`,
        [
          product.name,
          product.description,
          product.sku,
          product.category_id,
          product.stock_quantity,
          product.price,
          product.cost,
          1 // admin user
        ]
      );
    }
    console.log('✅ Productos de ejemplo insertados');

    console.log('🎉 Base de datos inicializada correctamente');
    console.log('\n📋 Credenciales de acceso:');
    console.log('   Email: admin@inventario.com');
    console.log('   Password: admin123');
    console.log('\n🔗 Endpoints disponibles:');
    console.log('   - API Docs: http://localhost:3000/api-docs');
    console.log('   - Health Check: http://localhost:3000/health');

  } catch (error) {
    console.error('❌ Error al inicializar la base de datos:', error);
  } finally {
    await pool.end();
  }
};

// Ejecutar si se llama directamente
if (require.main === module) {
  initializeDatabase();
}

module.exports = { initializeDatabase }; 