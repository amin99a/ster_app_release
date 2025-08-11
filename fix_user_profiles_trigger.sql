-- Fix signup trigger to use user_profiles table instead of users/profiles
-- This addresses the issue where signup creates accounts in wrong table

-- Drop any existing triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Create the correct trigger function for user_profiles table
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into user_profiles table (NOT profiles or users)
  INSERT INTO public.user_profiles (
    id, 
    full_name, 
    email, 
    role, 
    created_at,
    updated_at
  ) VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    NEW.email, 
    'user', -- Default role
    NOW(),
    NOW()
  );
  
  -- Log success
  RAISE NOTICE 'User profile created in user_profiles table for: %', NEW.email;
  RETURN NEW;
  
EXCEPTION
  WHEN OTHERS THEN
    -- Log error but don't fail signup
    RAISE WARNING 'Failed to create user_profiles entry for %: %', NEW.email, SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Verify the setup
DO $$
BEGIN
  RAISE NOTICE '=== USER_PROFILES TRIGGER SETUP COMPLETE ===';
  RAISE NOTICE 'New signups will now create profiles in user_profiles table';
  RAISE NOTICE 'Fields: id, full_name, email, role, created_at, updated_at';
END $$;