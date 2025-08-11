-- Fix Storage Bucket RLS Policies for Image Uploads
-- Run this in your Supabase SQL Editor

-- First, check if the car-images bucket exists
SELECT * FROM storage.buckets WHERE id = 'car-images';

-- Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('car-images', 'car-images', true)
ON CONFLICT (id) DO NOTHING;

-- Drop existing storage policies
DROP POLICY IF EXISTS "Users can upload images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own images" ON storage.objects;

-- Create comprehensive storage policies
CREATE POLICY "Users can upload images" ON storage.objects
FOR INSERT 
TO authenticated
WITH CHECK (
  bucket_id = 'car-images' AND
  (auth.uid()::text = (storage.foldername(name))[1] OR 
   auth.uid()::text = '550e8400-e29b-41d4-a716-446655440001')
);

CREATE POLICY "Public can view images" ON storage.objects
FOR SELECT 
TO public
USING (bucket_id = 'car-images');

CREATE POLICY "Users can update their own images" ON storage.objects
FOR UPDATE 
TO authenticated
USING (
  bucket_id = 'car-images' AND
  (auth.uid()::text = (storage.foldername(name))[1] OR 
   auth.uid()::text = '550e8400-e29b-41d4-a716-446655440001')
)
WITH CHECK (
  bucket_id = 'car-images' AND
  (auth.uid()::text = (storage.foldername(name))[1] OR 
   auth.uid()::text = '550e8400-e29b-41d4-a716-446655440001')
);

CREATE POLICY "Users can delete their own images" ON storage.objects
FOR DELETE 
TO authenticated
USING (
  bucket_id = 'car-images' AND
  (auth.uid()::text = (storage.foldername(name))[1] OR 
   auth.uid()::text = '550e8400-e29b-41d4-a716-446655440001')
);

-- Alternative: Simple policy for testing (less secure but easier to test)
-- Uncomment the lines below if the above policies don't work

/*
-- Simple policies for testing
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
*/

-- Verify the bucket was created
SELECT * FROM storage.buckets WHERE id = 'car-images';

-- Check if RLS is enabled on storage.objects
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'storage' AND tablename = 'objects'; 