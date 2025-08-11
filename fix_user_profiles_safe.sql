-- Safe fix for user_profiles table - only creates/updates what's needed
-- This won't fail if table already exists

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- First, let's check what we're working with
DO $$
DECLARE
    table_exists BOOLEAN := FALSE;
    column_count INTEGER := 0;
BEGIN
    -- Check if user_profiles table exists
    SELECT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles'
    ) INTO table_exists;
    
    IF table_exists THEN
        RAISE NOTICE 'user_profiles table already exists - checking structure...';
        
        -- Check columns
        SELECT COUNT(*) INTO column_count
        FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND table_schema = 'public';
        
        RAISE NOTICE 'user_profiles table has % columns', column_count;
    ELSE
        RAISE NOTICE 'user_profiles table does not exist - will create it';
    END IF;
END $$;

-- Drop and recreate triggers (safe to do even if they don't exist)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Only create table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  email TEXT,
  phone TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns if they don't exist
DO $$
BEGIN
    -- Add full_name column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'full_name'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN full_name TEXT;
        RAISE NOTICE 'Added full_name column';
    END IF;
    
    -- Add email column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'email'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN email TEXT;
        RAISE NOTICE 'Added email column';
    END IF;
    
    -- Add phone column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'phone'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN phone TEXT;
        RAISE NOTICE 'Added phone column';
    END IF;
    
    -- Add avatar_url column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'avatar_url'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN avatar_url TEXT;
        RAISE NOTICE 'Added avatar_url column';
    END IF;
    
    -- Add role column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'role'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN role TEXT DEFAULT 'user';
        RAISE NOTICE 'Added role column';
    END IF;
    
    -- Add created_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'created_at'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added created_at column';
    END IF;
    
    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'updated_at'
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column';
    END IF;
END $$;

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON public.user_profiles(created_at);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);

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

-- Drop existing trigger and recreate
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
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
    
    RAISE NOTICE 'User profile created in user_profiles table for: %', NEW.email;
    RETURN NEW;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Failed to create user_profiles entry for %: %', NEW.email, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Drop existing RLS policies to avoid conflicts
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Service role can insert profiles" ON public.user_profiles;

-- Create RLS Policies for user_profiles table
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Allow service role to insert profiles (for triggers and server-side operations)
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
)
ON CONFLICT (id) DO NOTHING; -- Ignore if profile already exists

-- Final verification and success message
DO $$
DECLARE
    auth_count INTEGER;
    profile_count INTEGER;
    missing_profiles INTEGER;
BEGIN
    SELECT COUNT(*) INTO auth_count FROM auth.users;
    SELECT COUNT(*) INTO profile_count FROM public.user_profiles;
    
    SELECT COUNT(*) INTO missing_profiles 
    FROM auth.users au
    WHERE NOT EXISTS (
        SELECT 1 FROM public.user_profiles up WHERE up.id = au.id
    );
    
    RAISE NOTICE '=== USER_PROFILES SETUP COMPLETE ===';
    RAISE NOTICE 'Auth users: %', auth_count;
    RAISE NOTICE 'User profiles: %', profile_count;
    RAISE NOTICE 'Missing profiles: %', missing_profiles;
    
    IF missing_profiles = 0 THEN
        RAISE NOTICE '✅ All auth users have profiles!';
    ELSE
        RAISE NOTICE '❌ % auth users are missing profiles', missing_profiles;
    END IF;
    
    RAISE NOTICE 'Table: user_profiles';
    RAISE NOTICE 'Trigger: on_auth_user_created (active)';
    RAISE NOTICE 'RLS: Enabled with proper policies';
END $$;