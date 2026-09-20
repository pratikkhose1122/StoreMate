-- Migration 007: RPC Process Sale and Intent Log Idempotency

-- 1. Intent Log Table
CREATE TABLE IF NOT EXISTS intent_log (
    intent_id UUID PRIMARY KEY,
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    rpc_name VARCHAR NOT NULL,
    response_payload JSONB,
    processed_at TIMESTAMPTZ DEFAULT now()
);

-- Ensure index for pruning if needed
CREATE INDEX IF NOT EXISTS idx_intent_log_shop_processed ON intent_log(shop_id, processed_at);

-- 2. Ensure invoice_sequences table exists (created in 004, but just to be safe)
CREATE TABLE IF NOT EXISTS invoice_sequences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    current_number INTEGER NOT NULL DEFAULT 0,
    financial_year VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(shop_id, financial_year)
);

-- 3. Add shop snapshot columns to sales if missing (they might be missing in some environments)
ALTER TABLE sales ADD COLUMN IF NOT EXISTS shop_name_snapshot VARCHAR;
ALTER TABLE sales ADD COLUMN IF NOT EXISTS shop_address_snapshot TEXT;
ALTER TABLE sales ADD COLUMN IF NOT EXISTS shop_phone_snapshot VARCHAR;

-- 4. Drop the old competing RPC
DROP FUNCTION IF EXISTS process_checkout(UUID, UUID, VARCHAR, NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, NUMERIC, VARCHAR, JSONB);

-- 5. The canonical RPC: rpc_process_sale
CREATE OR REPLACE FUNCTION rpc_process_sale(
  p_intent_id UUID,
  p_shop_id UUID,
  p_customer_id UUID,
  p_business_timestamp TIMESTAMPTZ,
  p_payment_method VARCHAR,
  p_items JSONB,
  p_discount_amount NUMERIC,
  p_paid_amount NUMERIC
) RETURNS JSONB AS $$
DECLARE
  v_sale_id UUID;
  v_invoice_number VARCHAR;
  v_financial_year VARCHAR;
  v_seq_val INT;
  v_item JSONB;
  v_product_id UUID;
  v_qty NUMERIC;
  v_price NUMERIC;
  v_tax_pct NUMERIC;
  v_item_subtotal NUMERIC;
  v_item_tax NUMERIC;
  v_prod_name VARCHAR;
  v_curr_stock NUMERIC;
  v_new_stock NUMERIC;
  v_subtotal NUMERIC := 0;
  v_tax_total NUMERIC := 0;
  v_grand_total NUMERIC := 0;
  v_due_amount NUMERIC := 0;
  v_shop_name VARCHAR;
  v_shop_address TEXT;
  v_shop_phone VARCHAR;
  v_existing_response JSONB;
  v_firebase_uid VARCHAR;
