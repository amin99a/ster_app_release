-- Check the role of the newly signed up user
-- This will help us understand why they're showing as guest

-- Show all profiles with their roles
SELECT 
  id,
  email,
  name,
  role,
  is_email_verified,
  created_at
FROM public.profiles 
ORDER BY created_at DESC 
LIMIT 10;

-- Check if there are any profiles with 'guest' role
SELECT 
  COUNT(*) as guest_count
FROM public.profiles 
WHERE role = 'guest';

-- Check if there are any profiles with 'user' role
SELECT 
  COUNT(*) as user_count
FROM public.profiles 
WHERE role = 'user';

-- Show the most recent user's full profile data
SELECT 
  p.*,
  au.email_confirmed_at,
  au.raw_user_meta_data
FROM public.profiles p
LEFT JOIN auth.users au ON p.id = au.id
ORDER BY p.created_at DESC 
LIMIT 5; 