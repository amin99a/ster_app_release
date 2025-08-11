-- Fix Car Database Issues - Matching Your Schema
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
WHERE tc.table_name = 'cars'
AND tc.table_schema = 'public';

-- ==================== STEP 2: SETUP RLS POLICIES ====================

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

-- ==================== STEP 3: TEST INSERT WITH CORRECT SCHEMA ====================

-- Test insert to verify everything works with your actual schema
INSERT INTO cars (
  name, 
  image, 
  price, 
  category, 
  rating, 
  trips, 
  location, 
  host_name, 
  host_image, 
  host_rating, 
  response_time, 
  description, 
  features, 
  images, 
  specs, 
  available, 
  transmission, 
  fuel_type, 
  passengers
) VALUES (
  'Test BMW X5 2023',
  'assets/images/car1.jpg',
  'UK£50 total',
  'SUV',
  0.0,
  0,
  'Alger',
  'Test Host',
  'assets/images/host.jpg',
  4.8,
  '1 hour',
  'Test car for database verification',
  '["GPS", "Bluetooth"]'::jsonb,
  '["assets/images/car1.jpg"]'::jsonb,
  '{"engine": "2.0L", "transmission": "automatic", "fuel": "gasoline", "seats": "5", "year": "2023", "brand": "BMW", "model": "X5", "color": "White", "licensePlate": "TEST123", "mileage": "10000"}'::jsonb,
  true,
  'automatic',
  'gasoline',
  5
) ON CONFLICT DO NOTHING;

-- ==================== STEP 4: VERIFY SETUP ====================

-- Display the policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'cars';

-- Check if test car was inserted
SELECT COUNT(*) as car_count FROM cars;

-- Show sample car data
SELECT * FROM cars LIMIT 3;

-- ==================== STEP 5: CLEANUP TEST DATA ====================

-- Remove test car
DELETE FROM cars WHERE name = 'Test BMW X5 2023';

-- ==================== SETUP COMPLETE ====================

SELECT 'Car database setup complete! You can now add cars from the app.' as status; 