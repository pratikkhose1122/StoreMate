-- StoreMate Phase 8: Real Data RPCs for Dashboard and Reports (REWRITTEN FOR FINANCIAL INTEGRITY)

-- RPC: get_top_products
CREATE OR REPLACE FUNCTION get_top_products(
    p_shop_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    name VARCHAR(255),
    sales_count BIGINT,
    revenue DECIMAL
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- RPC: get_dashboard_summary
CREATE OR REPLACE FUNCTION get_dashboard_summary(
    p_shop_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE (
    todays_sales DECIMAL,
    todays_profit DECIMAL,
    total_sales_count BIGINT,
    total_categories BIGINT,
    total_products BIGINT,
    out_of_stock_products BIGINT,
    low_stock_products BIGINT,
    inventory_value DECIMAL
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- RPC: get_sales_metrics
CREATE OR REPLACE FUNCTION get_sales_metrics(
    p_shop_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE,
    p_end_date TIMESTAMP WITH TIME ZONE
)
RETURNS TABLE (
    total_revenue DECIMAL,
    total_profit DECIMAL,
    total_sales BIGINT,
    total_cost DECIMAL
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- RPC: get_slow_products
CREATE OR REPLACE FUNCTION get_slow_products(
    p_shop_id UUID,
    p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    name VARCHAR(255),
    sales_count BIGINT,
    revenue DECIMAL,
    current_stock INTEGER
) AS $$
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
$$ LANGUAGE plpgsql SECURITY DEFINER;
