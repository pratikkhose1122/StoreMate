-- Discovered RPCs from live database

CREATE OR REPLACE FUNCTION public.get_dashboard_summary(p_shop_id uuid, p_start_date timestamp with time zone)
 RETURNS TABLE(todays_sales numeric, todays_profit numeric, total_sales_count bigint, total_categories bigint, total_products bigint, out_of_stock_products bigint, low_stock_products bigint, inventory_value numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    WITH returned_quantities AS (
        SELECT sale_item_id, SUM(quantity) AS returned_qty
        FROM return_items 
        GROUP BY sale_item_id
    ),
    sale_cogs AS (
        SELECT si.sale_id,
               SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0), 0) * si.purchase_price) AS valid_cogs
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
            SELECT SUM(s.total_amount - COALESCE(s.refund_amount, 0)) 
            FROM sales s 
            WHERE s.shop_id = p_shop_id 
              AND s.status IN ('completed', 'partially_refunded') 
              AND s.created_at >= p_start_date
        ), 0.0) as todays_sales,
        
        COALESCE((
            SELECT SUM(
                (s.total_amount - COALESCE(s.refund_amount, 0)) 
                - GREATEST(s.tax_amount - COALESCE(rt.total_refunded_tax, 0), 0)
                - COALESCE(sc.valid_cogs, 0)
            )
            FROM sales s 
            LEFT JOIN sale_cogs sc ON s.id = sc.sale_id
            LEFT JOIN refunded_tax_per_sale rt ON s.id = rt.sale_id
            WHERE s.shop_id = p_shop_id 
              AND s.status IN ('completed', 'partially_refunded') 
              AND s.created_at >= p_start_date
        ), 0.0) as todays_profit,
        
        (SELECT COUNT(*) FROM sales WHERE shop_id = p_shop_id AND status IN ('completed', 'partially_refunded') AND created_at >= p_start_date) as total_sales_count,
        (SELECT COUNT(*) FROM categories WHERE shop_id = p_shop_id) as total_categories,
        (SELECT COUNT(*) FROM products WHERE shop_id = p_shop_id) as total_products,
        (SELECT COUNT(*) FROM products WHERE shop_id = p_shop_id AND current_stock <= 0) as out_of_stock_products,
        (SELECT COUNT(*) FROM products WHERE shop_id = p_shop_id AND current_stock > 0 AND current_stock <= low_stock_threshold) as low_stock_products,
        COALESCE((SELECT SUM(current_stock * purchase_price) FROM products WHERE shop_id = p_shop_id AND current_stock > 0), 0.0) as inventory_value;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_sales_metrics(p_shop_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone)
 RETURNS TABLE(total_revenue numeric, total_profit numeric, total_sales bigint, total_cost numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
    RETURN QUERY
    WITH returned_quantities AS (
        SELECT sale_item_id, SUM(quantity) AS returned_qty
        FROM return_items 
        GROUP BY sale_item_id
    ),
    sale_cogs AS (
        SELECT si.sale_id,
               SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0), 0) * si.purchase_price) AS valid_cogs
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
        COALESCE(SUM(s.total_amount - COALESCE(s.refund_amount, 0)), 0.0) as total_revenue,
        
        COALESCE(SUM(
            (s.total_amount - COALESCE(s.refund_amount, 0)) 
            - GREATEST(s.tax_amount - COALESCE(rt.total_refunded_tax, 0), 0)
            - COALESCE(sc.valid_cogs, 0)
        ), 0.0) as total_profit,
        
        COUNT(s.id) as total_sales,
        
        COALESCE(SUM(sc.valid_cogs), 0.0) as total_cost
    FROM sales s
    LEFT JOIN sale_cogs sc ON s.id = sc.sale_id
    LEFT JOIN refunded_tax_per_sale rt ON s.id = rt.sale_id
    WHERE s.shop_id = p_shop_id
      AND s.status IN ('completed', 'partially_refunded')
      AND s.created_at >= p_start_date
      AND s.created_at <= p_end_date;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_slow_products(p_shop_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_limit integer DEFAULT 10)
 RETURNS TABLE(id uuid, name character varying, sales_count bigint, revenue numeric, current_stock integer)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
            SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0), 0)) as valid_qty,
            SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0), 0) * si.unit_price) as gross_sales
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
        COALESCE(ps.valid_qty, 0)::BIGINT as sales_count,
        COALESCE(ps.gross_sales, 0.0) as revenue,
        p.current_stock
    FROM products p
    LEFT JOIN product_sales ps ON p.id = ps.id
    WHERE p.shop_id = p_shop_id
    ORDER BY sales_count ASC, p.current_stock DESC
    LIMIT p_limit;
