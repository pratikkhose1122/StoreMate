-- Migration 017: Allow authenticated users to insert their own initial record during signup

BEGIN;

CREATE POLICY "Users can insert own record" ON users
  FOR INSERT TO authenticated
  WITH CHECK (
    firebase_uid = auth.jwt() ->> 'firebase_uid' 
    AND shop_id IS NULL
  );

COMMIT;
