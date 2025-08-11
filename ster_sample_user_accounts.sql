-- STER Car Rental App - Sample User Accounts
-- This file creates sample user accounts with different roles

-- =====================================================
-- SAMPLE USER ACCOUNTS (with existence check)
-- =====================================================

-- Note: These are sample accounts for testing purposes
-- In a real application, users would sign up through the app interface
-- These accounts use simple passwords for testing - change them in production

-- =====================================================
-- REGULAR USER ACCOUNTS
-- =====================================================

-- Sample User 1: Regular user account
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '11111111-1111-1111-1111-111111111111', 
  'Ahmed Benali', 
  'ahmed.benali@example.com', 
  '+213 123 456 789', 
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 
  'user', 
  true, 
  true, 
  '{"language": "ar", "currency": "DZD", "notifications": true}', 
  '2024-01-01 10:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'ahmed.benali@example.com');

-- Sample User 2: Another regular user
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '22222222-2222-2222-2222-222222222222', 
  'Fatima Zohra', 
  'fatima.zohra@example.com', 
  '+213 987 654 321', 
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 
  'user', 
  true, 
  false, 
  '{"language": "fr", "currency": "DZD", "notifications": true}', 
  '2024-01-15 14:30:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'fatima.zohra@example.com');

-- Sample User 3: Guest user
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '33333333-3333-3333-3333-333333333333', 
  'Guest User', 
  'guest@example.com', 
  NULL, 
  NULL, 
  'guest', 
  false, 
  false, 
  '{"language": "en", "currency": "DZD", "notifications": false}', 
  '2024-02-01 09:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'guest@example.com');

-- =====================================================
-- HOST ACCOUNTS
-- =====================================================

-- Sample Host 1: Professional car host
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '44444444-4444-4444-4444-444444444444', 
  'Hassan Host', 
  'hassan.host@example.com', 
  '+213 555 123 456', 
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 
  'host', 
  true, 
  true, 
  '{"language": "ar", "currency": "DZD", "notifications": true, "host_preferences": {"auto_approve": false, "instant_booking": true}}', 
  '2024-01-05 11:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'hassan.host@example.com');

-- Sample Host 2: Another host
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '55555555-5555-5555-5555-555555555555', 
  'Amina Host', 
  'amina.host@example.com', 
  '+213 777 888 999', 
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 
  'host', 
  true, 
  true, 
  '{"language": "fr", "currency": "DZD", "notifications": true, "host_preferences": {"auto_approve": true, "instant_booking": false}}', 
  '2024-01-10 16:45:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'amina.host@example.com');

-- Sample Host 3: Premium host
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '66666666-6666-6666-6666-666666666666', 
  'Omar Host', 
  'omar.host@example.com', 
  '+213 999 111 222', 
  'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 
  'host', 
  true, 
  true, 
  '{"language": "en", "currency": "DZD", "notifications": true, "host_preferences": {"auto_approve": true, "instant_booking": true}}', 
  '2024-01-20 13:20:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'omar.host@example.com');

-- =====================================================
-- ADMIN ACCOUNTS
-- =====================================================

-- Sample Admin 1: System administrator
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '77777777-7777-7777-7777-777777777777', 
  'Admin User', 
  'admin@ster.com', 
  '+213 111 222 333', 
  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 
  'admin', 
  true, 
  true, 
  '{"language": "en", "currency": "DZD", "notifications": true, "admin_preferences": {"dashboard_view": "full", "moderation_level": "high"}}', 
  '2024-01-01 08:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'admin@ster.com');

-- Sample Admin 2: Support admin
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, preferences, created_at)
SELECT 
  '88888888-8888-8888-8888-888888888888', 
  'Support Admin', 
  'support@ster.com', 
  '+213 444 555 666', 
  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 
  'admin', 
  true, 
  true, 
  '{"language": "ar", "currency": "DZD", "notifications": true, "admin_preferences": {"dashboard_view": "support", "moderation_level": "medium"}}', 
  '2024-01-02 09:30:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.profiles WHERE email = 'support@ster.com');

