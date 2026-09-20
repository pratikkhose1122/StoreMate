-- Phase 2E: Canonical RPCs
-- Drop old competing refund RPCs to leave only one canonical signature
DROP FUNCTION IF EXISTS public.process_refund(uuid, uuid, uuid, text, text, text, jsonb);
DROP FUNCTION IF EXISTS public.process_refund(uuid, uuid, uuid, text, text, text, text, jsonb);

-- 1. rpc_process_sale
CREATE OR REPLACE FUNCTION public.rpc_process_sale(
  p_intent_id UUID,
  p_shop_id UUID,
  p_customer_id UUID,
  p_business_timestamp TIMESTAMPTZ,
  p_payment_method VARCHAR,
  p_items JSONB,
  p_discount_amount NUMERIC(12,2),
  p_paid_amount NUMERIC(12,2)
) RETURNS JSONB AS $$
DECLARE
  v_sale_id UUID;
  v_invoice_number VARCHAR;
  v_financial_year VARCHAR;
  v_seq_val INT;
  v_item JSONB;
  v_product_id UUID;
  v_qty NUMERIC(12,3);
  v_price NUMERIC(12,2);
  v_tax_pct NUMERIC(5,2);
  v_item_subtotal NUMERIC(12,2);
  v_item_tax NUMERIC(12,2);
  v_prod_name VARCHAR;
  v_curr_stock NUMERIC(12,3);
  v_new_stock NUMERIC(12,3);
  v_subtotal NUMERIC(12,2) := 0.00;
  v_tax_total NUMERIC(12,2) := 0.00;
  v_grand_total NUMERIC(12,2) := 0.00;
  v_due_amount NUMERIC(12,2) := 0.00;
  v_shop_name VARCHAR;
  v_shop_address TEXT;
  v_shop_phone VARCHAR;
  v_existing_response JSONB;
  v_firebase_uid VARCHAR;
