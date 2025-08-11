-- Complete Fix for Car Database Issues with Constraint Handling
-- Run this in your Supabase SQL Editor

-- ==================== STEP 1: CHECK CURRENT STATE ====================

-- Check if cars table exists and its structure
SELECT EXISTS (
  SELECT FROM information_schema.tables 
  WHERE table_schema = 'public' 
  AND table_name = 'cars'
) as table_exists;

-- Check existing constraints
SELECT 
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
  AND tc.table_schema = cc.table_schema
WHERE tc.table_name = 'cars'
AND tc.table_schema = 'public';

-- ==================== STEP 2: DROP EXISTING CONSTRAINTS ====================

-- Drop existing check constraints that might cause issues
DROP CONSTRAINT IF EXISTS cars_fuel_type_check ON cars;
DROP CONSTRAINT IF EXISTS cars_transmission_check ON cars;
DROP CONSTRAINT IF EXISTS cars_category_check ON cars;

-- ==================== STEP 3: CREATE CARS TABLE IF NOT EXISTS ====================

CREATE TABLE IF NOT EXISTS cars (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  image TEXT,
  price TEXT,
  price_per_day DECIMAL(10,2),
  category TEXT,
  location TEXT,
  host_name TEXT,
  host_image TEXT,
  host_rating DECIMAL(3,2) DEFAULT 0.0,
  response_time TEXT,
  description TEXT,
  features JSONB,
  images JSONB,
  specs JSONB,
  rating DECIMAL(3,2) DEFAULT 0.0,
  trips INTEGER DEFAULT 0,
  available BOOLEAN DEFAULT TRUE,
  featured BOOLEAN DEFAULT FALSE,
  transmission TEXT,
  fuel_type TEXT,
  passengers INTEGER DEFAULT 4,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ==================== STEP 4: ADD MISSING COLUMNS ====================

-- Add missing columns if they don't exist
ALTER TABLE cars ADD COLUMN IF NOT EXISTS price_per_day DECIMAL(10,2);
ALTER TABLE cars ADD COLUMN IF NOT EXISTS host_rating DECIMAL(3,2) DEFAULT 0.0;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS response_time TEXT;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS features JSONB;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS images JSONB;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS specs JSONB;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS rating DECIMAL(3,2) DEFAULT 0.0;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS trips INTEGER DEFAULT 0;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS available BOOLEAN DEFAULT TRUE;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS featured BOOLEAN DEFAULT FALSE;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS transmission TEXT;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS fuel_type TEXT;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS passengers INTEGER DEFAULT 4;
ALTER TABLE cars ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
ALTER TABLE cars ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- ==================== STEP 5: FIX EXISTING COLUMNS ====================

-- Fix features and images columns if they exist as TEXT[]
DO $$
BEGIN
  -- Check if features column exists and is TEXT[]
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'cars' 
    AND column_name = 'features' 
    AND data_type = 'ARRAY'
  ) THEN
    -- Drop the column and recreate as JSONB
    ALTER TABLE cars DROP COLUMN features;
    ALTER TABLE cars ADD COLUMN features JSONB;
  END IF;
  
  -- Check if images column exists and is TEXT[]
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'cars' 
    AND column_name = 'images' 
    AND data_type = 'ARRAY'
  ) THEN
    -- Drop the column and recreate as JSONB
    ALTER TABLE cars DROP COLUMN images;
    ALTER TABLE cars ADD COLUMN images JSONB;
  END IF;
END $$;

-- ==================== STEP 6: SETUP RLS POLICIES ====================

-- Enable RLS on cars table
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for all users" ON cars;
DROP POLICY IF EXISTS "Enable insert for all users" ON cars;
DROP POLICY IF EXISTS "Enable update for all users" ON cars;
DROP POLICY IF EXISTS "Enable delete for all users" ON cars;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON cars;
DROP POLICY IF EXISTS "Enable update for car owners" ON cars;
DROP POLICY IF EXISTS "Enable delete for car owners" ON cars;

-- Create policies for cars table
-- Allow anyone to read cars (for browsing)
CREATE POLICY "Enable read access for all users" ON cars
  FOR SELECT USING (true);

-- Allow anyone to insert cars (for testing - change this for production)
CREATE POLICY "Enable insert for all users" ON cars
  FOR INSERT WITH CHECK (true);

-- Allow anyone to update cars (for testing - change this for production)
CREATE POLICY "Enable update for all users" ON cars
  FOR UPDATE USING (true);

-- Allow anyone to delete cars (for testing - change this for production)
CREATE POLICY "Enable delete for all users" ON cars
  FOR DELETE USING (true);

-- ==================== STEP 7: TEST INSERT ====================

-- Test insert to verify everything works
INSERT INTO cars (
  name, 
  image, 
  price, 
  price_per_day, 
  category, 
  location, 
  host_name, 
  host_image, 
  host_rating, 
  response_time, 
  description, 
  features, 
  images, 
  specs, 
  rating, 
  trips, 
  available, 
  featured, 
  transmission, 
  fuel_type, 
  passengers
) VALUES (
  'Test Car',
  'test.jpg',
  'UK£50 total',
  50.0,
  'SUV',
  'Alger',
  'Test Host',
  'host.jpg',
  4.8,
  '1 hour',
  'Test car for database verification',
  '["GPS", "Bluetooth"]'::jsonb,
  '["test.jpg"]'::jsonb,
  '{"engine": "2.0L", "transmission": "Automatic", "fuel": "Petrol", "seats": "5", "year": "2023", "brand": "BMW", "model": "X5", "color": "White", "licensePlate": "TEST123", "mileage": "10000"}'::jsonb,
  0.0,
  0,
  true,
  false,
  'Automatic',
  'Petrol',
  5
) ON CONFLICT DO NOTHING;

-- ==================== STEP 8: VERIFY SETUP ====================

-- Display the policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'cars';

-- Check if test car was inserted
SELECT COUNT(*) as car_count FROM cars;

-- Show sample car data
SELECT * FROM cars LIMIT 3;

-- ==================== STEP 9: CLEANUP TEST DATA ====================

-- Remove test car
DELETE FROM cars WHERE name = 'Test Car';

-- ==================== SETUP COMPLETE ====================

SELECT 'Car database setup complete! You can now add cars from the app.' as status; 