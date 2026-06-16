-- 1. Enable the pg_trgm extension for fast text search
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. Categories Table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT uq_shop_category_name UNIQUE (shop_id, name)
);

-- 3. Products Table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    
    name VARCHAR(255) NOT NULL,
    description TEXT,
    
    sku VARCHAR(50),
    barcode VARCHAR(100),
    image_url TEXT,
    
    purchase_price DECIMAL(12,2) NOT NULL CHECK (purchase_price >= 0),
    selling_price DECIMAL(12,2) NOT NULL CHECK (selling_price >= 0),
    
    quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    low_stock_threshold INTEGER NOT NULL DEFAULT 5,
    
    unit_type VARCHAR(20) NOT NULL DEFAULT 'piece',
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

-- Constraints for uniqueness ignoring nulls
CREATE UNIQUE INDEX uq_shop_sku ON products (shop_id, sku) WHERE sku IS NOT NULL;
CREATE UNIQUE INDEX uq_shop_barcode ON products (shop_id, barcode) WHERE barcode IS NOT NULL;

-- Indexes for performance
CREATE INDEX idx_products_shop_id ON products(shop_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode);
-- Trigram index for fast ILIKE/search on product name
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);

-- 4. Inventory Logs Action Type Enum
CREATE TYPE inventory_action_type AS ENUM (
    'stock_in', 
    'stock_out', 
    'adjustment', 
    'sale', 
    'purchase', 
    'return'
);

-- 5. Inventory Logs Table
CREATE TABLE inventory_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    
    action_type inventory_action_type NOT NULL,
    
    quantity_before INTEGER NOT NULL,
    quantity_change INTEGER NOT NULL,
    quantity_after INTEGER NOT NULL,
    
    notes TEXT,
    
    created_by UUID NOT NULL REFERENCES users(id) ON DELETE SET NULL,
    created_by_name VARCHAR(100) NOT NULL,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