END;
$function$;

CREATE OR REPLACE FUNCTION public.get_top_products(p_shop_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_limit integer DEFAULT 10)
 RETURNS TABLE(id uuid, name character varying, sales_count bigint, revenue numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
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
        SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0), 0))::BIGINT as sales_count,
        SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0), 0) * si.unit_price) as revenue -- Gross Item Sales
    FROM products p
    JOIN sale_items si ON p.id = si.product_id
    JOIN sales s ON si.sale_id = s.id
    LEFT JOIN returned_quantities rq ON rq.sale_item_id = si.id
    WHERE s.shop_id = p_shop_id
      AND s.status IN ('completed', 'partially_refunded')
      AND (p_start_date IS NULL OR s.created_at >= p_start_date)
      AND (p_end_date IS NULL OR s.created_at <= p_end_date)
    GROUP BY p.id, p.name
    HAVING SUM(GREATEST(si.quantity - COALESCE(rq.returned_qty, 0), 0)) > 0
    ORDER BY sales_count DESC, revenue DESC
    LIMIT p_limit;
END;
$function$;

CREATE OR REPLACE FUNCTION public.process_refund(p_shop_id uuid, p_sale_id uuid, p_user_id uuid, p_refund_method text, p_reason text, p_notes text, p_items jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_return_id UUID;
    v_item JSONB;
    v_total_refund NUMERIC := 0;
    v_sale_status TEXT;
    v_sale_total NUMERIC;
    v_sale_refunded NUMERIC;
    v_customer_id UUID;
    v_sale_item_id UUID;
    v_product_id UUID;
    v_quantity INT;
    v_refunded_qty INT;
    v_original_qty INT;
BEGIN
    -- 1. Lock the sale record to prevent race conditions
    SELECT total_amount, refund_amount, customer_id 
    INTO v_sale_total, v_sale_refunded, v_customer_id
    FROM sales
    WHERE id = p_sale_id AND shop_id = p_shop_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Sale not found or does not belong to shop';
    END IF;

    -- Generate return ID
    v_return_id := gen_random_uuid();
    
    -- Insert return record
    INSERT INTO returns (id, sale_id, shop_id, customer_id, refund_number, refund_amount, refund_method, reason, notes, created_by)
    VALUES (v_return_id, p_sale_id, p_shop_id, v_customer_id, 'REF-' || substr(md5(random()::text), 1, 8), 0, p_refund_method, p_reason, p_notes, p_user_id);

    -- Process items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_sale_item_id := (v_item->>'sale_item_id')::UUID;
        
        -- Handle missing product_id for manual items
        IF (v_item->>'product_id') IS NOT NULL AND (v_item->>'product_id') != 'null' THEN
           v_product_id := (v_item->>'product_id')::UUID;
        ELSE
           v_product_id := NULL;
        END IF;

        v_quantity := (v_item->>'quantity')::INT;

        -- Validate quantities
        SELECT quantity INTO v_original_qty FROM sale_items WHERE id = v_sale_item_id FOR UPDATE;
        
        SELECT COALESCE(SUM(quantity), 0) INTO v_refunded_qty 
        FROM return_items ri 
        JOIN returns r ON ri.return_id = r.id 
        WHERE ri.sale_item_id = v_sale_item_id AND r.sale_id = p_sale_id;

        IF (v_refunded_qty + v_quantity) > v_original_qty THEN
            RAISE EXCEPTION 'Cannot refund more than purchased quantity for item %', v_sale_item_id;
        END IF;

        -- Insert return item
        INSERT INTO return_items (return_id, sale_item_id, product_id, quantity, unit_price, tax_amount, discount_amount, line_total)
        VALUES (
            v_return_id,
            v_sale_item_id,
            v_product_id,
            v_quantity,
            (v_item->>'unit_price')::NUMERIC,
            (v_item->>'tax_amount')::NUMERIC,
            (v_item->>'discount_amount')::NUMERIC,
            (v_item->>'line_total')::NUMERIC
        );

        v_total_refund := v_total_refund + (v_item->>'line_total')::NUMERIC;

        -- Restore stock (ONLY if product_id is not null)
        IF v_product_id IS NOT NULL THEN
            UPDATE products 
            SET stock_quantity = stock_quantity + v_quantity
            WHERE id = v_product_id;
        END IF;
    END LOOP;

    -- Update return total
    UPDATE returns SET refund_amount = v_total_refund WHERE id = v_return_id;

    -- Update sale total & status
    v_sale_refunded := v_sale_refunded + v_total_refund;
    
    -- If they refunded 99.9% of the bill, consider it fully refunded to account for float math issues
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
$function$;

CREATE OR REPLACE FUNCTION public.process_refund(p_shop_id uuid, p_sale_id uuid, p_user_id uuid, p_original_payment_method text, p_refund_payment_method text, p_reason text, p_notes text, p_items jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_return_id UUID;
    v_item JSONB;
    v_total_refund NUMERIC := 0;
    v_sale_status TEXT;
    v_sale_total NUMERIC;
    v_sale_refunded NUMERIC;
    v_customer_id UUID;
    v_sale_item_id UUID;
    v_product_id UUID;
    v_quantity INT;
    v_refunded_qty INT;
    v_original_qty INT;
    v_user_role TEXT;
    v_refund_number TEXT;
BEGIN
    -- 1. Enforce RBAC
    SELECT role INTO v_user_role FROM users WHERE id = p_user_id;
    IF v_user_role NOT IN ('owner', 'manager') THEN
        RAISE EXCEPTION 'Unauthorized: Only owners or managers can process refunds.';
    END IF;

    -- 2. Lock sale and validate
    SELECT total_amount, refund_amount, customer_id, status 
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

    -- Generate Refund Number: RF-YYYYMMDD-XXXXX
    v_refund_number := 'RF-' || to_char(NOW(), 'YYYYMMDD') || '-' || lpad(floor(random() * 100000)::text, 5, '0');
    v_return_id := gen_random_uuid();
    
    -- Insert return record
    INSERT INTO returns (id, sale_id, shop_id, customer_id, refund_number, refund_amount, refund_method, reason, notes, created_by)
    VALUES (v_return_id, p_sale_id, p_shop_id, v_customer_id, v_refund_number, 0, p_refund_payment_method, p_reason, p_notes, p_user_id);

    -- Process items
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_sale_item_id := (v_item->>'sale_item_id')::UUID;
        
        -- Handle missing product_id for manual items
        IF (v_item->>'product_id') IS NOT NULL AND (v_item->>'product_id') != 'null' THEN
           v_product_id := (v_item->>'product_id')::UUID;
        ELSE
           v_product_id := NULL;
        END IF;

        v_quantity := (v_item->>'quantity')::INT;
        IF v_quantity <= 0 THEN
            RAISE EXCEPTION 'Refund quantity must be greater than zero.';
        END IF;

        -- Validate quantities
        SELECT quantity INTO v_original_qty FROM sale_items WHERE id = v_sale_item_id FOR UPDATE;
        
        SELECT COALESCE(SUM(quantity), 0) INTO v_refunded_qty 
        FROM return_items ri 
        JOIN returns r ON ri.return_id = r.id 
        WHERE ri.sale_item_id = v_sale_item_id AND r.sale_id = p_sale_id;

        IF (v_refunded_qty + v_quantity) > v_original_qty THEN
            RAISE EXCEPTION 'Cannot refund more than purchased quantity for item %', v_sale_item_id;
        END IF;

        -- Insert return item
        INSERT INTO return_items (return_id, sale_item_id, product_id, quantity, unit_price, tax_amount, discount_amount, line_total)
        VALUES (
            v_return_id,
            v_sale_item_id,
            v_product_id,
            v_quantity,
            (v_item->>'unit_price')::NUMERIC,
            (v_item->>'tax_amount')::NUMERIC,
            (v_item->>'discount_amount')::NUMERIC,
            (v_item->>'line_total')::NUMERIC
        );

        v_total_refund := v_total_refund + (v_item->>'line_total')::NUMERIC;

        -- Restore stock and log movement (ONLY if product_id is not null)
        IF v_product_id IS NOT NULL THEN
            DECLARE 
                v_prev_stock INT;
            BEGIN
                SELECT stock_quantity INTO v_prev_stock FROM products WHERE id = v_product_id FOR UPDATE;
                
                UPDATE products 
                SET stock_quantity = stock_quantity + v_quantity
                WHERE id = v_product_id;
                
                INSERT INTO inventory_movements (product_id, shop_id, type, previous_stock, new_stock, quantity_changed, reference_type, reference_id, created_by)
                VALUES (v_product_id, p_shop_id, 'refund', v_prev_stock, v_prev_stock + v_quantity, v_quantity, 'return', v_return_id, p_user_id);
            END;
        END IF;
    END LOOP;

    -- Update return total
    UPDATE returns SET refund_amount = v_total_refund WHERE id = v_return_id;

    -- Insert financial transaction for the refund (money leaving)
    INSERT INTO financial_transactions (shop_id, type, invoice_id, return_id, payment_method, amount, direction, created_by)
    VALUES (p_shop_id, 'refund', p_sale_id, v_return_id, p_refund_payment_method, v_total_refund, 'out', p_user_id);

    -- Update sale total & status
    v_sale_refunded := v_sale_refunded + v_total_refund;
    
    -- If they refunded 99.9% of the bill, consider it fully refunded to account for float math issues
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
$function$;

CREATE OR REPLACE FUNCTION public.register_shop(p_shop_code character varying, p_name character varying, p_owner_name character varying, p_mobile_number character varying, p_email character varying, p_address text, p_gstin character varying, p_business_type character varying)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_shop_id UUID;
  v_firebase_uid VARCHAR;
  v_shop JSONB;
BEGIN
  v_firebase_uid := auth.jwt() ->> 'firebase_uid';
  
  IF v_firebase_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Ensure user doesn't already have a shop
  IF (SELECT shop_id FROM users WHERE firebase_uid = v_firebase_uid) IS NOT NULL THEN
    RAISE EXCEPTION 'User already has a shop';
  END IF;

  INSERT INTO shops (
    shop_code, name, owner_name, mobile_number, email, address, gstin, business_type, subscription_status
  ) VALUES (
    p_shop_code, p_name, p_owner_name, p_mobile_number, p_email, p_address, p_gstin, p_business_type, 'active'
  ) RETURNING id INTO v_shop_id;

  UPDATE users 
  SET shop_id = v_shop_id 
  WHERE firebase_uid = v_firebase_uid;

  SELECT to_jsonb(s.*) INTO v_shop FROM shops s WHERE id = v_shop_id;
  RETURN v_shop;
END;
$function$;

CREATE OR REPLACE FUNCTION public.search_sales(search_text text, p_shop_id uuid)
 RETURNS SETOF sales
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT s.*
  FROM sales s
  LEFT JOIN customers c ON s.customer_id = c.id
  WHERE s.shop_id = p_shop_id
    AND (
      s.invoice_number ILIKE '%' || search_text || '%'
      OR c.name ILIKE '%' || search_text || '%'
      OR c.mobile_number ILIKE '%' || search_text || '%'
      OR EXISTS (
        SELECT 1 
        FROM jsonb_array_elements(s.items) AS item 
        WHERE (item->>'productName') ILIKE '%' || search_text || '%'
      )
    )
  ORDER BY s.created_at DESC;
END;
$function$;