BEGIN
  v_firebase_uid := COALESCE(
    (current_setting('request.jwt.claims', true)::jsonb)->>'firebase_uid',
    current_setting('request.jwt.claim.firebase_uid', true)
  );

  IF v_firebase_uid IS NULL OR NOT EXISTS (
    SELECT 1 FROM users WHERE firebase_uid = v_firebase_uid AND shop_id = p_shop_id
  ) THEN
    RAISE EXCEPTION 'Unauthorized: You do not have permission to access this shop.' USING ERRCODE = 'P0001';
  END IF;

  SELECT response_payload INTO v_existing_response FROM intent_log WHERE intent_id = p_intent_id;
  IF FOUND THEN
    RETURN v_existing_response;
  END IF;

  IF p_payment_method = 'credit' AND p_customer_id IS NULL THEN
    RAISE EXCEPTION 'Select a customer for credit payment.';
  END IF;

  SELECT name, address, mobile_number 
  INTO v_shop_name, v_shop_address, v_shop_phone
  FROM shops WHERE id = p_shop_id;

  IF v_shop_name IS NULL THEN
    RAISE EXCEPTION 'Shop not found.';
  END IF;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_qty := (v_item->>'quantity')::NUMERIC(12,3);
    v_price := (v_item->>'unitPrice')::NUMERIC(12,2);
    v_tax_pct := COALESCE((v_item->>'taxPercentage')::NUMERIC(5,2), 0.00);
    v_item_subtotal := v_qty * v_price;
    v_item_tax := v_item_subtotal * (v_tax_pct / 100.0);
    
    v_subtotal := v_subtotal + v_item_subtotal;
    v_tax_total := v_tax_total + v_item_tax;
  END LOOP;
  
  v_grand_total := v_subtotal + v_tax_total - p_discount_amount;
  v_due_amount := GREATEST(0.00, v_grand_total - p_paid_amount);

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

  INSERT INTO sales (
    shop_id, customer_id, invoice_number, subtotal, tax_amount,
    discount_amount, total_amount, paid_amount, due_amount, payment_method, status,
    shop_name_snapshot, shop_address_snapshot, shop_phone_snapshot
  ) VALUES (
    p_shop_id, p_customer_id, v_invoice_number, v_subtotal, v_tax_total,
    p_discount_amount, v_grand_total, p_paid_amount, v_due_amount, p_payment_method, 'completed',
    v_shop_name, v_shop_address, v_shop_phone
  ) RETURNING id INTO v_sale_id;

  FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
  LOOP
    v_product_id := (v_item->>'productId')::UUID;
    v_qty := (v_item->>'quantity')::NUMERIC(12,3);
    v_price := (v_item->>'unitPrice')::NUMERIC(12,2);
    v_tax_pct := COALESCE((v_item->>'taxPercentage')::NUMERIC(5,2), 0.00);
    v_item_subtotal := v_qty * v_price;
    v_item_tax := v_item_subtotal * (v_tax_pct / 100.0);
    v_prod_name := COALESCE(v_item->>'productName', 'Product');

    IF v_product_id IS NOT NULL THEN
      DECLARE
        v_purchase_price NUMERIC(12,2);
      BEGIN
        SELECT name, current_stock, purchase_price INTO v_prod_name, v_curr_stock, v_purchase_price
        FROM products WHERE id = v_product_id AND shop_id = p_shop_id FOR UPDATE;

        IF NOT FOUND THEN
          RAISE EXCEPTION 'Product % does not belong to the current shop or does not exist.', v_product_id USING ERRCODE = 'P0002';
        END IF;

        v_new_stock := v_curr_stock - v_qty;
        
        UPDATE products SET current_stock = v_new_stock, updated_at = now() WHERE id = v_product_id;

        INSERT INTO inventory_logs (
          product_id, shop_id, change_type, quantity, previous_stock, new_stock, notes
        ) VALUES (
          v_product_id, p_shop_id, 'sale', -v_qty, v_curr_stock, v_new_stock, 'POS Sale ' || v_invoice_number
        );
        
        INSERT INTO sale_items (
          sale_id, product_id, product_name, quantity, unit_price, purchase_price, tax_percentage, tax_amount, total_price
        ) VALUES (
          v_sale_id, v_product_id, v_prod_name, v_qty, v_price, COALESCE(v_purchase_price, 0.00), v_tax_pct, v_item_tax, v_item_subtotal
        );
      END;
    ELSE
      INSERT INTO sale_items (
        sale_id, product_id, product_name, quantity, unit_price, purchase_price, tax_percentage, tax_amount, total_price
      ) VALUES (
        v_sale_id, v_product_id, v_prod_name, v_qty, v_price, 0.00, v_tax_pct, v_item_tax, v_item_subtotal
      );
    END IF;
  END LOOP;

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

  v_existing_response := jsonb_build_object(
    'success', true,
    'entity_id', v_sale_id,
    'invoice_number', v_invoice_number,
    'server_timestamp', now()
  );

  INSERT INTO intent_log (intent_id, shop_id, rpc_name, response_payload)
  VALUES (p_intent_id, p_shop_id, 'rpc_process_sale', v_existing_response);

  RETURN v_existing_response;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. process_refund
CREATE OR REPLACE FUNCTION public.process_refund(
  p_shop_id uuid,
  p_sale_id uuid,
  p_user_id uuid,
  p_refund_payment_method text,
  p_reason text,
  p_notes text,
  p_items jsonb
) RETURNS uuid AS $$
DECLARE
    v_return_id UUID;
    v_item JSONB;
    v_total_refund NUMERIC(12,2) := 0.00;
    v_sale_status TEXT;
    v_sale_total NUMERIC(12,2);
    v_sale_refunded NUMERIC(12,2);
    v_customer_id UUID;
    v_sale_item_id UUID;
    v_product_id UUID;
    v_quantity NUMERIC(12,3);
    v_refunded_qty NUMERIC(12,3);
    v_original_qty NUMERIC(12,3);
    v_item_unit_price NUMERIC(12,2);
    v_item_tax_pct NUMERIC(5,2);
    v_item_refund_subtotal NUMERIC(12,2);
    v_item_refund_tax NUMERIC(12,2);
    v_item_refund_total NUMERIC(12,2);
    v_user_role TEXT;
    v_refund_number TEXT;
