-- STER Car Rental App - Supabase Database Setup
-- Run this in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==================== DIAGNOSTIC: CHECK EXISTING COLUMNS ====================
-- Let's see what columns already exist in the cars table
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'cars' 
ORDER BY ordinal_position;

-- ==================== USERS TABLE ====================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  profile_image TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
  is_email_verified BOOLEAN DEFAULT FALSE,
  is_phone_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE,
  preferences JSONB DEFAULT '{}',
  saved_cars TEXT[] DEFAULT '{}',
  booking_history TEXT[] DEFAULT '{}',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== CATEGORIES TABLE ====================
CREATE TABLE IF NOT EXISTS categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Handle duplicate categories and add unique constraint
DO $$ 
BEGIN
    -- Delete duplicate categories using ROW_NUMBER() approach
    DELETE FROM categories 
    WHERE id IN (
        SELECT id FROM (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY name ORDER BY created_at) as rn
            FROM categories
        ) t WHERE t.rn > 1
    );
    
    -- Add unique constraint to categories name if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'categories' AND constraint_name = 'categories_name_key') THEN
        ALTER TABLE categories ADD CONSTRAINT categories_name_key UNIQUE (name);
    END IF;
END $$;

-- ==================== CARS TABLE - ADD MISSING COLUMNS ====================
-- Add missing columns to existing cars table if they don't exist

-- Add host_id column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS host_id UUID REFERENCES users(id) ON DELETE CASCADE;

-- Add category_id column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(id);

-- Add transmission column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS transmission TEXT CHECK (transmission IN ('manual', 'automatic'));

-- Add fuel_type column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS fuel_type TEXT CHECK (fuel_type IN ('gasoline', 'diesel', 'electric', 'hybrid'));

-- Add passengers column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS passengers INTEGER DEFAULT 4;

-- Add rating column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS rating DECIMAL(3,2) DEFAULT 0.0;

-- Add available column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS available BOOLEAN DEFAULT TRUE;

-- Add images column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS images TEXT[];

-- Add updated_at column if it doesn't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- ==================== BOOKINGS TABLE ====================
CREATE TABLE IF NOT EXISTS bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  car_id UUID REFERENCES cars(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  host_id UUID REFERENCES users(id),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== NOTIFICATIONS TABLE ====================
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'general',
  related_id TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== REVIEWS TABLE ====================
CREATE TABLE IF NOT EXISTS reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  car_id UUID REFERENCES cars(id) ON DELETE CASCADE,
  user_id UUID REFERENCES users(id),
  rating DECIMAL(3,2) NOT NULL CHECK (rating >= 0 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== STORAGE BUCKETS ====================

-- Create storage buckets for images
INSERT INTO storage.buckets (id, name, public) VALUES 
  ('user-avatars', 'user-avatars', true),
  ('car-images', 'car-images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop existing storage policies if they exist
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
DROP POLICY IF EXISTS "Hosts can upload car images" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view car images" ON storage.objects;

-- Storage policies for user avatars
CREATE POLICY "Users can upload their own avatar" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'user-avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Anyone can view avatars" ON storage.objects
  FOR SELECT USING (bucket_id = 'user-avatars');

-- Storage policies for car images
CREATE POLICY "Hosts can upload car images" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'car-images');

CREATE POLICY "Anyone can view car images" ON storage.objects
  FOR SELECT USING (bucket_id = 'car-images');

-- ==================== SAMPLE DATA ====================

-- Insert sample categories (using simple INSERT to avoid ON CONFLICT issues)
INSERT INTO categories (name, description) 
SELECT 'Sedan', 'Comfortable family cars'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Sedan');

INSERT INTO categories (name, description) 
SELECT 'SUV', 'Sport utility vehicles'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'SUV');

INSERT INTO categories (name, description) 
SELECT 'Luxury', 'Premium and luxury vehicles'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Luxury');

INSERT INTO categories (name, description) 
SELECT 'Electric', 'Electric and hybrid vehicles'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Electric');

INSERT INTO categories (name, description) 
SELECT 'Sports', 'High-performance sports cars'
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = 'Sports');

-- ==================== FUNCTIONS ====================

-- Function to update car rating when review is added
CREATE OR REPLACE FUNCTION update_car_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE cars 
  SET rating = (
    SELECT AVG(rating) 
    FROM reviews 
    WHERE car_id = NEW.car_id
  )
  WHERE id = NEW.car_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS update_car_rating_trigger ON reviews;

-- Trigger to update car rating
CREATE TRIGGER update_car_rating_trigger
  AFTER INSERT OR UPDATE OR DELETE ON reviews
  FOR EACH ROW
  EXECUTE FUNCTION update_car_rating();

-- ==================== COMMENTS ====================

COMMENT ON TABLE users IS 'User accounts and profiles';
COMMENT ON TABLE cars IS 'Car listings for rental';
COMMENT ON TABLE bookings IS 'Car rental bookings';
COMMENT ON TABLE notifications IS 'User notifications';
COMMENT ON TABLE reviews IS 'Car reviews and ratings';
COMMENT ON TABLE categories IS 'Car categories';

-- ==================== SETUP COMPLETE ====================

-- Display setup completion message
SELECT 'STER Car Rental Database Setup Complete!' as status; 