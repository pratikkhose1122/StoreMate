BEGIN;

-- Create a helper function to get current user's shop_id without triggering RLS recursion
CREATE OR REPLACE FUNCTION auth_shop_id()
RETURNS uuid
SECURITY DEFINER
AS $$
  SELECT shop_id FROM public.users WHERE firebase_uid = (current_setting('request.jwt.claims', true)::json ->> 'firebase_uid') LIMIT 1;
$$ LANGUAGE sql STABLE;

-- Drop the broken policy
DROP POLICY IF EXISTS "Users can read shop members" ON users;

-- Recreate policy using the helper function
CREATE POLICY "Users can read shop members" ON users
  FOR SELECT TO authenticated
  USING (shop_id = auth_shop_id());

DROP POLICY IF EXISTS "Sales isolated by shop" ON sales;

CREATE POLICY "Sales isolated by shop" ON sales
  FOR ALL TO authenticated
  USING (shop_id = auth_shop_id());

-- Prevent users from escalating their role or transferring themselves
REVOKE UPDATE (role, shop_id, is_active) ON users FROM authenticated;

COMMIT;
