-- Script para insertar roles por defecto en el sistema de inventario
-- Ejecutar después de crear la base de datos

USE sys_inventario;

-- Insertar roles por defecto
INSERT INTO roles (name, description) VALUES 
('Administrador', 'Rol con acceso completo al sistema. Puede gestionar usuarios, productos, categorías, compras, ventas y configuraciones.'),
('Gerente', 'Rol con acceso a la gestión de productos, categorías, compras y ventas. Puede ver reportes y estadísticas.'),
('Vendedor', 'Rol con acceso a ventas y consulta de productos. Puede procesar ventas y ver inventario.'),
('Almacén', 'Rol con acceso a gestión de productos, categorías y compras. Puede actualizar inventario y procesar compras.'),
('Usuario', 'Rol básico con acceso limitado. Puede consultar productos y realizar operaciones básicas.');

-- Verificar que se insertaron correctamente
SELECT * FROM roles ORDER BY id; 