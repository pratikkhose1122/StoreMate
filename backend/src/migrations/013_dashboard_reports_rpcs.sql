-- 013_dashboard_reports_rpcs.sql
-- Phase 2G: Dashboard & Reports Canonical RPCs

-- 1. get_low_stock_list
-- Enforces numeric comparison and limits.
-- Preserves existing StoreMate business rule:
--   Out of Stock / Negative: current_stock <= 0
--   Low Stock: current_stock > 0 AND current_stock <= low_stock_threshold
DROP FUNCTION IF EXISTS public.get_low_stock_list(uuid, integer);
CREATE OR REPLACE FUNCTION public.get_low_stock_list(p_shop_id uuid, p_limit integer DEFAULT 10)
 RETURNS TABLE(id uuid, name character varying, current_stock numeric, low_stock_threshold integer, selling_price numeric)
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

    -- Limit Validation
    IF p_limit < 1 OR p_limit > 100 THEN
        RAISE EXCEPTION 'Invalid limit parameter. Must be between 1 and 100.' USING ERRCODE = 'P0002';
    END IF;

    RETURN QUERY
    SELECT 
        p.id,
        p.name,
        p.current_stock::NUMERIC(12,3),
        p.low_stock_threshold::INTEGER,
        p.selling_price::NUMERIC(12,2)
    FROM products p
    WHERE p.shop_id = p_shop_id
      AND p.current_stock > 0 
      AND p.current_stock <= p.low_stock_threshold
    ORDER BY p.current_stock ASC
    LIMIT p_limit;
END;
$$;

-- 2. get_daily_sales_metrics
-- Returns a server-side daily time series for charts without fetching raw sales into Dart.
-- Groups by 24-hour periods starting from p_start_date to ensure timezone-agnostic local day bucketing matching the client's date filter.
-- Uses the exact same financial semantics as the verified get_sales_metrics RPC.
DROP FUNCTION IF EXISTS public.get_daily_sales_metrics(uuid, timestamp with time zone, timestamp with time zone);
CREATE OR REPLACE FUNCTION public.get_daily_sales_metrics(p_shop_id uuid, p_start_date timestamp with time zone, p_end_date timestamp with time zone)
 RETURNS TABLE(report_date date, daily_revenue numeric, daily_profit numeric)
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
    daily_sales AS (
        SELECT 
            -- Calculate bucket day dynamically from start date to respect local client timezone boundaries
            (p_start_date + (floor(EXTRACT(EPOCH FROM (s.created_at - p_start_date)) / 86400) * interval '1 day'))::DATE AS bucket_date,
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
