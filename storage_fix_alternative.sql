-- Alternative Storage Fix (No Policy Changes)
-- Run this in your Supabase SQL Editor

-- 1. First, check if the car-images bucket exists
SELECT * FROM storage.buckets WHERE id = 'car-images';

-- 2. Create the bucket if it doesn't exist (this should work)
INSERT INTO storage.buckets (id, name, public)
VALUES ('car-images', 'car-images', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Check bucket settings
SELECT id, name, public, file_size_limit, allowed_mime_types 
FROM storage.buckets 
WHERE id = 'car-images';

-- 4. If the bucket exists but policies are the issue, try this temporary fix:
-- Go to Supabase Dashboard > Storage > car-images bucket > Settings
-- Make sure "Public bucket" is enabled
-- Set "File size limit" to a reasonable value (e.g., 50MB)
-- Add these MIME types: image/jpeg, image/png, image/webp, image/gif

-- 5. Alternative: Disable RLS temporarily (for testing only)
-- WARNING: This is less secure but will work for testing
-- Uncomment the line below if you have admin access:
-- ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;

-- 6. Check current RLS status
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'storage' AND tablename = 'objects'; 