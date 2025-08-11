-- Disable email confirmation requirement for testing
-- This allows users to login immediately after signup

-- Update Supabase auth settings to disable email confirmation
UPDATE auth.config 
SET email_confirmation_required = false 
WHERE id = 1;

-- Also update any existing users to have confirmed emails
UPDATE auth.users 
SET email_confirmed_at = NOW() 
WHERE email_confirmed_at IS NULL;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Email confirmation requirement disabled!';
  RAISE NOTICE 'Users can now login immediately after signup.';
END $$; 