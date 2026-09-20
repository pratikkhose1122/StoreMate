-- Phase 2B: Financial Precision Migration

-- 1. Money types to NUMERIC(12,2)
ALTER TABLE customers
  ALTER COLUMN current_credit TYPE numeric(12,2) USING current_credit::numeric(12,2),
  ALTER COLUMN credit_limit TYPE numeric(12,2) USING credit_limit::numeric(12,2);

ALTER TABLE financial_transactions
  ALTER COLUMN amount TYPE numeric(12,2) USING amount::numeric(12,2);

ALTER TABLE products
  ALTER COLUMN purchase_price TYPE numeric(12,2) USING purchase_price::numeric(12,2),
  ALTER COLUMN selling_price TYPE numeric(12,2) USING selling_price::numeric(12,2),
  ALTER COLUMN mrp TYPE numeric(12,2) USING mrp::numeric(12,2);

ALTER TABLE return_items
  ALTER COLUMN unit_price TYPE numeric(12,2) USING unit_price::numeric(12,2),
  ALTER COLUMN tax_amount TYPE numeric(12,2) USING tax_amount::numeric(12,2),
  ALTER COLUMN discount_amount TYPE numeric(12,2) USING discount_amount::numeric(12,2),
  ALTER COLUMN line_total TYPE numeric(12,2) USING line_total::numeric(12,2);

ALTER TABLE returns
  ALTER COLUMN refund_amount TYPE numeric(12,2) USING refund_amount::numeric(12,2);

ALTER TABLE sale_items
  ALTER COLUMN unit_price TYPE numeric(12,2) USING unit_price::numeric(12,2),
  ALTER COLUMN tax_amount TYPE numeric(12,2) USING tax_amount::numeric(12,2),
  ALTER COLUMN total_price TYPE numeric(12,2) USING total_price::numeric(12,2),
  ALTER COLUMN purchase_price TYPE numeric(12,2) USING purchase_price::numeric(12,2);

ALTER TABLE sales
  ALTER COLUMN subtotal TYPE numeric(12,2) USING subtotal::numeric(12,2),
  ALTER COLUMN tax_amount TYPE numeric(12,2) USING tax_amount::numeric(12,2),
  ALTER COLUMN discount_amount TYPE numeric(12,2) USING discount_amount::numeric(12,2),
  ALTER COLUMN total_amount TYPE numeric(12,2) USING total_amount::numeric(12,2),
  ALTER COLUMN paid_amount TYPE numeric(12,2) USING paid_amount::numeric(12,2),
  ALTER COLUMN due_amount TYPE numeric(12,2) USING due_amount::numeric(12,2),
  ALTER COLUMN refund_amount TYPE numeric(12,2) USING COALESCE(refund_amount, 0)::numeric(12,2);

-- 2. Quantity types to NUMERIC(12,3)
ALTER TABLE inventory_logs
  ALTER COLUMN quantity TYPE numeric(12,3) USING quantity::numeric(12,3),
  ALTER COLUMN previous_stock TYPE numeric(12,3) USING previous_stock::numeric(12,3),
  ALTER COLUMN new_stock TYPE numeric(12,3) USING new_stock::numeric(12,3);

ALTER TABLE inventory_movements
  ALTER COLUMN previous_stock TYPE numeric(12,3) USING previous_stock::numeric(12,3),
  ALTER COLUMN new_stock TYPE numeric(12,3) USING new_stock::numeric(12,3),
  ALTER COLUMN quantity_changed TYPE numeric(12,3) USING quantity_changed::numeric(12,3);

ALTER TABLE products
  ALTER COLUMN current_stock TYPE numeric(12,3) USING current_stock::numeric(12,3),
  ALTER COLUMN low_stock_threshold TYPE numeric(12,3) USING low_stock_threshold::numeric(12,3);

ALTER TABLE return_items
  ALTER COLUMN quantity TYPE numeric(12,3) USING quantity::numeric(12,3);

ALTER TABLE sale_items
  ALTER COLUMN quantity TYPE numeric(12,3) USING quantity::numeric(12,3);

-- 3. Enforce strict shop-isolated RLS for previously un-policied tables

ALTER TABLE returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE intent_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Returns isolated by shop" ON returns
  FOR ALL TO authenticated
  USING (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))))
  WITH CHECK (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))));

CREATE POLICY "Return items isolated by shop" ON return_items
  FOR ALL TO authenticated
  USING (return_id IN (SELECT returns.id FROM returns WHERE returns.shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text)))))
  WITH CHECK (return_id IN (SELECT returns.id FROM returns WHERE returns.shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text)))));

CREATE POLICY "Financial transactions isolated by shop" ON financial_transactions
  FOR ALL TO authenticated
  USING (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))))
  WITH CHECK (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))));

CREATE POLICY "Inventory movements isolated by shop" ON inventory_movements
  FOR ALL TO authenticated
  USING (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))))
  WITH CHECK (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))));

CREATE POLICY "Intent log isolated by shop" ON intent_log
  FOR ALL TO authenticated
  USING (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))))
  WITH CHECK (shop_id = (SELECT users.shop_id FROM users WHERE ((users.firebase_uid)::text = (auth.jwt() ->> 'firebase_uid'::text))));
