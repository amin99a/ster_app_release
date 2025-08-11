-- Create auth users with passwords for testing
-- This creates both auth.users entries and profiles

-- First, create auth users with passwords
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, created_at, updated_at)
VALUES 
  ('44444444-4444-4444-4444-444444444444', 'hassan.host@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555555', 'amina.host@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('66666666-6666-6666-6666-666666666666', 'omar.host@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('11111111-1111-1111-1111-111111111111', 'ahmed.benali@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222222', 'fatima.zohra@example.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('77777777-7777-7777-7777-777777777777', 'admin@ster.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW()),
  ('88888888-8888-8888-8888-888888888888', 'support@ster.com', crypt('password123', gen_salt('bf')), NOW(), NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Then create profiles (the trigger should handle this, but let's ensure they exist)
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
VALUES 
  ('44444444-4444-4444-4444-444444444444', 'Hassan Host', 'hassan.host@example.com', '+213 555 123 456', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'host', true, true, '{"language": "ar", "currency": "DZD", "notifications": true}', NOW()),
  ('55555555-5555-5555-5555-555555555555', 'Amina Host', 'amina.host@example.com', '+213 777 888 999', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 'host', true, true, '{"language": "fr", "currency": "DZD", "notifications": true}', NOW()),
  ('66666666-6666-6666-6666-666666666666', 'Omar Host', 'omar.host@example.com', '+213 999 111 222', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 'host', true, true, '{"language": "en", "currency": "DZD", "notifications": true}', NOW()),
  ('11111111-1111-1111-1111-111111111111', 'Ahmed Benali', 'ahmed.benali@example.com', '+213 123 456 789', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'user', true, true, '{"language": "ar", "currency": "DZD", "notifications": true}', NOW()),
  ('22222222-2222-2222-2222-222222222222', 'Fatima Zohra', 'fatima.zohra@example.com', '+213 987 654 321', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 'user', true, false, '{"language": "fr", "currency": "DZD", "notifications": true}', NOW()),
  ('77777777-7777-7777-7777-777777777777', 'Admin User', 'admin@ster.com', '+213 111 222 333', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'admin', true, true, '{"language": "en", "currency": "DZD", "notifications": true}', NOW()),
  ('88888888-8888-8888-8888-888888888888', 'Support Admin', 'support@ster.com', '+213 444 555 666', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 'admin', true, true, '{"language": "ar", "currency": "DZD", "notifications": true}', NOW())
ON CONFLICT (id) DO NOTHING;

-- Success message
DO $$
BEGIN
  RAISE NOTICE 'Auth users and profiles created successfully!';
  RAISE NOTICE 'You can now login with:';
  RAISE NOTICE '- hassan.host@example.com / password123';
  RAISE NOTICE '- amina.host@example.com / password123';
  RAISE NOTICE '- omar.host@example.com / password123';
  RAISE NOTICE '- ahmed.benali@example.com / password123';
  RAISE NOTICE '- fatima.zohra@example.com / password123';
  RAISE NOTICE '- admin@ster.com / password123';
  RAISE NOTICE '- support@ster.com / password123';
END $$; 