-- Complete Car Database Fix
-- Run this in your Supabase SQL Editor

-- 1. Enable RLS on cars table
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies
DROP POLICY IF EXISTS "Users can insert their own cars" ON cars;
DROP POLICY IF EXISTS "Users can view all cars" ON cars;
DROP POLICY IF EXISTS "Users can update their own cars" ON cars;
DROP POLICY IF EXISTS "Users can delete their own cars" ON cars;

-- 3. Create comprehensive policies
-- INSERT policy - allow authenticated users to insert cars
CREATE POLICY "Users can insert their own cars" ON cars
FOR INSERT 
TO authenticated
WITH CHECK (
  host_id::text = auth.uid()::text OR 
  host_id::text = '550e8400-e29b-41d4-a716-446655440001'
);

-- SELECT policy - allow public to view all cars
CREATE POLICY "Users can view all cars" ON cars
FOR SELECT 
TO public
USING (true);

-- UPDATE policy - allow users to update their own cars
CREATE POLICY "Users can update their own cars" ON cars
FOR UPDATE 
TO authenticated
USING (
  host_id::text = auth.uid()::text OR 
  host_id::text = '550e8400-e29b-41d4-a716-446655440001'
)
WITH CHECK (
  host_id::text = auth.uid()::text OR 
  host_id::text = '550e8400-e29b-41d4-a716-446655440001'
);

-- DELETE policy - allow users to delete their own cars
CREATE POLICY "Users can delete their own cars" ON cars
FOR DELETE 
TO authenticated
USING (
  host_id::text = auth.uid()::text OR 
  host_id::text = '550e8400-e29b-41d4-a716-446655440001'
);

-- 4. Verify the policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies 
WHERE tablename = 'cars';

-- 5. Test the policies
-- This will show if the policies are working correctly
SELECT 
  'INSERT' as operation,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_policies 
      WHERE tablename = 'cars' AND cmd = 'INSERT'
    ) THEN '✅ INSERT policy exists'
    ELSE '❌ INSERT policy missing'
  END as status
UNION ALL
SELECT 
  'SELECT' as operation,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_policies 
      WHERE tablename = 'cars' AND cmd = 'SELECT'
    ) THEN '✅ SELECT policy exists'
    ELSE '❌ SELECT policy missing'
  END as status
UNION ALL
SELECT 
  'UPDATE' as operation,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_policies 
      WHERE tablename = 'cars' AND cmd = 'UPDATE'
    ) THEN '✅ UPDATE policy exists'
    ELSE '❌ UPDATE policy missing'
  END as status
UNION ALL
SELECT 
  'DELETE' as operation,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_policies 
      WHERE tablename = 'cars' AND cmd = 'DELETE'
    ) THEN '✅ DELETE policy exists'
    ELSE '❌ DELETE policy missing'
  END as status; 