-- StoreMate Phase 9: Financial Integrity Schema Fixes

-- 1. Add missing historical purchase price tracking
ALTER TABLE sale_items ADD COLUMN IF NOT EXISTS purchase_price NUMERIC DEFAULT 0;
ALTER TABLE sale_items ADD COLUMN IF NOT EXISTS is_legacy_cost BOOLEAN DEFAULT FALSE;

-- 2. Backfill existing legacy items
UPDATE sale_items si
SET purchase_price = p.purchase_price, is_legacy_cost = TRUE
FROM products p
WHERE si.product_id = p.id AND si.purchase_price = 0;
