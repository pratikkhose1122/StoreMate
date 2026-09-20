-- ============================================================
-- StoreMate SaaS — Add Product Brand and Size
-- Migration: 006_add_product_brand_size.sql
-- Description: Adds brand and package_size to products table
-- ============================================================

ALTER TABLE products 
ADD COLUMN IF NOT EXISTS brand VARCHAR(255),
ADD COLUMN IF NOT EXISTS package_size VARCHAR(100);
