-- Migration: Admin Dashboard

-- ============================================================
-- 1. Admin actions log
-- ============================================================

CREATE TABLE IF NOT EXISTS admin_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES profiles(id),
  action_type TEXT NOT NULL CHECK (action_type IN ('deactivate', 'reactivate', 'dismiss_report')),
  target_sale_id UUID REFERENCES garage_sales(id),
  target_report_id UUID REFERENCES sale_reports(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE admin_actions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view admin actions" ON admin_actions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
  );

CREATE POLICY "Admins can insert admin actions" ON admin_actions
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
  );

-- ============================================================
-- 2. Admin RLS for reports
-- ============================================================

CREATE POLICY "Admins can view all reports" ON sale_reports
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
  );

CREATE POLICY "Admins can delete reports" ON sale_reports
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
  );

-- ============================================================
-- 3. Admin can view all sales (including inactive)
-- ============================================================

CREATE POLICY "Admins can view all sales" ON garage_sales
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.is_admin = true)
  );

-- ============================================================
-- 4. Helper function to check admin status
-- ============================================================

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.is_admin = true
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;
