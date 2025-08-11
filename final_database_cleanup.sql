-- =====================================================
-- FINAL DATABASE CLEANUP: Use Only user_profiles Table
-- This will consolidate all user data into user_profiles
-- Run this in your Supabase SQL Editor
-- =====================================================

-- 1. First, check what tables exist and their structure
SELECT 
    table_name,
    'Table exists' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'users', 'user_profiles')
ORDER BY table_name;

-- 2. Create the final user_profiles table with all necessary fields
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON public.user_profiles(created_at);

-- 4. Migrate data from existing tables to user_profiles
-- First, try to migrate from 'users' table if it exists
INSERT INTO public.user_profiles (id, full_name, email, phone, avatar_url, role, created_at, updated_at)
SELECT 
    u.id,
    COALESCE(u.full_name, 'User') as full_name,
    COALESCE(au.email, 'unknown@email.com') as email,
    u.phone,
    u.avatar_url,
    COALESCE(u.role, 'user') as role,
    COALESCE(u.created_at, NOW()) as created_at,
    COALESCE(u.updated_at, NOW()) as updated_at
FROM public.users u
LEFT JOIN auth.users au ON u.id = au.id
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users' AND table_schema = 'public')
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    phone = EXCLUDED.phone,
    avatar_url = EXCLUDED.avatar_url,
    role = EXCLUDED.role,
    updated_at = NOW();

-- 5. Then migrate from 'profiles' table if it exists
INSERT INTO public.user_profiles (id, full_name, email, phone, avatar_url, role, created_at, updated_at)
SELECT 
    p.id,
    COALESCE(p.name, p.full_name, 'User') as full_name,
    COALESCE(au.email, 'unknown@email.com') as email,
    p.phone,
    COALESCE(p.profile_image, p.avatar_url) as avatar_url,
    COALESCE(p.role, 'user') as role,
    COALESCE(p.created_at, NOW()) as created_at,
    COALESCE(p.updated_at, p.last_login_at, NOW()) as updated_at
FROM public.profiles p
LEFT JOIN auth.users au ON p.id = au.id
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles' AND table_schema = 'public')
ON CONFLICT (id) DO UPDATE SET
    full_name = COALESCE(EXCLUDED.full_name, user_profiles.full_name),
    email = COALESCE(EXCLUDED.email, user_profiles.email),
    phone = COALESCE(EXCLUDED.phone, user_profiles.phone),
    avatar_url = COALESCE(EXCLUDED.avatar_url, user_profiles.avatar_url),
    role = COALESCE(EXCLUDED.role, user_profiles.role),
    updated_at = NOW();

-- 6. Insert your specific user data
INSERT INTO public.user_profiles (id, full_name, email, role, created_at, updated_at)
VALUES (
    '180f4b99-bd57-40cb-a47a-2f1917a67f22',
    'Mohamed Amine',
    'khazanimohamedamin@gmail.com',
    'admin',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    updated_at = NOW();

-- 7. Drop the old tables (be careful - backup data first if needed)
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.admin_users CASCADE;

-- 8. Disable RLS for now to avoid recursion issues
ALTER TABLE public.user_profiles DISABLE ROW LEVEL SECURITY;

-- 9. Create simple trigger for new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user_profile()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, full_name, email, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
        NEW.email,
        'user'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Create trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_profile();

-- 11. Create updated_at trigger
CREATE OR REPLACE FUNCTION update_user_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON public.user_profiles;
CREATE TRIGGER update_user_profiles_updated_at 
    BEFORE UPDATE ON public.user_profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION update_user_profiles_updated_at();

-- 12. Verification
SELECT 'Database cleanup completed! Only user_profiles table remains.' as status;

-- Check final table structure
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check your user data
SELECT 
    id,
    full_name,
    email,
    role,
    created_at,
    'Your profile data' as status
FROM public.user_profiles 
WHERE id = '180f4b99-bd57-40cb-a47a-2f1917a67f22';

-- Count total users
SELECT 
    COUNT(*) as total_users,
    'Total users in user_profiles' as status
FROM public.user_profiles;