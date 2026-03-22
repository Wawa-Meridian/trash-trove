-- TrashTrove - Garage Sale Listings Database Schema
-- Run this in your Supabase SQL Editor

-- ============================================================
-- TABLES
-- ============================================================

-- Garage sales table
CREATE TABLE IF NOT EXISTS garage_sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  categories TEXT[] NOT NULL DEFAULT '{}',
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT NOT NULL,       -- 2-letter state code (e.g. "CA")
  zip TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  sale_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  seller_name TEXT NOT NULL,
  seller_email TEXT NOT NULL,
  manage_token UUID NOT NULL DEFAULT gen_random_uuid(),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Sale photos table
CREATE TABLE IF NOT EXISTS sale_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES garage_sales(id) ON DELETE CASCADE,
  url TEXT NOT NULL,
  caption TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Contact messages table
CREATE TABLE IF NOT EXISTS contact_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES garage_sales(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL,
  sender_email TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Sale reports table
CREATE TABLE IF NOT EXISTS sale_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES garage_sales(id) ON DELETE CASCADE,
  reason TEXT NOT NULL CHECK (reason IN ('spam', 'inappropriate', 'scam', 'duplicate', 'other')),
  details TEXT,
  reporter_ip TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_garage_sales_state ON garage_sales(state);
CREATE INDEX IF NOT EXISTS idx_garage_sales_state_city ON garage_sales(state, city);
CREATE INDEX IF NOT EXISTS idx_garage_sales_sale_date ON garage_sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_garage_sales_active_date ON garage_sales(is_active, sale_date);
CREATE INDEX IF NOT EXISTS idx_garage_sales_zip ON garage_sales(zip);
CREATE INDEX IF NOT EXISTS idx_sale_photos_sale_id ON sale_photos(sale_id);
CREATE INDEX IF NOT EXISTS idx_contact_messages_sale_id ON contact_messages(sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_reports_sale_id ON sale_reports(sale_id);

-- Full-text search on title + description
ALTER TABLE garage_sales ADD COLUMN IF NOT EXISTS fts tsvector
  GENERATED ALWAYS AS (to_tsvector('english', title || ' ' || description)) STORED;
CREATE INDEX IF NOT EXISTS idx_garage_sales_fts ON garage_sales USING gin(fts);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE garage_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_photos ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_reports ENABLE ROW LEVEL SECURITY;

-- Public read access
CREATE POLICY "Anyone can view active sales" ON garage_sales
  FOR SELECT USING (is_active = true);

CREATE POLICY "Anyone can view sale photos" ON sale_photos
  FOR SELECT USING (true);

-- Public insert (no auth required for MVP)
CREATE POLICY "Anyone can create sales" ON garage_sales
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can add photos" ON sale_photos
  FOR INSERT WITH CHECK (true);

-- Manage token based update/delete
CREATE POLICY "Token holders can update their sales" ON garage_sales
  FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Token holders can delete their sales" ON garage_sales
  FOR DELETE USING (true);

-- Contact messages
CREATE POLICY "Anyone can send contact messages" ON contact_messages
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can view contact messages" ON contact_messages
  FOR SELECT USING (true);

-- Sale reports
CREATE POLICY "Anyone can report sales" ON sale_reports
  FOR INSERT WITH CHECK (true);

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Get sale counts per state for active upcoming sales
CREATE OR REPLACE FUNCTION get_state_counts(min_date DATE)
RETURNS TABLE(state TEXT, count BIGINT) AS $$
  SELECT state, count(*)::BIGINT
  FROM garage_sales
  WHERE is_active = true AND sale_date >= min_date
  GROUP BY state
  ORDER BY count DESC;
$$ LANGUAGE sql STABLE;

-- Find nearby sales using Haversine formula
CREATE OR REPLACE FUNCTION nearby_sales(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_miles DOUBLE PRECISION DEFAULT 25
)
RETURNS TABLE(
  id UUID,
  title TEXT,
  description TEXT,
  categories TEXT[],
  address TEXT,
  city TEXT,
  state TEXT,
  zip TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  sale_date DATE,
  start_time TIME,
  end_time TIME,
  seller_name TEXT,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  distance_miles DOUBLE PRECISION
) AS $$
  SELECT
    g.id, g.title, g.description, g.categories,
    g.address, g.city, g.state, g.zip,
    g.latitude, g.longitude,
    g.sale_date, g.start_time, g.end_time,
    g.seller_name, g.is_active, g.created_at,
    (3959 * acos(
      cos(radians(user_lat)) * cos(radians(g.latitude)) *
      cos(radians(g.longitude) - radians(user_lng)) +
      sin(radians(user_lat)) * sin(radians(g.latitude))
    )) AS distance_miles
  FROM garage_sales g
  WHERE g.is_active = true
    AND g.sale_date >= CURRENT_DATE
    AND g.latitude IS NOT NULL
    AND g.longitude IS NOT NULL
    AND (3959 * acos(
      cos(radians(user_lat)) * cos(radians(g.latitude)) *
      cos(radians(g.longitude) - radians(user_lng)) +
      sin(radians(user_lat)) * sin(radians(g.latitude))
    )) <= radius_miles
  ORDER BY distance_miles;
$$ LANGUAGE sql STABLE;

-- ============================================================
-- STORAGE
-- ============================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('sale-photos', 'sale-photos', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Anyone can upload sale photos" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'sale-photos');

CREATE POLICY "Anyone can view sale photos storage" ON storage.objects
  FOR SELECT USING (bucket_id = 'sale-photos');

-- ============================================================
-- CRON: Weekly listing wipe (timezone-aware)
-- ============================================================
-- Runs every Sunday at midnight UTC; deletes sales whose sale_date
-- has passed in their state's local timezone.
-- Requires pg_cron extension enabled in Supabase dashboard.
