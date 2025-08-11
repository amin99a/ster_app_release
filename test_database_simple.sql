-- Simple Database Test
-- Run this in your Supabase SQL Editor to verify everything is working

-- Check if we can read from cars table
SELECT COUNT(*) as total_cars FROM cars;

-- Check the latest cars
SELECT id, name, created_at FROM cars ORDER BY created_at DESC LIMIT 5;

-- Check if RLS policies are set up correctly
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'cars';

-- Test a simple insert
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
  'Test Car from SQL',
  'test.jpg',
  'UK£50 total',
  'SUV',
  0.0,
  0,
  'Alger',
  'Test Host',
  'host.jpg',
  4.8,
  '1 hour',
  'Test car inserted via SQL',
  '["GPS"]'::jsonb,
  '["test.jpg"]'::jsonb,
  '{"engine": "2.0L", "transmission": "automatic", "fuel": "gasoline"}'::jsonb,
  true,
  'automatic',
  'gasoline',
  5
) RETURNING id, name, created_at;

-- Check if the test car was inserted
SELECT COUNT(*) as cars_after_insert FROM cars;

-- Clean up test car
DELETE FROM cars WHERE name = 'Test Car from SQL';

-- Final count
SELECT COUNT(*) as final_car_count FROM cars; 