BEGIN
    SELECT role INTO v_user_role FROM users WHERE id = p_user_id;
    IF v_user_role NOT IN ('owner', 'manager') THEN
        RAISE EXCEPTION 'Unauthorized: Only owners or managers can process refunds.';
    END IF;

    SELECT total_amount, COALESCE(refund_amount, 0.00), customer_id, status 
    INTO v_sale_total, v_sale_refunded, v_customer_id, v_sale_status
    FROM sales
    WHERE id = p_sale_id AND shop_id = p_shop_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale not found or does not belong to shop';
    END IF;

    IF v_sale_status IN ('cancelled', 'fully_refunded') THEN
        RAISE EXCEPTION 'Cannot refund a sale that is already %.', v_sale_status;
    END IF;

    v_refund_number := 'RF-' || to_char(NOW(), 'YYYYMMDD') || '-' || lpad(floor(random() * 100000)::text, 5, '0');
    v_return_id := gen_random_uuid();
    
    INSERT INTO returns (id, sale_id, shop_id, customer_id, refund_number, refund_amount, refund_method, reason, notes, created_by)
    VALUES (v_return_id, p_sale_id, p_shop_id, v_customer_id, v_refund_number, 0.00, p_refund_payment_method, p_reason, p_notes, p_user_id);

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_sale_item_id := (v_item->>'sale_item_id')::UUID;
        
        v_quantity := (v_item->>'quantity')::NUMERIC(12,3);
        IF v_quantity <= 0 THEN
            RAISE EXCEPTION 'Refund quantity must be greater than zero.';
        END IF;

        SELECT quantity, unit_price, tax_percentage, product_id 
        INTO v_original_qty, v_item_unit_price, v_item_tax_pct, v_product_id
        FROM sale_items WHERE id = v_sale_item_id FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Sale item % not found', v_sale_item_id;
        END IF;
        
        SELECT COALESCE(SUM(quantity), 0.00) INTO v_refunded_qty 
        FROM return_items ri 
        JOIN returns r ON ri.return_id = r.id 
        WHERE ri.sale_item_id = v_sale_item_id AND r.sale_id = p_sale_id;

        IF (v_refunded_qty + v_quantity) > v_original_qty THEN
            RAISE EXCEPTION 'Cannot refund more than purchased quantity for item %', v_sale_item_id;
        END IF;

        -- Authoritative Server-Side Calculation
        v_item_refund_subtotal := v_quantity * v_item_unit_price;
        v_item_refund_tax := v_item_refund_subtotal * (v_item_tax_pct / 100.0);
        v_item_refund_total := v_item_refund_subtotal + v_item_refund_tax;

        INSERT INTO return_items (return_id, sale_item_id, product_id, quantity, unit_price, tax_amount, discount_amount, line_total)
        VALUES (
            v_return_id,
            v_sale_item_id,
            v_product_id,
            v_quantity,
            v_item_unit_price,
            v_item_refund_tax,
            0.00, -- discount logic isn't defined per-item in refunds here, so we leave it 0
            v_item_refund_total
        );

        v_total_refund := v_total_refund + v_item_refund_total;

        IF v_product_id IS NOT NULL THEN
            DECLARE 
                v_prev_stock NUMERIC(12,3);
            BEGIN
                SELECT current_stock INTO v_prev_stock FROM products WHERE id = v_product_id FOR UPDATE;
                
                UPDATE products 
                SET current_stock = current_stock + v_quantity
                WHERE id = v_product_id;
                
                INSERT INTO inventory_movements (product_id, shop_id, type, previous_stock, new_stock, quantity_changed, reference_type, reference_id, created_by)
                VALUES (v_product_id, p_shop_id, 'refund', v_prev_stock, v_prev_stock + v_quantity, v_quantity, 'return', v_return_id, p_user_id);
            END;
        END IF;
    END LOOP;

    UPDATE returns SET refund_amount = v_total_refund WHERE id = v_return_id;

    INSERT INTO financial_transactions (shop_id, type, invoice_id, return_id, payment_method, amount, direction, created_by)
    VALUES (p_shop_id, 'refund', p_sale_id, v_return_id, p_refund_payment_method, v_total_refund, 'out', p_user_id);

    v_sale_refunded := v_sale_refunded + v_total_refund;
    
    IF v_sale_refunded >= (v_sale_total - 0.01) THEN
        v_sale_status := 'fully_refunded';
    ELSE
        v_sale_status := 'partially_refunded';
    END IF;

    UPDATE sales 
    SET 
        refund_amount = v_sale_refunded,
        status = v_sale_status,
        last_refund_at = NOW()
    WHERE id = p_sale_id;

    RETURN v_return_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Analytics
