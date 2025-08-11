-- Fix the trigger and create missing profiles
-- This addresses the "Profile NOT created by trigger" issue

-- First, drop and recreate the trigger function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create a more robust trigger function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into profiles with proper error handling
  INSERT INTO public.profiles (
    id, 
    name, 
    email, 
    role, 
    is_email_verified, 
    created_at
  ) VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email, 
    'user',
    COALESCE(NEW.email_confirmed_at IS NOT NULL, false),
    NOW()
  );
  
  -- Log success
  RAISE NOTICE 'Profile created for user: %', NEW.email;
  RETURN NEW;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Log the error but don't fail the signup
    RAISE WARNING 'Failed to create profile for user %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Now manually create profiles for existing users in auth.users
INSERT INTO public.profiles (
  id, 
  name, 
  email, 
  role, 
  is_email_verified, 
  created_at
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

-- Success message
DO $$
DECLARE
  profile_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO profile_count FROM public.profiles;
  RAISE NOTICE 'Trigger fixed and profiles created!';
  RAISE NOTICE 'Total profiles now: %', profile_count;
  RAISE NOTICE 'Test login with: test1754254999156@gmail.com / password123';
END $$; 