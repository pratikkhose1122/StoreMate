-- Migration 018: Fix SELECT policy for new users

BEGIN;

DROP POLICY IF EXISTS "Users can read shop members" ON users;

CREATE POLICY "Users can read shop members or own record" ON users
  FOR SELECT TO authenticated
  USING (
    firebase_uid = auth.jwt() ->> 'firebase_uid' 
    OR 
    (shop_id IS NOT NULL AND shop_id = auth_shop_id())
  );

COMMIT;
