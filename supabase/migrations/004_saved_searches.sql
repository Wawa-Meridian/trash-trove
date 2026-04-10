-- Migration: Saved Searches

CREATE TABLE IF NOT EXISTS saved_searches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  query TEXT,
  state TEXT,
  city TEXT,
  categories TEXT[] DEFAULT '{}',
  date_from DATE,
  date_to DATE,
  price_min INTEGER,
  price_max INTEGER,
  notify_email BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_saved_searches_user_id ON saved_searches(user_id);

ALTER TABLE saved_searches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own saved searches" ON saved_searches
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create saved searches" ON saved_searches
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own saved searches" ON saved_searches
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own saved searches" ON saved_searches
  FOR DELETE USING (auth.uid() = user_id);
