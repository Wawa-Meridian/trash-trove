-- Migration: Multi-day sales + Price range

-- ============================================================
-- 1. Sale dates table (1-to-many, supports multi-day sales)
-- ============================================================

CREATE TABLE IF NOT EXISTS sale_dates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES garage_sales(id) ON DELETE CASCADE,
  sale_date DATE NOT NULL,
  start_time TIME NOT NULL DEFAULT '08:00',
  end_time TIME NOT NULL DEFAULT '14:00'
);

CREATE INDEX IF NOT EXISTS idx_sale_dates_date ON sale_dates(sale_date);
CREATE INDEX IF NOT EXISTS idx_sale_dates_sale_id ON sale_dates(sale_id);

ALTER TABLE sale_dates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view sale dates" ON sale_dates
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert sale dates" ON sale_dates
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Sale dates can be updated" ON sale_dates
  FOR UPDATE USING (true);

CREATE POLICY "Sale dates can be deleted" ON sale_dates
  FOR DELETE USING (true);

-- ============================================================
-- 2. Migrate existing single-date data into sale_dates
-- ============================================================

INSERT INTO sale_dates (sale_id, sale_date, start_time, end_time)
SELECT id, sale_date, start_time, end_time
FROM garage_sales
WHERE sale_date IS NOT NULL
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. Price range columns
-- ============================================================

ALTER TABLE garage_sales
  ADD COLUMN IF NOT EXISTS price_min INTEGER,       -- cents
  ADD COLUMN IF NOT EXISTS price_max INTEGER,       -- cents
  ADD COLUMN IF NOT EXISTS has_free_items BOOLEAN NOT NULL DEFAULT false;
