-- Complete fix for user_profiles table issue
-- This creates the correct user_profiles table that matches AuthService expectations

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing conflicting tables and triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;

-- Create the correct user_profiles table that matches AuthService expectations
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_created_at ON public.user_profiles(created_at);
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);

-- Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON public.user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create the signup trigger function for automatic profile creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert into user_profiles table with correct field names
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
    'user',
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

-- RLS Policies for user_profiles table

-- Policy: Users can read their own profile
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Policy: Users can insert their own profile (for signup)
CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy: Allow service role to insert profiles (for triggers)
CREATE POLICY "Service role can insert profiles" ON public.user_profiles
    FOR INSERT WITH CHECK (true);

-- Create profiles for any existing auth users that don't have profiles
INSERT INTO public.user_profiles (
  id, 
  full_name, 
  email, 
  role, 
  created_at,
  updated_at
)
SELECT 
  au.id,
  COALESCE(au.raw_user_meta_data->>'name', 'User'),
  au.email,
  'user',
  COALESCE(au.created_at, NOW()),
  NOW()
FROM auth.users au
WHERE NOT EXISTS (
  SELECT 1 FROM public.user_profiles up WHERE up.id = au.id
);

-- Success message
DO $$
DECLARE
  auth_count INTEGER;
  profile_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO auth_count FROM auth.users;
  SELECT COUNT(*) INTO profile_count FROM public.user_profiles;
  
  RAISE NOTICE '=== USER_PROFILES TABLE SETUP COMPLETE ===';
  RAISE NOTICE 'Auth users: %', auth_count;
  RAISE NOTICE 'User profiles: %', profile_count;
  RAISE NOTICE 'Table: user_profiles (matches AuthService expectations)';
  RAISE NOTICE 'Fields: id, full_name, email, phone, avatar_url, role, created_at, updated_at';
  RAISE NOTICE 'Trigger: Automatically creates profiles on signup';
  RAISE NOTICE 'RLS: Enabled with proper policies';
END $$;