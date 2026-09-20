-- ===================================================
-- StoreMate Production SQL Schema & Security Audit Fixes
-- Includes: Multi-tenant RLS Isolation & Atomic RPC Checkout
-- ===================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. SHOPS TABLE
CREATE TABLE IF NOT EXISTS shops (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_code VARCHAR UNIQUE NOT NULL,
  name VARCHAR NOT NULL,
  owner_name VARCHAR NOT NULL,
  mobile_number VARCHAR,
  email VARCHAR,
  address TEXT,
  business_type VARCHAR NOT NULL DEFAULT 'general',
  gstin VARCHAR,
  logo_url TEXT,
  qr_code_url TEXT,
  upi_id VARCHAR,
  bank_details JSONB,
  terms_conditions TEXT,
  subscription_status VARCHAR DEFAULT 'active',
  subscription_end_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. USERS TABLE
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  firebase_uid VARCHAR UNIQUE NOT NULL,
  mobile_number VARCHAR UNIQUE NOT NULL,
  role VARCHAR DEFAULT 'owner',
  shop_id UUID REFERENCES shops(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 3. CATEGORIES TABLE
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  name VARCHAR NOT NULL,
  icon VARCHAR,
  color VARCHAR,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 4. PRODUCTS TABLE
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name VARCHAR NOT NULL,
  sku VARCHAR,
  barcode VARCHAR,
  unit_type VARCHAR DEFAULT 'piece',
  purchase_price NUMERIC(10,2) DEFAULT 0.00,
  selling_price NUMERIC(10,2) NOT NULL,
  mrp NUMERIC(10,2),
  current_stock INT DEFAULT 0,
  low_stock_threshold INT DEFAULT 5,
  is_low_stock_alert_enabled BOOLEAN DEFAULT true,
  tax_percentage NUMERIC(5,2) DEFAULT 0.00,
  hsn_code VARCHAR,
  image_url TEXT,
  description TEXT,
  status VARCHAR DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 5. CUSTOMERS TABLE
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  name VARCHAR NOT NULL,
  mobile_number VARCHAR NOT NULL,
  email VARCHAR,
  address TEXT,
  total_purchases NUMERIC(12,2) DEFAULT 0.00,
  current_credit NUMERIC(10,2) DEFAULT 0.00,
  credit_limit NUMERIC(10,2) DEFAULT 5000.00,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 6. SALES TABLE
CREATE TABLE IF NOT EXISTS sales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
  invoice_number VARCHAR UNIQUE NOT NULL,
  subtotal NUMERIC(10,2) NOT NULL,
  tax_amount NUMERIC(10,2) DEFAULT 0.00,
  discount_amount NUMERIC(10,2) DEFAULT 0.00,
  total_amount NUMERIC(10,2) NOT NULL,
  paid_amount NUMERIC(10,2) NOT NULL,
  due_amount NUMERIC(10,2) DEFAULT 0.00,
  payment_method VARCHAR NOT NULL DEFAULT 'cash',
  status VARCHAR DEFAULT 'completed',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 7. SALE ITEMS TABLE
CREATE TABLE IF NOT EXISTS sale_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  product_name VARCHAR NOT NULL,
  quantity INT NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL,
  tax_percentage NUMERIC(5,2) DEFAULT 0.00,
  tax_amount NUMERIC(10,2) DEFAULT 0.00,
  total_price NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 8. INVENTORY LOGS TABLE
CREATE TABLE IF NOT EXISTS inventory_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
  change_type VARCHAR NOT NULL,
  quantity INT NOT NULL,
  previous_stock INT NOT NULL,
  new_stock INT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS CONFIGURATION & SCHEMAS
ALTER TABLE shops ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_logs ENABLE ROW LEVEL SECURITY;

-- Clean existing policies
DROP POLICY IF EXISTS "Allow public read-write for shops" ON shops;
DROP POLICY IF EXISTS "Allow public read-write for users" ON users;
DROP POLICY IF EXISTS "Allow public read-write for categories" ON categories;
DROP POLICY IF EXISTS "Allow public read-write for products" ON products;
DROP POLICY IF EXISTS "Allow public read-write for customers" ON customers;
DROP POLICY IF EXISTS "Allow public read-write for sales" ON sales;
DROP POLICY IF EXISTS "Allow public read-write for sale_items" ON sale_items;
DROP POLICY IF EXISTS "Allow public read-write for inventory_logs" ON inventory_logs;

-- STRICT RLS POLICIES BASED ON FIREBASE_UID CLAIM
-- 1. Users can only read/update their own user record based on the custom claim
CREATE POLICY "Users can manage own record" ON users 
  FOR ALL USING (firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)) 
  WITH CHECK (firebase_uid = current_setting('request.jwt.claim.firebase_uid', true));

-- 2. Shops can only be accessed if the user's shop_id matches the shop id
CREATE POLICY "Shops isolated by user shop_id" ON shops 
  FOR ALL USING (id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)))
  WITH CHECK (id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)));

