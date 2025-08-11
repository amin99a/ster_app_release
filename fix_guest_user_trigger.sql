-- Fix the trigger to handle guest users properly
-- This ensures guest users get the correct role

-- Drop and recreate the trigger function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_role TEXT;
BEGIN
  -- Determine the role from user metadata
  user_role := COALESCE(NEW.raw_user_meta_data->>'role', 'user');
  
  -- Insert into profiles with the correct role
  INSERT INTO public.profiles (
    id, name, email, role, is_email_verified, created_at
  ) VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email, 
    user_role, -- Use the role from metadata
    true, -- Always mark as verified for testing
    NOW()
  );
  
  -- Log success with role info
  RAISE NOTICE 'Profile created for user: % with role: %', NEW.email, user_role;
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

-- Success message
DO $$
BEGIN
  RAISE NOTICE '=== GUEST USER TRIGGER FIXED ===';
  RAISE NOTICE 'Guest users will now be created with "guest" role!';
  RAISE NOTICE 'Regular users will be created with "user" role!';
END $$; 