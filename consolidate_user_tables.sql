-- =====================================================
-- Consolidate User Tables - Keep Only 'users'
-- This will merge all user data into one table
-- Run this in your Supabase SQL Editor
-- =====================================================

-- 1. First, let's see what we're working with
SELECT 'Current tables:' as info;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'users', 'user_profile');

-- 2. Backup any data from other tables before dropping
-- (This creates a backup table with all user data)
CREATE TABLE IF NOT EXISTS public.user_backup AS
SELECT 
    COALESCE(p.id, u.id, up.id) as id,
    COALESCE(p.name, u.full_name, up.name) as full_name,
    COALESCE(p.email, u.email, up.email) as email,
    COALESCE(p.phone, u.phone, up.phone) as phone,
    COALESCE(p.profile_image, u.avatar_url, up.avatar_url) as avatar_url,
    COALESCE(u.role, 'user') as role,
    COALESCE(p.created_at, u.created_at, up.created_at, NOW()) as created_at,
    COALESCE(p.updated_at, u.updated_at, up.updated_at, NOW()) as updated_at
FROM public.profiles p
FULL OUTER JOIN public.users u ON p.id = u.id
FULL OUTER JOIN public.user_profile up ON COALESCE(p.id, u.id) = up.id;

-- 3. Drop the old tables
DROP TABLE IF EXISTS public.profiles CASCADE;
DROP TABLE IF EXISTS public.user_profile CASCADE;

-- 4. Ensure the users table has the correct structure
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 5. Insert any missing data from backup
INSERT INTO public.users (id, full_name, email, phone, avatar_url, role, created_at, updated_at)
SELECT 
    id,
    full_name,
    email,
    phone,
    avatar_url,
    role,
    created_at,
    updated_at
FROM public.user_backup
ON CONFLICT (id) DO UPDATE SET
    full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
    email = COALESCE(EXCLUDED.email, public.users.email),
    phone = COALESCE(EXCLUDED.phone, public.users.phone),
    avatar_url = COALESCE(EXCLUDED.avatar_url, public.users.avatar_url),
    role = COALESCE(EXCLUDED.role, public.users.role),
    updated_at = NOW();

-- 6. Create your user profile if it doesn't exist
INSERT INTO public.users (id, full_name, email, role, created_at, updated_at)
VALUES (
    '180f4b99-bd57-40cb-a47a-2f1917a67f22',
    'Mohamed Amine',
    'khazanimohamedamin@gmail.com',
    'user',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    updated_at = NOW();

-- 7. Clean up
DROP TABLE IF EXISTS public.user_backup;

-- 8. Verification
SELECT 'Consolidation complete!' as status;

-- Check final structure
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'users'
ORDER BY ordinal_position;

-- Check your user data
SELECT 
    id,
    full_name,
    email,
    role,
    created_at,
    'User data verified!' as status
FROM public.users 
WHERE id = '180f4b99-bd57-40cb-a47a-2f1917a67f22'; 