-- =====================================================
-- SAMPLE HOST REQUESTS (for users who want to become hosts)
-- =====================================================

-- Host request from a regular user
INSERT INTO public.host_requests (user_id, request_note, status, created_at)
SELECT 
  (SELECT id FROM public.profiles WHERE email = 'ahmed.benali@example.com' LIMIT 1),
  'I would like to become a host to share my car with the community. I have a clean driving record and maintain my vehicle well.',
  'pending',
  '2024-02-15 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.host_requests hr 
  JOIN public.profiles p ON hr.user_id = p.id 
  WHERE p.email = 'ahmed.benali@example.com'
);

-- =====================================================
-- SAMPLE NOTIFICATIONS
-- =====================================================

-- Welcome notification for new user
INSERT INTO public.notifications (user_id, title, message, type, data, created_at)
SELECT 
  (SELECT id FROM public.profiles WHERE email = 'ahmed.benali@example.com' LIMIT 1),
  'Welcome to STER!',
  'Thank you for joining STER. Start exploring cars in your area.',
  'info',
  '{"action": "explore_cars", "deep_link": "/cars"}',
  '2024-01-01 10:05:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.notifications n 
  JOIN public.profiles p ON n.user_id = p.id 
  WHERE p.email = 'ahmed.benali@example.com' AND n.title = 'Welcome to STER!'
);

-- Host approval notification
INSERT INTO public.notifications (user_id, title, message, type, data, created_at)
SELECT 
  (SELECT id FROM public.profiles WHERE email = 'hassan.host@example.com' LIMIT 1),
  'Host Account Approved',
  'Congratulations! Your host account has been approved. You can now list your cars.',
  'success',
  '{"action": "list_car", "deep_link": "/host/dashboard"}',
  '2024-01-05 11:05:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.notifications n 
  JOIN public.profiles p ON n.user_id = p.id 
  WHERE p.email = 'hassan.host@example.com' AND n.title = 'Host Account Approved'
);

-- =====================================================
-- SAMPLE FAVORITES (for users)
-- =====================================================

-- User adds a car to favorites
INSERT INTO public.favorites (user_id, car_id, created_at)
SELECT 
  (SELECT id FROM public.profiles WHERE email = 'ahmed.benali@example.com' LIMIT 1),
  (SELECT id FROM public.cars WHERE name = 'Toyota RAV4 2023' LIMIT 1),
  '2024-02-20 15:30:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.favorites f 
  JOIN public.profiles p ON f.user_id = p.id 
  JOIN public.cars c ON f.car_id = c.id 
  WHERE p.email = 'ahmed.benali@example.com' AND c.name = 'Toyota RAV4 2023'
);

-- Another favorite
INSERT INTO public.favorites (user_id, car_id, created_at)
SELECT 
  (SELECT id FROM public.profiles WHERE email = 'fatima.zohra@example.com' LIMIT 1),
  (SELECT id FROM public.cars WHERE name = 'Tesla Model 3 2023' LIMIT 1),
  '2024-02-21 12:15:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.favorites f 
  JOIN public.profiles p ON f.user_id = p.id 
  JOIN public.cars c ON f.car_id = c.id 
  WHERE p.email = 'fatima.zohra@example.com' AND c.name = 'Tesla Model 3 2023'
);

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

-- This will show a success message if the script runs without errors
DO $$
BEGIN
  RAISE NOTICE 'Sample user accounts created successfully!';
  RAISE NOTICE 'Users: ahmed.benali@example.com, fatima.zohra@example.com, guest@example.com';
  RAISE NOTICE 'Hosts: hassan.host@example.com, amina.host@example.com, omar.host@example.com';
  RAISE NOTICE 'Admins: admin@ster.com, support@ster.com';
END $$;

-- =====================================================
-- END OF SAMPLE USER ACCOUNTS
-- ===================================================== 