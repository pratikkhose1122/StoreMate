-- 014_shop_timezone_semantics.sql
-- Phase 2G: Timezone + Transaction Semantics Remediation

-- 1. Add IANA timezone source of truth to shops
ALTER TABLE shops ADD COLUMN IF NOT EXISTS timezone TEXT NOT NULL DEFAULT 'Asia/Kolkata';

-- 2. get_dashboard_summary
DROP FUNCTION IF EXISTS public.get_dashboard_summary(uuid, timestamp with time zone);
CREATE OR REPLACE FUNCTION public.get_dashboard_summary(p_shop_id uuid, p_start_date timestamp with time zone DEFAULT (now() - '30 days'::interval))
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$
DECLARE
    v_total_sales_count INT;
    v_total_revenue NUMERIC(12,2) := 0.00;
    v_total_profit NUMERIC(12,2) := 0.00;
    v_avg_bill NUMERIC(12,2) := 0.00;
    
    v_total_categories INT;
    v_total_products INT;
    v_out_of_stock INT;
    v_low_stock INT;
    v_inventory_value NUMERIC(12,2) := 0.00;
    
    v_firebase_uid VARCHAR;
BEGIN
    -- Shop Authorization
    v_firebase_uid := COALESCE(
        (current_setting('request.jwt.claims', true)::jsonb)->>'firebase_uid',
        current_setting('request.jwt.claim.firebase_uid', true)
    );
    IF v_firebase_uid IS NULL OR NOT EXISTS (
        SELECT 1 FROM users WHERE firebase_uid = v_firebase_uid AND shop_id = p_shop_id
    ) THEN
        RAISE EXCEPTION 'Unauthorized: You do not have permission to access this shop.' USING ERRCODE = 'P0001';
    END IF;

    -- A. Transaction Counting: All successfully completed bills, even if later refunded.
    SELECT COUNT(id) INTO v_total_sales_count
    FROM sales
    WHERE shop_id = p_shop_id 
      AND status IN ('completed', 'partially_refunded', 'fully_refunded')
      AND created_at >= p_start_date;

    -- B. Financial Aggregation: Only retained financial value from non-fully refunded sales.
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
        COALESCE(SUM(s.total_amount - COALESCE(s.refund_amount, 0.00)), 0.00),
        COALESCE(SUM(
            (s.total_amount - COALESCE(s.refund_amount, 0.00)) 
            - GREATEST(s.tax_amount - COALESCE(rt.total_refunded_tax, 0.00), 0.00)
            - COALESCE(sc.valid_cogs, 0.00)
        ), 0.00)
    INTO v_total_revenue, v_total_profit
    FROM sales s 
    LEFT JOIN sale_cogs sc ON s.id = sc.sale_id
    LEFT JOIN refunded_tax_per_sale rt ON s.id = rt.sale_id
    WHERE s.shop_id = p_shop_id 
      AND s.status IN ('completed', 'partially_refunded') 
      AND s.created_at >= p_start_date;

    -- C. Average Bill
    IF v_total_sales_count > 0 THEN
        v_avg_bill := v_total_revenue / v_total_sales_count;
    END IF;

    -- D. Stock Health
    SELECT COUNT(*) INTO v_total_categories FROM categories WHERE shop_id = p_shop_id;
    SELECT COUNT(*) INTO v_total_products FROM products WHERE shop_id = p_shop_id;
    SELECT COUNT(*) INTO v_out_of_stock FROM products WHERE shop_id = p_shop_id AND current_stock <= 0;
    SELECT COUNT(*) INTO v_low_stock FROM products WHERE shop_id = p_shop_id AND current_stock > 0 AND current_stock <= low_stock_threshold;
    SELECT COALESCE(SUM(current_stock * purchase_price), 0.00) INTO v_inventory_value FROM products WHERE shop_id = p_shop_id AND current_stock > 0;

    RETURN jsonb_build_object(
        'todays_sales', v_total_revenue,
        'todays_profit', v_total_profit,
        'total_sales_count', v_total_sales_count,
        'average_bill', v_avg_bill,
        'total_categories', v_total_categories,
        'total_products', v_total_products,
        'out_of_stock_products', v_out_of_stock,
        'low_stock_products', v_low_stock,
        'inventory_value', v_inventory_value
    );
