
-- ESTRUCTURA COMPLETA DE INVENTARIO + TRAZABILIDAD + USUARIOS
-- Generado: 2025-08-01 19:54:25

-- ======================
-- ROLES DE USUARIOS
-- ======================
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- USUARIOS DEL SISTEMA
-- ======================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role_id INTEGER REFERENCES roles(id),
    status BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ======================
-- LOG DE ACTIVIDAD
-- ======================
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    record_id INTEGER,
    description TEXT,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- CATEGORÍAS DE PRODUCTOS
-- ======================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ======================
-- PRODUCTOS
-- ======================
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sku VARCHAR(50) UNIQUE,
    category_id INTEGER REFERENCES categories(id),
    stock_quantity INTEGER DEFAULT 0,
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2) NOT NULL,
    status BOOLEAN DEFAULT TRUE,
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

-- ======================
-- COMPRAS
-- ======================
CREATE TABLE purchases (
    id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100),
    purchase_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE purchase_items (
    id SERIAL PRIMARY KEY,
    purchase_id INTEGER REFERENCES purchases(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED
);

-- ======================
-- VENTAS
-- ======================
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    sale_date DATE NOT NULL,
    total_amount DECIMAL(10,2),
    created_by INTEGER REFERENCES users(id),
    updated_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP
);

CREATE TABLE sale_items (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

-- ======================
-- AJUSTES DE INVENTARIO
-- ======================
CREATE TABLE inventory_adjustments (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    adjustment_type VARCHAR(20) CHECK (adjustment_type IN ('ADD', 'REMOVE')),
    quantity INTEGER NOT NULL,
    reason TEXT,
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
