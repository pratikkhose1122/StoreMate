-- ============================================================
-- StoreMate SaaS — Initial Database Schema
-- Migration: 001_initial_schema.sql
-- Description: Creates shops and users tables with all
--              indexes, constraints, and audit fields.
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Sequence for auto-generating shop codes (STM-0001, STM-0002, ...)
CREATE SEQUENCE IF NOT EXISTS shop_code_seq START 1;

-- ──────────────────────────────────────────────────────────────
-- Table: shops
-- ──────────────────────────────────────────────────────────────
CREATE TABLE shops (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_code           VARCHAR(20)     UNIQUE NOT NULL,
    name                VARCHAR(255)    NOT NULL,
    owner_name          VARCHAR(255)    NOT NULL,
    mobile_number       VARCHAR(15),
    email               VARCHAR(255),
    address             TEXT,
    business_type       VARCHAR(50)     NOT NULL DEFAULT 'general'
                        CHECK (business_type IN (
                            'kirana',
                            'electronics',
                            'clothing',
                            'hardware',
                            'pharmacy',
                            'restaurant',
                            'general',
                            'other'
                        )),
    is_active           BOOLEAN         NOT NULL DEFAULT true,
    subscription_status VARCHAR(20)     NOT NULL DEFAULT 'free',
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- ──────────────────────────────────────────────────────────────
-- Table: users
-- ──────────────────────────────────────────────────────────────
CREATE TABLE users (
    id                  UUID            PRIMARY KEY DEFAULT gen_random_uuid(),
    shop_id             UUID            REFERENCES shops(id) ON DELETE SET NULL,
    mobile_number       VARCHAR(15)     NOT NULL UNIQUE,
    firebase_uid        VARCHAR(128)    NOT NULL UNIQUE,
    role                VARCHAR(20)     NOT NULL DEFAULT 'owner'
                        CHECK (role IN ('owner', 'manager', 'staff')),
    is_active           BOOLEAN         NOT NULL DEFAULT true,
    last_login_at       TIMESTAMPTZ,
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    deleted_at          TIMESTAMPTZ
);

-- ──────────────────────────────────────────────────────────────
-- Indexes
-- ──────────────────────────────────────────────────────────────

-- Users lookups
CREATE INDEX idx_users_shop_id        ON users(shop_id);
CREATE INDEX idx_users_mobile_number  ON users(mobile_number);
CREATE INDEX idx_users_firebase_uid   ON users(firebase_uid);

-- Shops lookups
CREATE INDEX idx_shops_shop_code      ON shops(shop_code);

-- Partial indexes for soft-delete filtering (only index non-deleted rows)
CREATE INDEX idx_shops_active         ON shops(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_active         ON users(deleted_at) WHERE deleted_at IS NULL;

-- ──────────────────────────────────────────────────────────────
-- Trigger: auto-update updated_at on row modification
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_shops_updated_at
    BEFORE UPDATE ON shops
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
