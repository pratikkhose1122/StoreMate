-- Add settings columns using IF NOT EXISTS logic
-- PostgreSQL doesn't support IF NOT EXISTS directly for ADD COLUMN in standard ALTER TABLE prior to v15 or requires a DO block for older versions if we want to be absolutely safe, 
-- but let's write a standard idempotent DO block to add columns if they don't exist.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shops' AND column_name = 'logo_url') THEN
        ALTER TABLE shops ADD COLUMN logo_url VARCHAR(500);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shops' AND column_name = 'gst_number') THEN
        ALTER TABLE shops ADD COLUMN gst_number VARCHAR(50);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shops' AND column_name = 'business_type') THEN
        ALTER TABLE shops ADD COLUMN business_type VARCHAR(100);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'shops' AND column_name = 'invoice_prefix') THEN
        ALTER TABLE shops ADD COLUMN invoice_prefix VARCHAR(10) DEFAULT 'INV';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'sales' AND column_name = 'shop_gst_snapshot') THEN
        ALTER TABLE sales ADD COLUMN shop_gst_snapshot VARCHAR(50);
    END IF;
END $$;
