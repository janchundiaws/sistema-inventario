const express = require('express');
const router = express.Router();
const { 
  getRoles, 
  getRoleById, 
  createRole 
} = require('../controllers/roleController');
const { authenticateToken } = require('../middleware/auth');

// Rutas públicas (para obtener roles en el formulario de registro)
router.get('/', getRoles);
router.get('/:id', getRoleById);

// Rutas protegidas (para crear roles)
router.post('/', authenticateToken, createRole);

module.exports = router; 