-- Test new signup flow
-- This verifies that the trigger is working correctly

-- First, let's check the current trigger status
SELECT 
  trigger_name,
  event_manipulation,
  action_statement
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created';

-- Check the trigger function
SELECT 
  routine_name,
  routine_definition
FROM information_schema.routines 
WHERE routine_name = 'handle_new_user';

-- Test: Simulate what happens when a new user signs up
-- (This is for testing only - don't run in production)

-- Step 1: Check current counts
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  RAISE NOTICE '=== BEFORE TEST ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
END $$;

-- Step 2: Create a test user (simulating app signup)
INSERT INTO auth.users (
  id, 
  email, 
  email_confirmed_at, 
  created_at, 
  updated_at,
  raw_user_meta_data
) VALUES (
  'test-signup-1234-5678-9abc-def012345678',
  'newuser@test.com',
  NOW(),
  NOW(),
  NOW(),
  '{"name": "New Test User"}'::jsonb
);

-- Step 3: Check if profile was created automatically
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
  new_profile_id TEXT;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  
  SELECT id INTO new_profile_id 
  FROM public.profiles 
  WHERE email = 'newuser@test.com';
  
  RAISE NOTICE '=== AFTER TEST ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  
  IF new_profile_id IS NOT NULL THEN
    RAISE NOTICE '✅ SUCCESS: Profile created automatically for newuser@test.com';
    RAISE NOTICE 'Profile ID: %', new_profile_id;
  ELSE
    RAISE NOTICE '❌ FAILED: Profile NOT created for newuser@test.com';
  END IF;
END $$;

-- Clean up test data
DELETE FROM auth.users WHERE email = 'newuser@test.com';
DELETE FROM public.profiles WHERE email = 'newuser@test.com';

-- Final status
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  RAISE NOTICE '=== CLEANUP COMPLETE ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
END $$; 