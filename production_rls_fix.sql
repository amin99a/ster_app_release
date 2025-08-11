-- =====================================================
-- PRODUCTION RLS FIX: Proper Security Implementation
-- This creates a secure, non-recursive RLS system
-- Run this AFTER the permanent_fix.sql
-- =====================================================

-- 1. Re-enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 2. Create a simple, secure policy system
-- Users can only access their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- 3. Create a separate admin table for role management
CREATE TABLE IF NOT EXISTS public.admin_users (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create admin policies using the separate table
CREATE POLICY "Admins can view all profiles" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.admin_users 
            WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Admins can update all profiles" ON public.users
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.admin_users 
            WHERE user_id = auth.uid()
        )
    );

-- 5. Add you as an admin (optional)
INSERT INTO public.admin_users (user_id)
VALUES ('180f4b99-bd57-40cb-a47a-2f1917a67f22')
ON CONFLICT (user_id) DO NOTHING;

-- 6. Update your role to admin in the users table
UPDATE public.users 
SET role = 'admin', updated_at = NOW()
WHERE id = '180f4b99-bd57-40cb-a47a-2f1917a67f22';

-- 7. Verification
SELECT 'Production RLS fix applied!' as status;

-- Check if you're now an admin
SELECT 
    u.id,
    u.full_name,
    u.role,
    CASE WHEN au.user_id IS NOT NULL THEN 'Admin access granted' ELSE 'Regular user' END as admin_status
FROM public.users u
LEFT JOIN public.admin_users au ON u.id = au.user_id
WHERE u.id = '180f4b99-bd57-40cb-a47a-2f1917a67f22'; 