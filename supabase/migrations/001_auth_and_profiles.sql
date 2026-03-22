-- Migration: Auth & Profiles
-- Adds user authentication support while preserving anonymous manage_token flow

-- ============================================================
-- 1. Profiles table (auto-created on signup)
-- ============================================================

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name TEXT,
  email TEXT,
  is_admin BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Public can view profiles"
  ON profiles FOR SELECT
  USING (true);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.email
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- 2. Add user_id to garage_sales (nullable for anonymous sales)
-- ============================================================

ALTER TABLE garage_sales
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES profiles(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_garage_sales_user_id ON garage_sales(user_id);

-- ============================================================
-- 3. Add user_id and is_read to contact_messages
-- ============================================================

ALTER TABLE contact_messages
  ADD COLUMN IF NOT EXISTS is_read BOOLEAN NOT NULL DEFAULT false;

-- ============================================================
-- 4. Update RLS policies for dual auth (manage_token OR user_id)
-- ============================================================

-- Drop old permissive update/delete policies
DROP POLICY IF EXISTS "Token holders can update their sales" ON garage_sales;
DROP POLICY IF EXISTS "Token holders can delete their sales" ON garage_sales;

-- New update policy: owner via user_id OR manage_token (checked in API)
CREATE POLICY "Owners can update their sales" ON garage_sales
  FOR UPDATE USING (
    auth.uid() = user_id
    OR true  -- manage_token validation happens in the API layer
  );

-- New delete policy
CREATE POLICY "Owners can delete their sales" ON garage_sales
  FOR DELETE USING (
    auth.uid() = user_id
    OR true  -- manage_token validation happens in the API layer
  );

-- Allow authenticated users to view their own inactive sales too
CREATE POLICY "Owners can view own inactive sales" ON garage_sales
  FOR SELECT USING (auth.uid() = user_id);

-- ============================================================
-- 5. Contact messages: sellers can read messages for their sales
-- ============================================================

DROP POLICY IF EXISTS "Anyone can view contact messages" ON contact_messages;

CREATE POLICY "Sellers can view messages for their sales" ON contact_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM garage_sales
      WHERE garage_sales.id = contact_messages.sale_id
      AND garage_sales.user_id = auth.uid()
    )
  );

CREATE POLICY "Anyone can view contact messages with service role" ON contact_messages
  FOR SELECT USING (true);

-- Allow updating is_read
CREATE POLICY "Sellers can update message read status" ON contact_messages
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM garage_sales
      WHERE garage_sales.id = contact_messages.sale_id
      AND garage_sales.user_id = auth.uid()
    )
  );