BEGIN
  -- 1. Authorization: check if caller has access to the shop
  -- Extract firebase_uid from JWT (handling both standard Supabase and custom JWT formats)
  v_firebase_uid := COALESCE(
    (current_setting('request.jwt.claims', true)::jsonb)->>'firebase_uid',
    current_setting('request.jwt.claim.firebase_uid', true)
  );

  IF v_firebase_uid IS NULL OR NOT EXISTS (
    SELECT 1 FROM users WHERE firebase_uid = v_firebase_uid AND shop_id = p_shop_id
  ) THEN
    RAISE EXCEPTION 'Unauthorized: You do not have permission to access this shop.' USING ERRCODE = 'P0001';
  END IF;

  -- 2. Idempotency Check
  SELECT response_payload INTO v_existing_response FROM intent_log WHERE intent_id = p_intent_id;
  IF FOUND THEN
    RETURN v_existing_response;
  END IF;

  -- 3. Validate Credit Payment
  IF p_payment_method = 'credit' AND p_customer_id IS NULL THEN
    RAISE EXCEPTION 'Select a customer for credit payment.';
  END IF;

  -- 4. Fetch authoritative shop details for snapshot
  SELECT name, address, mobile_number 
  INTO v_shop_name, v_shop_address, v_shop_phone
  FROM shops WHERE id = p_shop_id;

  IF v_shop_name IS NULL THEN
    RAISE EXCEPTION 'Shop not found.';
  END IF;

  -- 5. Calculate totals from items
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_qty := (v_item->>'quantity')::NUMERIC;
    v_price := (v_item->>'unitPrice')::NUMERIC;
    v_tax_pct := COALESCE((v_item->>'taxPercentage')::NUMERIC, 0.0);
    v_item_subtotal := v_qty * v_price;
    v_item_tax := v_item_subtotal * (v_tax_pct / 100.0);
    
    v_subtotal := v_subtotal + v_item_subtotal;
    v_tax_total := v_tax_total + v_item_tax;
  END LOOP;
  
  v_grand_total := v_subtotal + v_tax_total - p_discount_amount;
  v_due_amount := GREATEST(0, v_grand_total - p_paid_amount);

  -- 6. Generate Invoice Number with Row-Level Lock
  v_financial_year := to_char(p_business_timestamp, 'YYYY'); 
  
  INSERT INTO invoice_sequences (shop_id, financial_year, current_number)
  VALUES (p_shop_id, v_financial_year, 0)
  ON CONFLICT (shop_id, financial_year) DO NOTHING;

  SELECT current_number INTO v_seq_val
  FROM invoice_sequences 
  WHERE shop_id = p_shop_id AND financial_year = v_financial_year
  FOR UPDATE;

  v_seq_val := v_seq_val + 1;
  
  UPDATE invoice_sequences 
  SET current_number = v_seq_val 
  WHERE shop_id = p_shop_id AND financial_year = v_financial_year;

  v_invoice_number := 'INV-' || v_financial_year || '-' || lpad(v_seq_val::text, 6, '0');

  -- 7. Insert Sale
  INSERT INTO sales (
    shop_id, customer_id, invoice_number, subtotal, tax_amount,
    discount_amount, total_amount, paid_amount, due_amount, payment_method, status,
    shop_name_snapshot, shop_address_snapshot, shop_phone_snapshot
  ) VALUES (
    p_shop_id, p_customer_id, v_invoice_number, v_subtotal, v_tax_total,
    p_discount_amount, v_grand_total, p_paid_amount, v_due_amount, p_payment_method, 'completed',
    v_shop_name, v_shop_address, v_shop_phone
  ) RETURNING id INTO v_sale_id;

  -- 8. Process each item (inventory deduction + sale item)
  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_product_id := (v_item->>'productId')::UUID;
    v_qty := (v_item->>'quantity')::NUMERIC;
    v_price := (v_item->>'unitPrice')::NUMERIC;
    v_tax_pct := COALESCE((v_item->>'taxPercentage')::NUMERIC, 0.0);
    v_item_subtotal := v_qty * v_price;
    v_item_tax := v_item_subtotal * (v_tax_pct / 100.0);
    v_prod_name := COALESCE(v_item->>'productName', 'Product');

    IF v_product_id IS NOT NULL THEN
      DECLARE
        v_purchase_price NUMERIC;
      BEGIN
        -- Lock product row for atomic stock update and historical cost capture
        SELECT name, current_stock, purchase_price INTO v_prod_name, v_curr_stock, v_purchase_price
        FROM products WHERE id = v_product_id AND shop_id = p_shop_id FOR UPDATE;

        IF NOT FOUND THEN
          RAISE EXCEPTION 'Product % does not belong to the current shop or does not exist.', v_product_id USING ERRCODE = 'P0002';
        END IF;

        v_new_stock := v_curr_stock - v_qty;
        
        -- Update product stock
        UPDATE products SET current_stock = v_new_stock, updated_at = now() WHERE id = v_product_id;

        -- Create inventory audit log
        INSERT INTO inventory_logs (
          product_id, shop_id, change_type, quantity, previous_stock, new_stock, notes
        ) VALUES (
          v_product_id, p_shop_id, 'sale', -v_qty, v_curr_stock, v_new_stock, 'POS Sale ' || v_invoice_number
        );
        
        -- Insert sale item WITH captured historical cost
        INSERT INTO sale_items (
          sale_id, product_id, product_name, quantity, unit_price, purchase_price, tax_percentage, tax_amount, total_price
        ) VALUES (
          v_sale_id, v_product_id, v_prod_name, v_qty, v_price, COALESCE(v_purchase_price, 0), v_tax_pct, v_item_tax, v_item_subtotal
        );
      END;
    ELSE
      -- Insert sale item for manual/custom product without historical cost
      INSERT INTO sale_items (
        sale_id, product_id, product_name, quantity, unit_price, purchase_price, tax_percentage, tax_amount, total_price
      ) VALUES (
        v_sale_id, v_product_id, v_prod_name, v_qty, v_price, 0, v_tax_pct, v_item_tax, v_item_subtotal
      );
    END IF;
  END LOOP;

  -- 9. Update customer totals & credit if customer attached
  IF p_customer_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1
      FROM customers
      WHERE id = p_customer_id
        AND shop_id = p_shop_id
    ) THEN
      RAISE EXCEPTION 'Customer does not belong to the current shop.' USING ERRCODE = 'P0003';
    END IF;

    UPDATE customers SET
      total_purchases = total_purchases + v_grand_total,
      current_credit = current_credit + v_due_amount,
      updated_at = now()
    WHERE id = p_customer_id;
  END IF;

  -- 10. Store idempotency response
  v_existing_response := jsonb_build_object(
    'success', true,
    'entity_id', v_sale_id,
    'invoice_number', v_invoice_number,
    'server_timestamp', now()
  );

  INSERT INTO intent_log (intent_id, shop_id, rpc_name, response_payload)
  VALUES (p_intent_id, p_shop_id, 'rpc_process_sale', v_existing_response);

  -- 11. Return Response
  RETURN v_existing_response;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
