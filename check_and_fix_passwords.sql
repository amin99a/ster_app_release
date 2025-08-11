-- Check and fix password issues
-- The problem: SQL-created users have encrypted passwords, app expects plain text

-- First, let's see what users we have and their password status
SELECT 
  id,
  email,
  CASE 
    WHEN encrypted_password IS NOT NULL THEN 'Encrypted (SQL created)'
    WHEN encrypted_password IS NULL THEN 'No password (App created)'
  END as password_status,
  email_confirmed_at
FROM auth.users
ORDER BY created_at;

-- Show profiles status
SELECT 
  p.id,
  p.email,
  p.name,
  p.role,
  p.is_email_verified
FROM public.profiles p
ORDER BY p.created_at;

-- The issue: SQL-created users have encrypted passwords
-- Solution: Create new test users with proper passwords
-- OR: Update existing users to have proper passwords

-- Option 1: Create new test users with proper passwords
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES 
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'test1@ster.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'test2@ster.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'test3@ster.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Create profiles for new test users
INSERT INTO public.profiles (id, name, email, role, is_email_verified, created_at)
VALUES 
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Test User 1', 'test1@ster.com', 'user', true, NOW()),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Test User 2', 'test2@ster.com', 'user', true, NOW()),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Test User 3', 'test3@ster.com', 'user', true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '=== NEW TEST ACCOUNTS CREATED ===';
  RAISE NOTICE 'Use these accounts for testing:';
  RAISE NOTICE 'test1@ster.com / password123';
  RAISE NOTICE 'test2@ster.com / password123';
  RAISE NOTICE 'test3@ster.com / password123';
  RAISE NOTICE '';
  RAISE NOTICE 'These have proper encrypted passwords that work with Supabase auth!';
END $$; 