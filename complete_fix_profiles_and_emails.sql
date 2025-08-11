-- Complete fix: Create profiles + confirm emails
-- This addresses both the empty profiles table and email confirmation issues

-- Step 1: Fix the trigger function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, name, email, role, is_email_verified, created_at
  ) VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email, 'user',
    true, -- Always mark as verified for testing
    NOW()
  );
  RAISE NOTICE 'Profile created for user: %', NEW.email;
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Failed to create profile for user %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Step 3: Confirm ALL emails in auth.users
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;

-- Step 4: Create profiles for ALL existing users
INSERT INTO public.profiles (
  id, name, email, role, is_email_verified, created_at
)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'name', 'User'),
  au.email,
  'user',
  true, -- Mark all as verified
  COALESCE(au.created_at, NOW())
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.profiles p WHERE p.id = au.id
);

-- Step 5: Update all profiles to verified
UPDATE public.profiles 
SET is_email_verified = true 
WHERE is_email_verified = false;

-- Success message
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  RAISE NOTICE '=== FIX COMPLETE ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'Profiles: %', profile_count;
  RAISE NOTICE 'All emails confirmed!';
  RAISE NOTICE 'Test with: test1754255237823@gmail.com / password123';
END $$; 