END;
$$;

-- 3. get_sales_metrics
DROP FUNCTION IF EXISTS public.get_sales_metrics(uuid, timestamp with time zone, timestamp with time zone);
CREATE OR REPLACE FUNCTION public.get_sales_metrics(p_shop_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone)
 RETURNS TABLE(total_revenue numeric, total_profit numeric, total_sales bigint, total_cost numeric, average_bill numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$
DECLARE
    v_firebase_uid VARCHAR;
BEGIN
    -- Shop Authorization
    v_firebase_uid := COALESCE(
        (current_setting('request.jwt.claims', true)::jsonb)->>'firebase_uid',
        current_setting('request.jwt.claim.firebase_uid', true)
    );
    IF v_firebase_uid IS NULL OR NOT EXISTS (
        SELECT 1 FROM users WHERE firebase_uid = v_firebase_uid AND shop_id = p_shop_id
    ) THEN
        RAISE EXCEPTION 'Unauthorized: You do not have permission to access this shop.' USING ERRCODE = 'P0001';
    END IF;

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
    ),
    aggregated_metrics AS (
        SELECT 
            COALESCE(SUM(s.total_amount - COALESCE(s.refund_amount, 0.00)), 0.00) as revenue,
            COALESCE(SUM(
                (s.total_amount - COALESCE(s.refund_amount, 0.00)) 
                - GREATEST(s.tax_amount - COALESCE(rt.total_refunded_tax, 0.00), 0.00)
                - COALESCE(sc.valid_cogs, 0.00)
            ), 0.00) as profit,
            COALESCE(SUM(sc.valid_cogs), 0.00) as cost
        FROM sales s
        LEFT JOIN sale_cogs sc ON s.id = sc.sale_id
        LEFT JOIN refunded_tax_per_sale rt ON s.id = rt.sale_id
        WHERE s.shop_id = p_shop_id
          AND s.status IN ('completed', 'partially_refunded')
          AND s.created_at >= p_start_date
          AND s.created_at <= p_end_date
    ),
    transaction_count AS (
        SELECT COUNT(id) as bills
        FROM sales
        WHERE shop_id = p_shop_id
          AND status IN ('completed', 'partially_refunded', 'fully_refunded')
          AND created_at >= p_start_date
          AND created_at <= p_end_date
    )
    SELECT 
        am.revenue::NUMERIC(12,2),
        am.profit::NUMERIC(12,2),
        tc.bills::BIGINT,
        am.cost::NUMERIC(12,2),
        (CASE WHEN tc.bills > 0 THEN am.revenue / tc.bills ELSE 0.00 END)::NUMERIC(12,2) as average_bill
    FROM aggregated_metrics am, transaction_count tc;
END;
$$;

-- 4. get_daily_sales_metrics
DROP FUNCTION IF EXISTS public.get_daily_sales_metrics(uuid, timestamp with time zone, timestamp with time zone);
CREATE OR REPLACE FUNCTION public.get_daily_sales_metrics(p_shop_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone)
 RETURNS TABLE(report_date date, daily_revenue numeric, daily_profit numeric)
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $$
DECLARE
    v_firebase_uid VARCHAR;
    v_timezone TEXT;
BEGIN
    -- Shop Authorization and Timezone Fetch
    v_firebase_uid := COALESCE(
        (current_setting('request.jwt.claims', true)::jsonb)->>'firebase_uid',
        current_setting('request.jwt.claim.firebase_uid', true)
    );
    IF v_firebase_uid IS NULL OR NOT EXISTS (
        SELECT 1 FROM users WHERE firebase_uid = v_firebase_uid AND shop_id = p_shop_id
    ) THEN
        RAISE EXCEPTION 'Unauthorized: You do not have permission to access this shop.' USING ERRCODE = 'P0001';
    END IF;

    SELECT timezone INTO v_timezone FROM shops WHERE id = p_shop_id;
    IF v_timezone IS NULL THEN v_timezone := 'Asia/Kolkata'; END IF;

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
    ),
    daily_sales AS (
        SELECT 
            (s.created_at AT TIME ZONE v_timezone)::DATE AS bucket_date,
            (s.total_amount - COALESCE(s.refund_amount, 0.00)) AS retained_revenue,
            GREATEST(s.tax_amount - COALESCE(rt.total_refunded_tax, 0.00), 0.00) AS retained_tax,
            COALESCE(sc.valid_cogs, 0.00) AS retained_cogs
        FROM sales s
        LEFT JOIN sale_cogs sc ON s.id = sc.sale_id
        LEFT JOIN refunded_tax_per_sale rt ON s.id = rt.sale_id
        WHERE s.shop_id = p_shop_id
          AND s.status IN ('completed', 'partially_refunded')
          AND s.created_at >= p_start_date
          AND s.created_at <= p_end_date
    )
    SELECT 
        bucket_date,
        SUM(retained_revenue)::NUMERIC(12,2) AS daily_revenue,
        SUM(retained_revenue - retained_tax - retained_cogs)::NUMERIC(12,2) AS daily_profit
    FROM daily_sales
    GROUP BY bucket_date
    ORDER BY bucket_date ASC;
