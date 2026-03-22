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
