-- =====================================================
-- Supabase Authentication Layer - Complete Schema
-- =====================================================

-- 1. Create the users table with proper foreign key reference to auth.users
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create indexes for better performance
CREATE INDEX idx_users_role ON public.users(role);
CREATE INDEX idx_users_created_at ON public.users(created_at);
CREATE INDEX idx_users_phone ON public.users(phone) WHERE phone IS NOT NULL;

-- 3. Enable Row Level Security
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 4. Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 5. Create trigger for updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- 6. RLS Policies

-- Policy: Users can read their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Policy: Users can insert their own profile (for signup)
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Policy: Admins can view all profiles
CREATE POLICY "Admins can view all profiles" ON public.users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Policy: Admins can update all profiles
CREATE POLICY "Admins can update all profiles" ON public.users
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- 7. Automatic Profile Creation Trigger

-- Function to handle new user signup
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

-- Trigger to automatically create user profile on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 8. Helper Functions

-- Function to get user by ID (for admin use)
CREATE OR REPLACE FUNCTION get_user_by_id(user_id UUID)
RETURNS TABLE (
    id UUID,
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    role TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check if current user is admin
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Access denied: Admin role required';
    END IF;
    
    RETURN QUERY
    SELECT 
        u.id,
        u.full_name,
        u.phone,
        u.avatar_url,
        u.role,
        u.created_at,
        u.updated_at
    FROM public.users u
    WHERE u.id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update user role (admin only)
CREATE OR REPLACE FUNCTION update_user_role(
    user_id UUID,
    new_role TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check if current user is admin
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Access denied: Admin role required';
    END IF;
    
    -- Validate role
    IF new_role NOT IN ('guest', 'user', 'host', 'admin') THEN
        RAISE EXCEPTION 'Invalid role: %', new_role;
    END IF;
    
    -- Update role
    UPDATE public.users 
    SET role = new_role, updated_at = NOW()
    WHERE id = user_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all users (admin only)
CREATE OR REPLACE FUNCTION get_all_users()
RETURNS TABLE (
    id UUID,
    full_name TEXT,
    phone TEXT,
    avatar_url TEXT,
    role TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    -- Check if current user is admin
    IF NOT EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = auth.uid() AND role = 'admin'
    ) THEN
        RAISE EXCEPTION 'Access denied: Admin role required';
    END IF;
    
    RETURN QUERY
    SELECT 
        u.id,
        u.full_name,
        u.phone,
        u.avatar_url,
        u.role,
        u.created_at,
        u.updated_at
    FROM public.users u
    ORDER BY u.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Sample Data (Optional - for testing)

-- Insert sample admin user (replace with actual admin user ID)
-- INSERT INTO public.users (id, full_name, role) 
-- VALUES ('your-admin-user-id', 'Admin User', 'admin');

-- 10. Verification Queries

-- Check if table was created correctly
-- SELECT table_name, column_name, data_type, is_nullable 
-- FROM information_schema.columns 
-- WHERE table_name = 'users' AND table_schema = 'public';

-- Check if RLS is enabled
-- SELECT schemaname, tablename, rowsecurity 
-- FROM pg_tables 
-- WHERE tablename = 'users';

-- Check if policies were created
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
-- FROM pg_policies 
-- WHERE tablename = 'users';

-- Check if trigger was created
-- SELECT trigger_name, event_manipulation, action_statement 
-- FROM information_schema.triggers 
-- WHERE trigger_name = 'on_auth_user_created';

-- =====================================================
-- Usage Examples
-- =====================================================

-- 1. Sign up a new user (this will automatically create a profile)
-- The trigger will handle profile creation automatically

-- 2. Update user profile (user can only update their own)
-- UPDATE public.users 
-- SET full_name = 'New Name', phone = '+1234567890'
-- WHERE id = auth.uid();

-- 3. Admin can view all users
-- SELECT * FROM get_all_users();

-- 4. Admin can update user role
-- SELECT update_user_role('user-id-here', 'host');

-- 5. Admin can get specific user
-- SELECT * FROM get_user_by_id('user-id-here');

-- =====================================================
-- Migration from existing profiles table (if needed)
-- =====================================================

-- If you have an existing profiles table, you can migrate data:
/*
-- Create temporary table to store existing data
CREATE TEMP TABLE temp_profiles AS 
SELECT * FROM public.profiles;

-- Insert data into new users table
INSERT INTO public.users (id, full_name, phone, avatar_url, role, created_at, updated_at)
SELECT 
    id,
    COALESCE(name, 'User') as full_name,
    phone,
    profile_image as avatar_url,
    COALESCE(role, 'user') as role,
    created_at,
    COALESCE(last_login_at, created_at) as updated_at
FROM temp_profiles;

-- Drop temporary table
DROP TABLE temp_profiles;
*/ 