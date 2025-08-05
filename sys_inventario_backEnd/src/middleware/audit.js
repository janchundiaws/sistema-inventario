const pool = require('../config/database');

const logAudit = async (req, res, next) => {
  const originalSend = res.send;
  
  res.send = function(data) {
    // Solo registrar si la operación fue exitosa
    if (res.statusCode >= 200 && res.statusCode < 300) {
      const auditData = {
        user_id: req.user?.id,
        action: req.method,
        table_name: req.route?.path?.split('/')[1] || 'unknown',
        record_id: req.params.id || null,
        description: `${req.method} ${req.originalUrl}`,
        ip_address: req.ip,
        user_agent: req.get('User-Agent')
      };

      // Registrar de forma asíncrona para no afectar la respuesta
      pool.query(
        'INSERT INTO audit_logs (user_id, action, table_name, record_id, description, ip_address, user_agent) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [
          auditData.user_id,
          auditData.action,
          auditData.table_name,
          auditData.record_id,
          auditData.description,
          auditData.ip_address,
          auditData.user_agent
        ]
      ).catch(err => {
        console.error('Error al registrar auditoría:', err);
      });
    }
    
    originalSend.call(this, data);
  };
  
  next();
};

module.exports = { logAudit }; 