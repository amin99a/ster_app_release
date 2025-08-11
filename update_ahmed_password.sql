-- Update password for ahmed@example.com user
-- Run this in your Supabase SQL Editor

-- First, let's check if the user exists
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'ahmed@example.com';

-- Update the user's password (if the user exists)
-- Note: This will set the password to 'password123'
-- You can change this password as needed

UPDATE auth.users 
SET encrypted_password = crypt('password123', gen_salt('bf'))
WHERE email = 'ahmed@example.com';

-- Verify the update
SELECT id, email, created_at 
FROM auth.users 
WHERE email = 'ahmed@example.com'; 