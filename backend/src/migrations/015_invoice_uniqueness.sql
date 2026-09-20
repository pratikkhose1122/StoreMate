-- Phase 2 Final Gate: Canonical Invoice Uniqueness

-- Remove the buggy global constraint if it somehow exists
ALTER TABLE sales DROP CONSTRAINT IF EXISTS sales_invoice_number_key;

-- Apply the canonical multi-tenant constraint
ALTER TABLE sales ADD CONSTRAINT sales_shop_id_invoice_number_key UNIQUE (shop_id, invoice_number);
