-- Fix the trigger to ensure it sets the role as 'user' for new signups
-- This addresses the "guest user" issue

-- Drop and recreate the trigger function with explicit role setting
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into profiles with explicit 'user' role
  INSERT INTO public.profiles (
    id, name, email, role, is_email_verified, created_at
  ) VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email, 
    'user', -- Explicitly set as 'user', not 'guest'
    true, -- Always mark as verified for testing
    NOW()
  );
  
  -- Log success with role info
  RAISE NOTICE 'Profile created for user: % with role: user', NEW.email;
  RETURN NEW;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Failed to create profile for user %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update any existing profiles that have 'guest' role to 'user'
UPDATE public.profiles 
SET role = 'user' 
WHERE role = 'guest' OR role IS NULL;

-- Success message
DO $$
DECLARE
  user_count INTEGER;
  guest_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM public.profiles WHERE role = 'user';
  SELECT COUNT(*) INTO guest_count FROM public.profiles WHERE role = 'guest';
  RAISE NOTICE '=== TRIGGER FIXED ===';
  RAISE NOTICE 'Users with "user" role: %', user_count;
  RAISE NOTICE 'Users with "guest" role: %', guest_count;
  RAISE NOTICE 'New signups will now have "user" role!';
END $$; 