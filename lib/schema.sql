-- TrashTrove - Garage Sale Listings Database Schema
-- Run this in your Supabase SQL Editor

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

-- Indexes for browsing by location
CREATE INDEX IF NOT EXISTS idx_garage_sales_state ON garage_sales(state);
CREATE INDEX IF NOT EXISTS idx_garage_sales_state_city ON garage_sales(state, city);
CREATE INDEX IF NOT EXISTS idx_garage_sales_sale_date ON garage_sales(sale_date);
CREATE INDEX IF NOT EXISTS idx_garage_sales_active_date ON garage_sales(is_active, sale_date);
CREATE INDEX IF NOT EXISTS idx_garage_sales_zip ON garage_sales(zip);
CREATE INDEX IF NOT EXISTS idx_sale_photos_sale_id ON sale_photos(sale_id);

-- Full-text search on title + description
ALTER TABLE garage_sales ADD COLUMN IF NOT EXISTS fts tsvector
  GENERATED ALWAYS AS (to_tsvector('english', title || ' ' || description)) STORED;
CREATE INDEX IF NOT EXISTS idx_garage_sales_fts ON garage_sales USING gin(fts);

-- Enable RLS
ALTER TABLE garage_sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_photos ENABLE ROW LEVEL SECURITY;

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

-- Storage bucket for sale photos
INSERT INTO storage.buckets (id, name, public)
VALUES ('sale-photos', 'sale-photos', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Anyone can upload sale photos" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'sale-photos');

CREATE POLICY "Anyone can view sale photos storage" ON storage.objects
  FOR SELECT USING (bucket_id = 'sale-photos');

-- ============================================================
-- Additional schema: manage_token, contact_messages, sale_reports,
-- RPC functions, RLS policies, indexes, and pg_cron cleanup
-- ============================================================

-- 1. Add manage_token column to garage_sales for anonymous edit/delete
ALTER TABLE garage_sales ADD COLUMN IF NOT EXISTS manage_token UUID DEFAULT gen_random_uuid();
CREATE INDEX IF NOT EXISTS idx_garage_sales_manage_token ON garage_sales(manage_token);

-- 2. Contact messages table
CREATE TABLE IF NOT EXISTS contact_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES garage_sales(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL,
  sender_email TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_contact_messages_sale_id ON contact_messages(sale_id);

-- 3. Sale reports table
CREATE TABLE IF NOT EXISTS sale_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES garage_sales(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  details TEXT,
  reporter_ip TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_sale_reports_sale_id ON sale_reports(sale_id);

-- 4. Enable RLS on new tables
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_reports ENABLE ROW LEVEL SECURITY;

-- 5. RLS policies for contact_messages
CREATE POLICY "Anyone can send a contact message" ON contact_messages
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Sale owners can view their messages" ON contact_messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM garage_sales
      WHERE garage_sales.id = contact_messages.sale_id
    )
  );

-- 6. RLS policies for sale_reports
CREATE POLICY "Anyone can report a sale" ON sale_reports
  FOR INSERT WITH CHECK (true);

-- 7. Update/delete RLS policies for garage_sales using manage_token
CREATE POLICY "Manage token holders can update their sales" ON garage_sales
  FOR UPDATE USING (
    manage_token IS NOT NULL
    AND manage_token = current_setting('request.headers', true)::json->>'x-manage-token'
  ) WITH CHECK (
    manage_token IS NOT NULL
    AND manage_token = current_setting('request.headers', true)::json->>'x-manage-token'
  );

CREATE POLICY "Manage token holders can delete their sales" ON garage_sales
  FOR DELETE USING (
    manage_token IS NOT NULL
    AND manage_token = current_setting('request.headers', true)::json->>'x-manage-token'
  );

-- 8. RPC function: get_state_counts
--    Returns the number of active sales per state on or after min_date.
CREATE OR REPLACE FUNCTION get_state_counts(min_date DATE)
RETURNS TABLE(state TEXT, count BIGINT)
LANGUAGE sql STABLE
AS $$
  SELECT g.state, COUNT(*) AS count
  FROM garage_sales g
  WHERE g.is_active = true
    AND g.sale_date >= min_date
  GROUP BY g.state
  ORDER BY count DESC;
$$;

-- 9. RPC function: nearby_sales
--    Returns active sales within radius_miles of the given lat/lng,
--    ordered by distance. Uses the Haversine formula.
CREATE OR REPLACE FUNCTION nearby_sales(lat DOUBLE PRECISION, lng DOUBLE PRECISION, radius_miles DOUBLE PRECISION)
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
)
LANGUAGE sql STABLE
AS $$
  SELECT
    g.id,
    g.title,
    g.description,
    g.categories,
    g.address,
    g.city,
    g.state,
    g.zip,
    g.latitude,
    g.longitude,
    g.sale_date,
    g.start_time,
    g.end_time,
    g.seller_name,
    g.is_active,
    g.created_at,
    3958.8 * 2 * asin(sqrt(
      sin(radians(g.latitude - lat) / 2) ^ 2
      + cos(radians(lat)) * cos(radians(g.latitude))
        * sin(radians(g.longitude - lng) / 2) ^ 2
    )) AS distance_miles
  FROM garage_sales g
  WHERE g.is_active = true
    AND g.latitude IS NOT NULL
    AND g.longitude IS NOT NULL
    AND 3958.8 * 2 * asin(sqrt(
      sin(radians(g.latitude - lat) / 2) ^ 2
      + cos(radians(lat)) * cos(radians(g.latitude))
        * sin(radians(g.longitude - lng) / 2) ^ 2
    )) <= radius_miles
  ORDER BY distance_miles;
$$;

-- 10. Spatial index for lat/lng lookups (speeds up nearby_sales)
CREATE INDEX IF NOT EXISTS idx_garage_sales_lat_lng
  ON garage_sales(latitude, longitude)
  WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- 11. Weekly cleanup of expired listings via pg_cron
--     Deactivates sales whose date has passed by more than 1 day.
--     Requires the pg_cron extension (enabled by default on Supabase).
CREATE EXTENSION IF NOT EXISTS pg_cron;

SELECT cron.schedule(
  'cleanup-expired-listings',   -- job name
  '0 3 * * 0',                  -- every Sunday at 3:00 AM UTC
  $$UPDATE garage_sales SET is_active = false, updated_at = now() WHERE is_active = true AND sale_date < CURRENT_DATE - INTERVAL '1 day'$$
);
