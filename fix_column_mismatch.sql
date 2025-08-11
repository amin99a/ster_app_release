-- Fix the column mismatch between 'name' and 'full_name' in user_profiles table
-- This addresses the NOT NULL constraint violation

-- First, let's see the current structure
DO $$
DECLARE
    has_name BOOLEAN := FALSE;
    has_full_name BOOLEAN := FALSE;
    name_nullable BOOLEAN := TRUE;
    full_name_nullable BOOLEAN := TRUE;
BEGIN
    -- Check if 'name' column exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'name'
        AND table_schema = 'public'
    ) INTO has_name;
    
    -- Check if 'full_name' column exists
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'full_name'
        AND table_schema = 'public'
    ) INTO has_full_name;
    
    -- Check if 'name' is nullable
    IF has_name THEN
        SELECT is_nullable = 'YES' INTO name_nullable
        FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'name'
        AND table_schema = 'public';
    END IF;
    
    -- Check if 'full_name' is nullable
    IF has_full_name THEN
        SELECT is_nullable = 'YES' INTO full_name_nullable
        FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'full_name'
        AND table_schema = 'public';
    END IF;
    
    RAISE NOTICE '=== USER_PROFILES TABLE ANALYSIS ===';
    RAISE NOTICE 'Has name column: % (nullable: %)', has_name, name_nullable;
    RAISE NOTICE 'Has full_name column: % (nullable: %)', has_full_name, full_name_nullable;
    
    -- Decision logic
    IF has_name AND NOT name_nullable THEN
        RAISE NOTICE 'ISSUE: name column exists and is NOT NULL - need to use this instead of full_name';
    END IF;
    
    IF has_full_name AND has_name THEN
        RAISE NOTICE 'ISSUE: Both name and full_name columns exist - need to consolidate';
    END IF;
END $$;

-- Drop existing triggers to avoid conflicts during fix
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Strategy 1: If both name and full_name exist, sync them and use name as primary
DO $$
DECLARE
    has_name BOOLEAN := FALSE;
    has_full_name BOOLEAN := FALSE;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' AND column_name = 'name' AND table_schema = 'public'
    ) INTO has_name;
    
    SELECT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_profiles' AND column_name = 'full_name' AND table_schema = 'public'
    ) INTO has_full_name;
    
    IF has_name AND has_full_name THEN
        -- Copy full_name to name where name is null
        UPDATE public.user_profiles 
        SET name = full_name 
        WHERE name IS NULL AND full_name IS NOT NULL;
        
        -- Copy name to full_name where full_name is null
        UPDATE public.user_profiles 
        SET full_name = name 
        WHERE full_name IS NULL AND name IS NOT NULL;
        
        RAISE NOTICE 'Synchronized name and full_name columns';
    END IF;
    
    IF has_name AND NOT has_full_name THEN
        -- Add full_name column and copy from name
        ALTER TABLE public.user_profiles ADD COLUMN full_name TEXT;
        UPDATE public.user_profiles SET full_name = name;
        RAISE NOTICE 'Added full_name column and copied from name';
    END IF;
    
    IF NOT has_name AND has_full_name THEN
        -- Rename full_name to name (this is likely the case)
        ALTER TABLE public.user_profiles RENAME COLUMN full_name TO name;
        RAISE NOTICE 'Renamed full_name column to name';
    END IF;
END $$;

-- Make sure name column is NOT NULL (set default for any null values)
UPDATE public.user_profiles 
SET name = COALESCE(name, 'User') 
WHERE name IS NULL;

-- Add NOT NULL constraint if it doesn't exist
DO $$
BEGIN
    BEGIN
        ALTER TABLE public.user_profiles ALTER COLUMN name SET NOT NULL;
        RAISE NOTICE 'Set name column to NOT NULL';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'name column constraint already exists or failed to set';
    END;
END $$;

-- Create the corrected trigger function that uses 'name' column
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert into user_profiles table using 'name' column (not full_name)
    INSERT INTO public.user_profiles (
        id, 
        name,  -- Use 'name' instead of 'full_name'
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
    
    RAISE NOTICE 'User profile created in user_profiles table for: % with name: %', NEW.email, COALESCE(NEW.raw_user_meta_data->>'name', 'User');
    RETURN NEW;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING 'Failed to create user_profiles entry for %: %', NEW.email, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create profiles for any existing auth users that don't have profiles
INSERT INTO public.user_profiles (
    id, 
    name,  -- Use 'name' instead of 'full_name'
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
ON CONFLICT (id) DO UPDATE SET
    name = COALESCE(EXCLUDED.name, public.user_profiles.name),
    email = COALESCE(EXCLUDED.email, public.user_profiles.email),
    updated_at = NOW();

-- Final verification
DO $$
DECLARE
    auth_count INTEGER;
    profile_count INTEGER;
    missing_profiles INTEGER;
    null_names INTEGER;
BEGIN
    SELECT COUNT(*) INTO auth_count FROM auth.users;
    SELECT COUNT(*) INTO profile_count FROM public.user_profiles;
    SELECT COUNT(*) INTO null_names FROM public.user_profiles WHERE name IS NULL;
    
    SELECT COUNT(*) INTO missing_profiles 
    FROM auth.users au
    WHERE NOT EXISTS (
        SELECT 1 FROM public.user_profiles up WHERE up.id = au.id
    );
    
    RAISE NOTICE '=== COLUMN MISMATCH FIX COMPLETE ===';
    RAISE NOTICE 'Auth users: %', auth_count;
    RAISE NOTICE 'User profiles: %', profile_count;
    RAISE NOTICE 'Missing profiles: %', missing_profiles;
    RAISE NOTICE 'Profiles with null names: %', null_names;
    
    IF missing_profiles = 0 AND null_names = 0 THEN
        RAISE NOTICE '✅ All issues fixed! Trigger now uses name column correctly.';
    ELSE
        RAISE NOTICE '❌ Still have issues to resolve';
    END IF;
END $$;