DROP FUNCTION IF EXISTS public.get_dashboard_summary(uuid, timestamp with time zone);
CREATE OR REPLACE FUNCTION public.get_dashboard_summary(p_shop_id uuid, p_start_date timestamp with time zone)
 RETURNS TABLE(todays_sales numeric, todays_profit numeric, total_sales_count bigint, total_categories bigint, total_products bigint, out_of_stock_products bigint, low_stock_products bigint, inventory_value numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH returned_quantities AS (
        SELECT sale_item_id, SUM(quantity) AS returned_qty
        FROM return_items 
        GROUP BY sale_item_id
    ),
    sale_cogs AS (
        SELECT si.sale_id,
               SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00) * si.purchase_price) AS valid_cogs
        FROM sale_items si
        LEFT JOIN returned_quantities rq ON rq.sale_item_id = si.id
        GROUP BY si.sale_id
    ),
    refunded_tax_per_sale AS (
        SELECT r.sale_id, SUM(ri.tax_amount) as total_refunded_tax
        FROM returns r 
        JOIN return_items ri ON r.id = ri.return_id
        GROUP BY r.sale_id
    )
    SELECT 
        COALESCE((
            SELECT SUM(s.total_amount - COALESCE(s.refund_amount, 0.00)) 
            FROM sales s 
            WHERE s.shop_id = p_shop_id 
              AND s.status IN ('completed', 'partially_refunded') 
              AND s.created_at >= p_start_date
        ), 0.00) as todays_sales,
        
        COALESCE((
            SELECT SUM(
                (s.total_amount - COALESCE(s.refund_amount, 0.00)) 
                - GREATEST(s.tax_amount - COALESCE(rt.total_refunded_tax, 0.00), 0.00)
                - COALESCE(sc.valid_cogs, 0.00)
            )
            FROM sales s 
            LEFT JOIN sale_cogs sc ON s.id = sc.sale_id
            LEFT JOIN refunded_tax_per_sale rt ON s.id = rt.sale_id
            WHERE s.shop_id = p_shop_id 
              AND s.status IN ('completed', 'partially_refunded') 
              AND s.created_at >= p_start_date
        ), 0.00) as todays_profit,
        
        (SELECT COUNT(*) FROM sales WHERE shop_id = p_shop_id AND status IN ('completed', 'partially_refunded') AND created_at >= p_start_date) as total_sales_count,
        (SELECT COUNT(*) FROM categories WHERE shop_id = p_shop_id) as total_categories,
        (SELECT COUNT(*) FROM products WHERE shop_id = p_shop_id) as total_products,
        (SELECT COUNT(*) FROM products WHERE shop_id = p_shop_id AND current_stock <= 0) as out_of_stock_products,
        (SELECT COUNT(*) FROM products WHERE shop_id = p_shop_id AND current_stock > 0 AND current_stock <= low_stock_threshold) as low_stock_products,
        COALESCE((SELECT SUM(current_stock * purchase_price) FROM products WHERE shop_id = p_shop_id AND current_stock > 0), 0.00) as inventory_value;
END;
$$;

