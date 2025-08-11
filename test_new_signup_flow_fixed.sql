-- Test new signup flow with correct UUID format
-- This verifies that the trigger is working correctly

-- Test: Simulate what happens when a new user signs up
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
  new_profile_id TEXT;
BEGIN
  -- Check before
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  RAISE NOTICE '=== BEFORE TEST ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  
  -- Create test user (simulating app signup) with correct UUID
  INSERT INTO auth.users (
    id, email, email_confirmed_at, created_at, updated_at, raw_user_meta_data
  ) VALUES (
    '12345678-1234-1234-1234-123456789abc',
    'newuser@test.com', NOW(), NOW(), NOW(),
    '{"name": "New Test User"}'::jsonb
  );
  
  -- Check if profile was created
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  SELECT id INTO new_profile_id FROM public.profiles WHERE email = 'newuser@test.com';
  
  RAISE NOTICE '=== AFTER TEST ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  
  IF new_profile_id IS NOT NULL THEN
    RAISE NOTICE '✅ SUCCESS: Profile created automatically!';
    RAISE NOTICE 'Profile ID: %', new_profile_id;
  ELSE
    RAISE NOTICE '❌ FAILED: Profile NOT created!';
  END IF;
  
  -- Cleanup
  DELETE FROM auth.users WHERE email = 'newuser@test.com';
  DELETE FROM public.profiles WHERE email = 'newuser@test.com';
  
  RAISE NOTICE '=== TEST COMPLETE ===';
END $$; 