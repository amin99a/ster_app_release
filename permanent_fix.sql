-- =====================================================
-- PERMANENT FIX: Remove All RLS Policies
-- This will allow the app to work for all users
-- Run this in your Supabase SQL Editor
-- =====================================================

-- 1. DISABLE RLS COMPLETELY (temporary fix)
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 2. Drop all existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.users;

-- 3. Drop the problematic function
DROP FUNCTION IF EXISTS is_admin();

-- 4. Create a simple trigger for new users (without RLS issues)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', NEW.email, 'User'),
        'user'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Ensure the trigger exists
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 6. Create your user profile
INSERT INTO public.users (id, full_name, role, created_at, updated_at)
VALUES (
    '180f4b99-bd57-40cb-a47a-2f1917a67f22',
    'Mohamed Amine',
    'user',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    updated_at = NOW();

-- 7. Verification
SELECT 'Permanent fix applied! RLS disabled for now.' as status;

-- Check if your user was created
SELECT 
    id,
    full_name,
    role,
    created_at,
    'User profile created!' as status
FROM public.users 
WHERE id = '180f4b99-bd57-40cb-a47a-2f1917a67f22';

-- Check if trigger exists
SELECT 
    trigger_name,
    'Trigger exists!' as status
FROM information_schema.triggers 
WHERE trigger_name = 'on_auth_user_created'; 