END;
$$;

-- 5. get_top_products
DROP FUNCTION IF EXISTS public.get_top_products(uuid, timestamp with time zone, timestamp with time zone, integer);
CREATE OR REPLACE FUNCTION public.get_top_products(p_shop_id uuid, p_start_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_end_date timestamp with time zone DEFAULT NULL::timestamp with time zone, p_limit integer DEFAULT 10)
 RETURNS TABLE(id uuid, name character varying, sales_count numeric, revenue numeric, profit numeric)
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
    valid_sale_items AS (
        SELECT 
            si.product_id,
            si.product_name,
            si.unit_price,
            si.purchase_price,
            si.tax_percentage,
            GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00) AS valid_qty
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        LEFT JOIN returned_quantities rq ON rq.sale_item_id = si.id
        WHERE s.shop_id = p_shop_id
          AND s.status IN ('completed', 'partially_refunded')
          AND (p_start_date IS NULL OR s.created_at >= p_start_date)
          AND (p_end_date IS NULL OR s.created_at <= p_end_date)
    )
    SELECT 
        v.product_id AS id,
        v.product_name AS name,
        SUM(v.valid_qty)::NUMERIC(12,3) AS sales_count,
        SUM(v.valid_qty * v.unit_price)::NUMERIC(12,2) AS revenue,
        SUM((v.valid_qty * v.unit_price) - (v.valid_qty * v.unit_price * (v.tax_percentage / 100.0)) - (v.valid_qty * v.purchase_price))::NUMERIC(12,2) AS profit
    FROM valid_sale_items v
    WHERE v.valid_qty > 0
    GROUP BY v.product_id, v.product_name
    ORDER BY sales_count DESC, revenue DESC
    LIMIT p_limit;
END;
$$;

-- 6. get_slow_products
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
    valid_sale_items AS (
        SELECT 
            si.product_id,
            GREATEST(si.quantity - COALESCE(rq.returned_qty, 0.00), 0.00) AS valid_qty,
            si.unit_price
        FROM sale_items si
        JOIN sales s ON s.id = si.sale_id
        LEFT JOIN returned_quantities rq ON rq.sale_item_id = si.id
        WHERE s.shop_id = p_shop_id
          AND s.status IN ('completed', 'partially_refunded')
          AND (p_start_date IS NULL OR s.created_at >= p_start_date)
          AND (p_end_date IS NULL OR s.created_at <= p_end_date)
    ),
    product_stats AS (
        SELECT 
            v.product_id,
            SUM(v.valid_qty) AS total_qty_sold,
            SUM(v.valid_qty * v.unit_price) AS total_revenue
        FROM valid_sale_items v
        GROUP BY v.product_id
    )
    SELECT 
        p.id,
        p.name,
        COALESCE(ps.total_qty_sold, 0.00)::NUMERIC(12,3) AS sales_count,
        COALESCE(ps.total_revenue, 0.00)::NUMERIC(12,2) AS revenue,
        p.current_stock::NUMERIC(12,3)
    FROM products p
    LEFT JOIN product_stats ps ON p.id = ps.product_id
    WHERE p.shop_id = p_shop_id
    ORDER BY sales_count ASC, p.current_stock DESC
    LIMIT p_limit;
END;
$$;
