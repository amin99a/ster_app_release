-- Simple sample data for STER app
-- This creates basic profiles for testing

-- Insert sample profiles
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
VALUES 
  ('11111111-1111-1111-1111-111111111111', 'Test User 1', 'test1@gmail.com', '+213 123 456 789', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'user', true, true, '{"language": "en", "currency": "DZD", "notifications": true}', NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Test Host 1', 'host1@gmail.com', '+213 987 654 321', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 'host', true, true, '{"language": "en", "currency": "DZD", "notifications": true}', NOW()),
  ('33333333-3333-3333-3333-333333333333', 'Test Admin 1', 'admin1@gmail.com', '+213 555 123 456', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 'admin', true, true, '{"language": "en", "currency": "DZD", "notifications": true}', NOW())
ON CONFLICT (id) DO NOTHING;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Sample profiles created successfully!';
  RAISE NOTICE 'You can now create auth users with these emails:';
  RAISE NOTICE '- test1@gmail.com';
  RAISE NOTICE '- host1@gmail.com';
  RAISE NOTICE '- admin1@gmail.com';
END $$; 