-- Simple Fix for Car Insertion Issues
-- Run this in your Supabase SQL Editor

-- Enable RLS on cars table
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Enable read access for all users" ON cars;
DROP POLICY IF EXISTS "Enable insert for all users" ON cars;
DROP POLICY IF EXISTS "Enable update for all users" ON cars;
DROP POLICY IF EXISTS "Enable delete for all users" ON cars;

-- Create simple policies that allow all operations for testing
CREATE POLICY "Enable read access for all users" ON cars
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON cars
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update for all users" ON cars
  FOR UPDATE USING (true);

CREATE POLICY "Enable delete for all users" ON cars
  FOR DELETE USING (true);

-- Display the policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'cars';

-- Test insert
INSERT INTO cars (name, image, price, category, location, host_name, description, available)
VALUES ('Test Car', 'test.jpg', 'UK£50 total', 'SUV', 'Test Location', 'Test Host', 'Test Description', true)
ON CONFLICT DO NOTHING; 