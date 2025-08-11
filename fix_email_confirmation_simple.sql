-- Simple fix: Confirm all existing users' emails
-- This allows immediate login without email confirmation

-- Confirm all existing users' emails
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;

-- Also update profiles to mark emails as verified
UPDATE public.profiles 
SET is_email_verified = true 
WHERE is_email_verified = false;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'All user emails confirmed!';
  RAISE NOTICE 'Users can now login immediately.';
  RAISE NOTICE 'Test with: 54254661633@gmail.com / password123';
END $$; 