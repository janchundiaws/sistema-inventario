const pool = require('../config/database');

/**
 * @swagger
 * /api/roles:
 *   get:
 *     summary: Obtener lista de roles
 *     description: Retorna una lista de todos los roles disponibles en el sistema
 *     tags: [Roles]
 *     responses:
 *       200:
 *         description: Lista de roles obtenida exitosamente
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
 *                         description: ID del rol
 *                       name:
 *                         type: string
 *                         description: Nombre del rol
 *                       description:
 *                         type: string
 *                         description: Descripción del rol
 *                       created_at:
 *                         type: string
 *                         format: date-time
 *                         description: Fecha de creación
 *       500:
 *         description: Error interno del servidor
 */
const getRoles = async (req, res) => {
  try {
    const [roles] = await pool.query(
      'SELECT id, name, description, created_at FROM roles ORDER BY name ASC'
    );

    res.json({
      success: true,
      data: roles
    });
  } catch (error) {
    console.error('Error al obtener roles:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error al obtener roles',
      error: error.message 
    });
  }
};

/**
 * @swagger
 * /api/roles/{id}:
 *   get:
 *     summary: Obtener rol por ID
 *     description: Retorna los detalles de un rol específico
 *     tags: [Roles]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: ID del rol
 *     responses:
 *       200:
 *         description: Rol encontrado exitosamente
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
 *                     name:
 *                       type: string
 *                     description:
 *                       type: string
 *                     created_at:
 *                       type: string
 *                       format: date-time
 *       404:
 *         description: Rol no encontrado
 *       500:
 *         description: Error interno del servidor
 */
const getRoleById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const [result] = await pool.query(
      `SELECT r.*, COUNT(u.id) as user_count
       FROM roles r
       LEFT JOIN users u ON r.id = u.role_id
       WHERE r.id = ?
       GROUP BY r.id`,
      [id]
    );

    if (result.length === 0) {
      return res.status(404).json({ 
        success: false, 
        message: 'Rol no encontrado' 
      });
    }

    res.json({ 
      success: true, 
      data: result[0] 
    });
  } catch (error) {
    console.error('Error al obtener rol:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error al obtener rol',
      error: error.message 
    });
  }
};

/**
 * @swagger
 * /api/roles:
 *   post:
 *     summary: Crear nuevo rol
 *     description: Crea un nuevo rol en el sistema
 *     tags: [Roles]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: Nombre del rol
 *                 example: "Administrador"
 *               description:
 *                 type: string
 *                 description: Descripción del rol
 *                 example: "Rol con acceso completo al sistema"
 *     responses:
 *       201:
 *         description: Rol creado exitosamente
 *       400:
 *         description: Datos de entrada inválidos
 *       401:
 *         description: No autorizado
 *       409:
 *         description: El rol ya existe
 *       500:
 *         description: Error interno del servidor
 */
const createRole = async (req, res) => {
  try {
    const { name, description } = req.body;

    if (!name) {
      return res.status(400).json({
        success: false,
        message: 'El nombre del rol es requerido'
      });
    }

    // Verificar si el rol ya existe
    const [existingRole] = await pool.query(
      'SELECT id FROM roles WHERE name = ?',
      [name]
    );

    if (existingRole.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Ya existe un rol con ese nombre'
      });
    }

    // Crear rol
    const [result] = await pool.query(
      'INSERT INTO roles (name, description) VALUES (?, ?)',
      [name, description]
    );

    // Obtener el rol creado
    const [roleResult] = await pool.query(
      'SELECT * FROM roles WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Rol creado exitosamente',
      data: roleResult[0]
    });
  } catch (error) {
    console.error('Error al crear rol:', error);
    res.status(500).json({ 
      success: false, 
      message: 'Error al crear rol',
      error: error.message 
    });
  }
};

module.exports = {
  getRoles,
  getRoleById,
  createRole
}; 