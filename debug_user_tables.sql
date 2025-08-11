-- Debug script to check what user tables exist and their structure
-- Run this in your Supabase SQL Editor to understand the current state

-- Check what tables exist
SELECT table_name, table_schema 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('users', 'profiles', 'user_profiles')
ORDER BY table_name;

-- Check columns in user_profiles table (if it exists)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check columns in profiles table (if it exists)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check columns in users table (if it exists)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'users' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check existing triggers
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers 
WHERE trigger_name LIKE '%user%' OR trigger_name LIKE '%auth%'
ORDER BY trigger_name;

-- Check if any profiles exist
DO $$
DECLARE
    user_profiles_count INTEGER := 0;
    profiles_count INTEGER := 0;
    users_count INTEGER := 0;
    auth_users_count INTEGER := 0;
BEGIN
    -- Count auth.users
    SELECT COUNT(*) INTO auth_users_count FROM auth.users;
    
    -- Try to count user_profiles
    BEGIN
        SELECT COUNT(*) INTO user_profiles_count FROM public.user_profiles;
    EXCEPTION WHEN undefined_table THEN
        user_profiles_count := -1; -- Table doesn't exist
    END;
    
    -- Try to count profiles
    BEGIN
        SELECT COUNT(*) INTO profiles_count FROM public.profiles;
    EXCEPTION WHEN undefined_table THEN
        profiles_count := -1; -- Table doesn't exist
    END;
    
    -- Try to count users
    BEGIN
        SELECT COUNT(*) INTO users_count FROM public.users;
    EXCEPTION WHEN undefined_table THEN
        users_count := -1; -- Table doesn't exist
    END;
    
    RAISE NOTICE '=== TABLE COUNTS ===';
    RAISE NOTICE 'auth.users: %', auth_users_count;
    RAISE NOTICE 'public.user_profiles: % (% = table does not exist)', user_profiles_count, CASE WHEN user_profiles_count = -1 THEN '-1' ELSE 'exists' END;
    RAISE NOTICE 'public.profiles: % (% = table does not exist)', profiles_count, CASE WHEN profiles_count = -1 THEN '-1' ELSE 'exists' END;
    RAISE NOTICE 'public.users: % (% = table does not exist)', users_count, CASE WHEN users_count = -1 THEN '-1' ELSE 'exists' END;
END $$;