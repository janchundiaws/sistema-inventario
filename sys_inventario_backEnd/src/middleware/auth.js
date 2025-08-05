const jwt = require('jsonwebtoken');
const pool = require('../config/database');

const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ 
      success: false, 
      message: 'Token de acceso requerido' 
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Verificar que el usuario existe y está activo
    const [result] = await pool.query(
      'SELECT id, name, email, role_id, status FROM users WHERE id = ? AND status = true',
      [decoded.userId]
    );

    if (result.length === 0) {
      return res.status(401).json({ 
        success: false, 
        message: 'Usuario no encontrado o inactivo' 
      });
    }

    req.user = result[0];
    next();
  } catch (error) {
    return res.status(403).json({ 
      success: false, 
      message: 'Token inválido' 
    });
  }
};

const requireRole = (roles) => {
  return async (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Autenticación requerida' 
      });
    }

    // Obtener el rol del usuario
    const [result] = await pool.query(
      'SELECT name FROM roles WHERE id = ?',
      [req.user.role_id]
    );

    if (result.length === 0) {
      return res.status(403).json({ 
        success: false, 
        message: 'Rol no encontrado' 
      });
    }

    const userRole = result[0].name;
    
    if (!roles.includes(userRole)) {
      return res.status(403).json({ 
        success: false, 
        message: 'Permisos insuficientes' 
      });
    }

    next();
  };
};

module.exports = { authenticateToken, requireRole }; 