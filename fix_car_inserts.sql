-- Fix Car Insertion Issues - RLS Policies
-- Run this in your Supabase SQL Editor

-- First, let's check if RLS is enabled on the cars table
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'cars';

-- Enable RLS on cars table if not already enabled
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for all users" ON cars;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON cars;
DROP POLICY IF EXISTS "Enable update for car owners" ON cars;
DROP POLICY IF EXISTS "Enable delete for car owners" ON cars;

-- Create policies for cars table
-- Allow anyone to read cars (for browsing)
CREATE POLICY "Enable read access for all users" ON cars
  FOR SELECT USING (true);

-- Allow authenticated users to insert cars
CREATE POLICY "Enable insert for authenticated users" ON cars
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow car owners to update their cars
CREATE POLICY "Enable update for car owners" ON cars
  FOR UPDATE USING (auth.uid()::text = host_id::text);

-- Allow car owners to delete their cars
CREATE POLICY "Enable delete for car owners" ON cars
  FOR DELETE USING (auth.uid()::text = host_id::text);

-- If you want to allow anonymous inserts (for testing), use this instead:
-- CREATE POLICY "Enable insert for all users" ON cars
--   FOR INSERT WITH CHECK (true);

-- Display the policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'cars';

-- Test insert (optional - remove this after testing)
-- INSERT INTO cars (name, image, price, category, location, host_name, description, available)
-- VALUES ('Test Car', 'test.jpg', 'UK£50 total', 'SUV', 'Test Location', 'Test Host', 'Test Description', true); 