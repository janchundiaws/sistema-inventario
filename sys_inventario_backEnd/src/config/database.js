const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 3306,
  database: process.env.DB_NAME || 'sys_inventario',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD,
  waitForConnections: true,
  connectionLimit: 20,
  queueLimit: 0,
  acquireTimeout: 60000,
  timeout: 60000,
  reconnect: true
});

// Verificar conexión
pool.getConnection()
  .then(connection => {
    console.log('✅ Conectado a MySQL');
    connection.release();
  })
  .catch(err => {
    console.error('❌ Error en la conexión de MySQL:', err);
  });

module.exports = pool; 