DROP FUNCTION IF EXISTS public.get_sales_metrics(uuid, timestamp with time zone, timestamp with time zone);
CREATE OR REPLACE FUNCTION public.get_sales_metrics(p_shop_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone)
 RETURNS TABLE(total_revenue numeric, total_profit numeric, total_sales bigint, total_cost numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH returned_quantities AS (
        SELECT sale_item_id, SUM(quantity) AS returned_qty
        FROM return_items 
        GROUP BY sale_item_id
    ),
    sale_cogs AS (
        SELECT si.sale_id,
               SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00) * si.purchase_price) AS valid_cogs
        FROM sale_items si
        LEFT JOIN returned_quantities rq ON rq.sale_item_id = si.id
        GROUP BY si.sale_id
    ),
    refunded_tax_per_sale AS (
        SELECT r.sale_id, SUM(ri.tax_amount) as total_refunded_tax
        FROM returns r 
        JOIN return_items ri ON r.id = ri.return_id
        GROUP BY r.sale_id
    )
    SELECT 
        COALESCE(SUM(s.total_amount - COALESCE(s.refund_amount, 0.00)), 0.00) as total_revenue,
        
        COALESCE(SUM(
            (s.total_amount - COALESCE(s.refund_amount, 0.00)) 
            - GREATEST(s.tax_amount - COALESCE(rt.total_refunded_tax, 0.00), 0.00)
            - COALESCE(sc.valid_cogs, 0.00)
        ), 0.00) as total_profit,
        
        COUNT(s.id) as total_sales,
        
        COALESCE(SUM(sc.valid_cogs), 0.00) as total_cost
    FROM sales s
    LEFT JOIN sale_cogs sc ON s.id = sc.sale_id
    LEFT JOIN refunded_tax_per_sale rt ON s.id = rt.sale_id
    WHERE s.shop_id = p_shop_id
      AND s.status IN ('completed', 'partially_refunded')
      AND s.created_at >= p_start_date
      AND s.created_at <= p_end_date;
END;
$$;

DROP FUNCTION IF EXISTS public.get_slow_products(uuid, timestamp with time zone, timestamp with time zone, integer);
CREATE OR REPLACE FUNCTION public.get_slow_products(p_shop_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_limit integer DEFAULT 10)
 RETURNS TABLE(id uuid, name character varying, sales_count numeric, revenue numeric, current_stock numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH returned_quantities AS (
        SELECT sale_item_id, SUM(quantity) AS returned_qty
        FROM return_items
        GROUP BY sale_item_id
    ),
    product_sales AS (
        SELECT 
            p.id,
            SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00)) as valid_qty,
            SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00) * si.unit_price) as gross_sales
        FROM products p
        LEFT JOIN sale_items si ON p.id = si.product_id 
        LEFT JOIN sales s ON si.sale_id = s.id 
            AND s.shop_id = p_shop_id 
            AND s.status IN ('completed', 'partially_refunded')
            AND (p_start_date IS NULL OR s.created_at >= p_start_date)
            AND (p_end_date IS NULL OR s.created_at <= p_end_date)
        LEFT JOIN returned_quantities rq ON rq.sale_item_id = si.id
        WHERE p.shop_id = p_shop_id
        GROUP BY p.id
    )
    SELECT 
        p.id,
        p.name,
        COALESCE(ps.valid_qty, 0.00)::NUMERIC(12,3) as sales_count,
        COALESCE(ps.gross_sales, 0.00)::NUMERIC(12,2) as revenue,
        p.current_stock::NUMERIC(12,3)
    FROM products p
    LEFT JOIN product_sales ps ON p.id = ps.id
    WHERE p.shop_id = p_shop_id
    ORDER BY sales_count ASC, p.current_stock DESC
    LIMIT p_limit;
END;
$$;

DROP FUNCTION IF EXISTS public.get_top_products(uuid, timestamp with time zone, timestamp with time zone, integer);
CREATE OR REPLACE FUNCTION public.get_top_products(p_shop_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_limit integer DEFAULT 10)
 RETURNS TABLE(id uuid, name character varying, sales_count numeric, revenue numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH returned_quantities AS (
        SELECT sale_item_id, SUM(quantity) AS returned_qty
        FROM return_items
        GROUP BY sale_item_id
    )
    SELECT 
        p.id,
        p.name,
        SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00))::NUMERIC(12,3) as sales_count,
        SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00) * si.unit_price)::NUMERIC(12,2) as revenue
    FROM products p
    JOIN sale_items si ON p.id = si.product_id
    JOIN sales s ON si.sale_id = s.id
    LEFT JOIN returned_quantities rq ON rq.sale_item_id = si.id
    WHERE s.shop_id = p_shop_id
      AND s.status IN ('completed', 'partially_refunded')
      AND (p_start_date IS NULL OR s.created_at >= p_start_date)
      AND (p_end_date IS NULL OR s.created_at <= p_end_date)
    GROUP BY p.id, p.name
    HAVING SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00)) > 0
    ORDER BY sales_count DESC, revenue DESC
    LIMIT p_limit;
END;
$$;