-- 3. All other tables isolated by shop_id matching the authenticated user's shop_id
CREATE POLICY "Categories isolated by shop" ON categories 
  FOR ALL USING (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)))
  WITH CHECK (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)));

CREATE POLICY "Products isolated by shop" ON products 
  FOR ALL USING (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)))
  WITH CHECK (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)));

CREATE POLICY "Customers isolated by shop" ON customers 
  FOR ALL USING (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)))
  WITH CHECK (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)));

CREATE POLICY "Sales isolated by shop" ON sales 
  FOR ALL USING (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)))
  WITH CHECK (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)));

CREATE POLICY "Sale items isolated by shop" ON sale_items 
  FOR ALL USING (sale_id IN (SELECT id FROM sales WHERE shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true))))
  WITH CHECK (sale_id IN (SELECT id FROM sales WHERE shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true))));

CREATE POLICY "Inventory logs isolated by shop" ON inventory_logs 
  FOR ALL USING (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)))
  WITH CHECK (shop_id = (SELECT shop_id FROM users WHERE firebase_uid = current_setting('request.jwt.claim.firebase_uid', true)));

GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;

-- =========================================================================
-- ATOMIC STORED PROCEDURE: process_checkout (ACID COMPLIANT RPC FUNCTION)
-- =========================================================================
CREATE OR REPLACE FUNCTION process_checkout(
  p_shop_id UUID,
  p_customer_id UUID,
  p_invoice_number VARCHAR,
  p_subtotal NUMERIC,
  p_tax_amount NUMERIC,
  p_discount_amount NUMERIC,
  p_total_amount NUMERIC,
  p_paid_amount NUMERIC,
  p_due_amount NUMERIC,
  p_payment_method VARCHAR,
  p_items JSONB
) RETURNS JSONB AS $$
DECLARE
  v_sale_id UUID;
  v_item JSONB;
  v_product_id UUID;
  v_qty INT;
  v_price NUMERIC;
  v_tax_pct NUMERIC;
  v_item_subtotal NUMERIC;
  v_item_tax NUMERIC;
  v_prod_name VARCHAR;
  v_curr_stock INT;
  v_new_stock INT;
BEGIN
  -- 1. Insert into sales table
  INSERT INTO sales (
    shop_id, customer_id, invoice_number, subtotal, tax_amount,
    discount_amount, total_amount, paid_amount, due_amount, payment_method, status
  ) VALUES (
    p_shop_id, p_customer_id, p_invoice_number, p_subtotal, p_tax_amount,
    p_discount_amount, p_total_amount, p_paid_amount, p_due_amount, p_payment_method, 'completed'
  ) RETURNING id INTO v_sale_id;

  -- 2. Process each item inside atomic loop
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_product_id := (v_item->>'productId')::UUID;
    v_qty := (v_item->>'quantity')::INT;
    v_price := (v_item->>'unitPrice')::NUMERIC;
    v_tax_pct := COALESCE((v_item->>'taxPercentage')::NUMERIC, 0.0);
    v_item_subtotal := v_qty * v_price;
    v_item_tax := v_item_subtotal * (v_tax_pct / 100.0);
    v_prod_name := COALESCE(v_item->>'productName', 'Product');

    IF v_product_id IS NOT NULL THEN
      -- Lock product row for atomic stock update
      SELECT name, current_stock INTO v_prod_name, v_curr_stock
      FROM products WHERE id = v_product_id FOR UPDATE;

      IF FOUND THEN
        v_new_stock := GREATEST(0, v_curr_stock - v_qty);
        
        -- Update product stock
        UPDATE products SET current_stock = v_new_stock, updated_at = now() WHERE id = v_product_id;

        -- Create inventory audit log
        INSERT INTO inventory_logs (
          product_id, shop_id, change_type, quantity, previous_stock, new_stock, notes
        ) VALUES (
          v_product_id, p_shop_id, 'sale', -v_qty, v_curr_stock, v_new_stock, 'POS Sale ' || p_invoice_number
        );
      END IF;
    END IF;

    -- Insert sale item
    INSERT INTO sale_items (
      sale_id, product_id, product_name, quantity, unit_price, tax_percentage, tax_amount, total_price
    ) VALUES (
      v_sale_id, v_product_id, v_prod_name, v_qty, v_price, v_tax_pct, v_item_tax, v_item_subtotal
    );
  END LOOP;

  -- 3. Update customer totals & credit if customer attached
  IF p_customer_id IS NOT NULL THEN
    UPDATE customers SET
      total_purchases = total_purchases + p_total_amount,
      current_credit = current_credit + p_due_amount,
      updated_at = now()
    WHERE id = p_customer_id;
  END IF;

  RETURN jsonb_build_object(
    'id', v_sale_id,
    'invoiceNumber', p_invoice_number,
    'shopId', p_shop_id,
    'totalAmount', p_total_amount,
    'paidAmount', p_paid_amount,
    'dueAmount', p_due_amount,
    'status', 'completed'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
