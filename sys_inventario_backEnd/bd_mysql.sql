-- ESTRUCTURA COMPLETA DE INVENTARIO + TRAZABILIDAD + USUARIOS
-- Generado: 2025-08-01 19:54:25
-- Base de datos: MySQL

-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS sys_inventario;
USE sys_inventario;

-- ======================
-- ROLES DE USUARIOS
-- ======================
CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- USUARIOS DEL SISTEMA
-- ======================
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role_id INT,
    status BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- ======================
-- LOG DE ACTIVIDAD
-- ======================
CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    description TEXT,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- ======================
-- CATEGORÍAS DE PRODUCTOS
-- ======================
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_by INT,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- ======================
-- PRODUCTOS
-- ======================
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sku VARCHAR(50) UNIQUE,
    category_id INT,
    stock_quantity INT DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    status BOOLEAN DEFAULT TRUE,
    created_by INT,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- ======================
-- COMPRAS
-- ======================
CREATE TABLE purchases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100),
    purchase_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    created_by INT,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

CREATE TABLE purchase_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
    FOREIGN KEY (purchase_id) REFERENCES purchases(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ======================
-- VENTAS
-- ======================
CREATE TABLE sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100),
    sale_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    created_by INT,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

CREATE TABLE sale_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- ======================
-- AJUSTES DE INVENTARIO
-- ======================
CREATE TABLE inventory_adjustments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    adjustment_type ENUM('ADD', 'REMOVE') NOT NULL,
    quantity INT NOT NULL,
    reason TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- ======================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ======================
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_purchase_items_purchase_id ON purchase_items(purchase_id);
CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_inventory_adjustments_product_id ON inventory_adjustments(product_id); 