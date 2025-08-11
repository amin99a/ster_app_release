-- Confirm email for the test user that was just created
-- This allows immediate login without email confirmation

-- Update the auth.users table to confirm the email
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email = '54254661633@gmail.com';

-- Also update the profiles table to mark email as verified
UPDATE public.profiles 
SET is_email_verified = true 
WHERE email = '54254661633@gmail.com';

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Email confirmed for test user!';
  RAISE NOTICE 'You can now login with: 54254661633@gmail.com / password123';
END $$; 