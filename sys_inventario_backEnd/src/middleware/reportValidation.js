const { query } = require('express-validator');

/**
 * Validaciones para reportes de movimiento de productos
 */
const reportValidation = [
  query('start_date')
    .optional()
    .isISO8601()
    .withMessage('La fecha de inicio debe tener formato válido (YYYY-MM-DD)'),
  
  query('end_date')
    .optional()
    .isISO8601()
    .withMessage('La fecha de fin debe tener formato válido (YYYY-MM-DD)')
    .custom((endDate, { req }) => {
      if (req.query.start_date && endDate) {
        const startDate = new Date(req.query.start_date);
        const endDateObj = new Date(endDate);
        if (endDateObj < startDate) {
          throw new Error('La fecha de fin no puede ser anterior a la fecha de inicio');
        }
      }
      return true;
    }),
  
  query('product_id')
    .optional()
    .isInt({ min: 1 })
    .withMessage('El ID del producto debe ser un número entero positivo')
];

module.exports = {
  reportValidation
}; 