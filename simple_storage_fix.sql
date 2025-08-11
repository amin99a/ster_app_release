-- Simple Storage Fix for Testing
-- Run this in your Supabase SQL Editor

-- Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('car-images', 'car-images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop any existing policies
DROP POLICY IF EXISTS "Allow all authenticated uploads" ON storage.objects;
DROP POLICY IF EXISTS "Allow all public views" ON storage.objects;
DROP POLICY IF EXISTS "Allow all authenticated updates" ON storage.objects;
DROP POLICY IF EXISTS "Allow all authenticated deletes" ON storage.objects;

-- Create simple policies for testing
CREATE POLICY "Allow all authenticated uploads" ON storage.objects
FOR INSERT 
TO authenticated
WITH CHECK (bucket_id = 'car-images');

CREATE POLICY "Allow all public views" ON storage.objects
FOR SELECT 
TO public
USING (bucket_id = 'car-images');

CREATE POLICY "Allow all authenticated updates" ON storage.objects
FOR UPDATE 
TO authenticated
USING (bucket_id = 'car-images')
WITH CHECK (bucket_id = 'car-images');

CREATE POLICY "Allow all authenticated deletes" ON storage.objects
FOR DELETE 
TO authenticated
USING (bucket_id = 'car-images');

-- Verify the bucket exists
SELECT * FROM storage.buckets WHERE id = 'car-images'; 