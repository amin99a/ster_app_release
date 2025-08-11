-- Fix existing accounts that don't have profiles
-- This targets the accounts like hassan.host@example.com

-- First, let's see what we have
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
  missing_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  SELECT COUNT(*) INTO missing_count 
  FROM auth.users au 
  WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = au.id);
  
  RAISE NOTICE '=== CURRENT STATUS ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  RAISE NOTICE 'Missing profiles: %', missing_count;
END $$;

-- Show existing auth users without profiles
SELECT 
  au.id,
  au.email,
  au.raw_user_meta_data,
  au.email_confirmed_at
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = au.id
);

-- Create profiles for ALL missing users
INSERT INTO public.profiles (
  id, name, email, role, is_email_verified, created_at
)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'name', 'User'),
  au.email,
  'user',
  COALESCE(au.email_confirmed_at IS NOT NULL, false),
  COALESCE(au.created_at, NOW())
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = au.id
);

-- Confirm all emails again
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;

-- Mark all profiles as verified
UPDATE public.profiles 
SET is_email_verified = true 
WHERE is_email_verified = false;

-- Final status
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  RAISE NOTICE '=== FIXED ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  RAISE NOTICE 'All accounts should now work!';
END $$; 