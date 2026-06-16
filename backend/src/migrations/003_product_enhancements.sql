-- Migration 003: Product Enhancements

-- 1. Add tax_percentage column for future billing support
ALTER TABLE products ADD COLUMN tax_percentage DECIMAL(5,2) DEFAULT 0;

-- 2. Ensure image_url exists (if it wasn't added properly in 002)
ALTER TABLE products ADD COLUMN IF NOT EXISTS image_url VARCHAR(255);
