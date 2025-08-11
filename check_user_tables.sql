-- =====================================================
-- Check User-Related Tables
-- Run this in your Supabase SQL Editor
-- =====================================================

-- Check what tables exist
SELECT 
    table_name,
    'Table exists' as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'users', 'user_profile');

-- Check table structures
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('profiles', 'users', 'user_profile')
ORDER BY table_name, ordinal_position;

-- Check if tables have data
SELECT 'profiles' as table_name, COUNT(*) as row_count FROM public.profiles
UNION ALL
SELECT 'users' as table_name, COUNT(*) as row_count FROM public.users
UNION ALL
SELECT 'user_profile' as table_name, COUNT(*) as row_count FROM public.user_profile; 