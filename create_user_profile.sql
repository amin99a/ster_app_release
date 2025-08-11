-- =====================================================
-- Create User Profile for Current User
-- Run this in your Supabase SQL Editor
-- =====================================================

-- Insert user profile for the current authenticated user
INSERT INTO public.users (id, full_name, role, created_at, updated_at)
VALUES (
    '180f4b99-bd57-40cb-a47a-2f1917a67f22', -- Your user ID from the error log
    'Khazani Mohamed Amin', -- Your name from the email
    'user', -- Start as regular user
    NOW(),
    NOW()
)
ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    role = EXCLUDED.role,
    updated_at = NOW();

-- Verify the user was created
SELECT 
    id,
    full_name,
    role,
    created_at,
    updated_at,
    'User profile created successfully!' as status
FROM public.users 
WHERE id = '180f4b99-bd57-40cb-a47a-2f1917a67f22';

-- If you want to make this user an admin, run this:
/*
UPDATE public.users 
SET role = 'admin', updated_at = NOW()
WHERE id = '180f4b99-bd57-40cb-a47a-2f1917a67f22';
*/ 