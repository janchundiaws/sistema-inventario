const express = require('express');
const router = express.Router();
const { 
  register, 
  login, 
  getProfile, 
  registerValidation, 
  loginValidation 
} = require('../controllers/authController');
const { authenticateToken } = require('../middleware/auth');

// Rutas públicas
router.post('/register', registerValidation, register);
router.post('/login', loginValidation, login);

// Rutas protegidas
router.get('/profile', authenticateToken, getProfile);

module.exports = router; 