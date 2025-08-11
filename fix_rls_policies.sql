-- =====================================================
-- Fix RLS Policies - Remove Infinite Recursion
-- Run this in your Supabase SQL Editor
-- =====================================================

-- 1. Drop all existing policies to start fresh
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.users;
DROP POLICY IF EXISTS "Admins can update all profiles" ON public.users;

-- 2. Create simplified RLS policies without recursion
-- Basic policy: Users can only access their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 3. Create a function to check if user is admin (without recursion)
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if the current user has admin role in their profile
    RETURN EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Create admin policies using the function
CREATE POLICY "Admins can view all profiles" ON public.users
    FOR SELECT USING (is_admin());

CREATE POLICY "Admins can update all profiles" ON public.users
    FOR UPDATE USING (is_admin());

-- 5. Create a manual admin user (replace with your actual user ID)
-- You can run this separately after creating your first admin
/*
INSERT INTO public.users (id, full_name, role, created_at, updated_at)
VALUES (
    '180f4b99-bd57-40cb-a47a-2f1917a67f22', -- Replace with your user ID
    'Admin User',
    'admin',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    updated_at = NOW();
*/

-- 6. Verification queries
SELECT 'RLS policies fixed successfully!' as status;

-- Check if policies were created
SELECT 
    policyname,
    permissive,
    cmd,
    'Policy created' as status
FROM pg_policies 
WHERE tablename = 'users' AND schemaname = 'public';

-- Check if function was created
SELECT 
    routine_name,
    'Function created' as status
FROM information_schema.routines 
WHERE routine_name = 'is_admin'; 