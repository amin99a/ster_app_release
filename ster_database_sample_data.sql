-- STER Car Rental App - Sample Data
-- This file contains realistic test data for all database tables

-- =====================================================
-- SAMPLE USERS/PROFILES
-- =====================================================

-- Note: In Supabase, user profiles are automatically created when users sign up
-- through the authentication system. The profiles table has a foreign key constraint
-- to auth.users, so we cannot insert profiles directly.
-- 
-- To create test users, you need to:
-- 1. Sign up users through your app's authentication
-- 2. Or manually create users in the Supabase Auth dashboard
-- 3. Then update their profiles with the data below
--
-- For now, we'll skip profile insertion and focus on other tables
-- that don't have foreign key constraints to auth.users

-- Sample profile data for reference (use this after creating auth users):
/*
INSERT INTO public.profiles (id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, created_at) VALUES
-- Regular Users
('USER_UUID_HERE', 'Ahmed Benali', 'ahmed@example.com', '+213 123 456 789', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'user', true, true, '2024-01-15 10:00:00+00'),
('USER_UUID_HERE', 'Fatima Zohra', 'fatima@example.com', '+213 234 567 890', 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150', 'user', true, false, '2024-01-20 14:30:00+00'),
('USER_UUID_HERE', 'Karim Boudiaf', 'karim@example.com', '+213 345 678 901', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150', 'user', true, true, '2024-02-01 09:15:00+00'),
('USER_UUID_HERE', 'Nour El Houda', 'nour@example.com', '+213 456 789 012', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150', 'user', true, true, '2024-02-10 16:45:00+00'),

-- Hosts
('USER_UUID_HERE', 'Hassan Host', 'hassan@example.com', '+213 567 890 123', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 'host', true, true, '2024-01-05 08:00:00+00'),
('USER_UUID_HERE', 'Amina Host', 'amina@example.com', '+213 678 901 234', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 'host', true, true, '2024-01-12 11:20:00+00'),
('USER_UUID_HERE', 'Omar Host', 'omar@example.com', '+213 789 012 345', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 'host', true, false, '2024-01-25 13:10:00+00'),

-- Admin
('USER_UUID_HERE', 'Admin User', 'admin@ster.com', '+213 890 123 456', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150', 'admin', true, true, '2024-01-01 00:00:00+00');
*/

-- =====================================================
-- SAMPLE CATEGORIES
-- =====================================================

INSERT INTO public.categories (id, name, description, icon, image, created_at) VALUES
('c1111111-1111-1111-1111-111111111111', 'SUV', 'Sport Utility Vehicles perfect for family trips and off-road adventures', '🚙', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400', '2024-01-01 00:00:00+00'),
('c2222222-2222-2222-2222-222222222222', 'Luxury', 'Premium vehicles for special occasions and business travel', '🏎️', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400', '2024-01-01 00:00:00+00'),
('c3333333-3333-3333-3333-333333333333', 'Electric', 'Environmentally friendly electric cars for eco-conscious travelers', '⚡', 'https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400', '2024-01-01 00:00:00+00'),
('c4444444-4444-4444-4444-444444444444', 'Convertible', 'Open-top driving experience for sunny days', '🌞', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', '2024-01-01 00:00:00+00'),
('c5555555-5555-5555-5555-555555555555', 'Business', 'Professional vehicles for business travel and meetings', '💼', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', '2024-01-01 00:00:00+00'),
('c6666666-6666-6666-6666-666666666666', 'Sport', 'High-performance sports cars for thrill seekers', '🏁', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', '2024-01-01 00:00:00+00'),
('c7777777-7777-7777-7777-777777777777', 'Mini', 'Compact cars perfect for city driving and parking', '🚗', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', '2024-01-01 00:00:00+00');

-- =====================================================
-- SAMPLE CARS
-- =====================================================

INSERT INTO public.cars (id, name, image, price_per_day, category_id, rating, trips, location, host_id, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at) VALUES
-- SUV Category
('car1111-1111-1111-1111-111111111111', 'Toyota RAV4 2023', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400', 120.00, 'c1111111-1111-1111-1111-111111111111', 4.8, 45, 'Algiers', '55555555-5555-5555-5555-555555555555', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 1 hour', 'Perfect SUV for family trips with excellent fuel economy and spacious interior.', '["GPS Navigation", "Bluetooth", "Backup Camera", "Cruise Control", "Heated Seats"]', '["https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400", "https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "2.5L 4-Cylinder", "Power": "203 HP", "Fuel Economy": "28 MPG", "Seating": "5 passengers"}', 'Automatic', 'Hybrid', 5, true, true, '2024-01-15 10:00:00+00'),

('car2222-2222-2222-2222-222222222222', 'Honda CR-V 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 110.00, 'c1111111-1111-1111-1111-111111111111', 4.6, 32, 'Oran', '66666666-6666-6666-6666-666666666666', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 30 minutes', 'Reliable SUV with great safety features and comfortable ride.', '["Apple CarPlay", "Android Auto", "Lane Departure Warning", "Blind Spot Monitor", "Emergency Braking"]', '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "1.5L Turbo", "Power": "190 HP", "Fuel Economy": "30 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, false, '2024-01-20 14:30:00+00'),

-- Luxury Category
('car3333-3333-3333-3333-333333333333', 'Mercedes-Benz S-Class 2023', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400', 350.00, 'c2222222-2222-2222-2222-222222222222', 4.9, 18, 'Algiers', '55555555-5555-5555-5555-555555555555', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 15 minutes', 'Ultimate luxury sedan with premium features and exceptional comfort.', '["Massage Seats", "Burmester Sound System", "Ambient Lighting", "Heads-up Display", "Night Vision"]', '["https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400"]', '{"Engine": "3.0L 6-Cylinder", "Power": "429 HP", "Fuel Economy": "22 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, true, '2024-02-01 09:15:00+00'),

('car4444-4444-4444-4444-444444444444', 'BMW 7 Series 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 320.00, 'c2222222-2222-2222-2222-222222222222', 4.7, 25, 'Constantine', '77777777-7777-7777-7777-777777777777', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 45 minutes', 'Executive sedan with cutting-edge technology and refined performance.', '["Gesture Control", "Wireless Charging", "Panoramic Roof", "Premium Audio", "Driver Assistance"]', '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', '{"Engine": "3.0L 6-Cylinder", "Power": "335 HP", "Fuel Economy": "25 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, false, '2024-02-10 16:45:00+00'),

-- Electric Category
('car5555-5555-5555-5555-555555555555', 'Tesla Model 3 2023', 'https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400', 180.00, 'c3333333-3333-3333-3333-333333333333', 4.8, 38, 'Algiers', '66666666-6666-6666-6666-666666666666', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 20 minutes', 'Zero-emission electric vehicle with instant acceleration and autopilot features.', '["Autopilot", "Supercharging", "Glass Roof", "Premium Audio", "Over-the-air Updates"]', '["https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400"]', '{"Battery": "75 kWh", "Range": "358 miles", "Power": "450 HP", "Seating": "5 passengers"}', 'Automatic', 'Electric', 5, true, true, '2024-01-25 13:10:00+00'),

-- Convertible Category
('car6666-6666-6666-6666-666666666666', 'BMW Z4 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 200.00, 'c4444444-4444-4444-4444-444444444444', 4.6, 22, 'Oran', '77777777-7777-7777-7777-777777777777', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 1 hour', 'Open-top sports car perfect for coastal drives and weekend getaways.', '["Convertible Top", "Sport Seats", "Premium Audio", "Navigation", "Parking Sensors"]', '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', '{"Engine": "2.0L 4-Cylinder", "Power": "255 HP", "Fuel Economy": "28 MPG", "Seating": "2 passengers"}', 'Automatic', 'Gasoline', 2, true, false, '2024-02-05 11:20:00+00'),

-- Business Category
('car7777-7777-7777-7777-777777777777', 'Audi A6 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 150.00, 'c5555555-5555-5555-5555-555555555555', 4.5, 28, 'Constantine', '55555555-5555-5555-5555-555555555555', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 30 minutes', 'Professional sedan ideal for business meetings and corporate travel.', '["Quattro AWD", "Virtual Cockpit", "MMI Navigation", "Bang & Olufsen Audio", "Driver Assistance"]', '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "2.0L 4-Cylinder", "Power": "248 HP", "Fuel Economy": "27 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, false, '2024-01-30 15:45:00+00'),

-- Sport Category
('car8888-8888-8888-8888-888888888888', 'Porsche 911 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 400.00, 'c6666666-6666-6666-6666-666666666666', 4.9, 15, 'Algiers', '66666666-6666-6666-6666-666666666666', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 15 minutes', 'Iconic sports car with legendary performance and precision engineering.', '["Sport Chrono Package", "PASM Suspension", "Sport Exhaust", "Carbon Fiber Interior", "Track Mode"]', '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', '{"Engine": "3.0L 6-Cylinder", "Power": "379 HP", "Fuel Economy": "20 MPG", "Seating": "4 passengers"}', 'Manual', 'Gasoline', 4, true, true, '2024-02-15 12:00:00+00'),

-- Mini Category
('car9999-9999-9999-9999-999999999999', 'Mini Cooper 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 80.00, 'c7777777-7777-7777-7777-777777777777', 4.4, 35, 'Oran', '77777777-7777-7777-7777-777777777777', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 45 minutes', 'Compact and stylish city car perfect for urban driving and parking.', '["Mini Connected", "LED Headlights", "Sport Suspension", "Premium Audio", "Parking Sensors"]', '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "1.5L 3-Cylinder", "Power": "134 HP", "Fuel Economy": "32 MPG", "Seating": "4 passengers"}', 'Automatic', 'Gasoline', 4, true, false, '2024-02-20 09:30:00+00');

-- =====================================================
-- SAMPLE BOOKINGS
-- =====================================================

INSERT INTO public.bookings (id, car_id, user_id, host_id, start_date, end_date, total_price, status, notes, created_at) VALUES
-- Completed bookings
('book1111-1111-1111-1111-111111111111', 'car1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', '55555555-5555-5555-5555-555555555555', '2024-01-20', '2024-01-22', 240.00, 'completed', 'Great experience, car was in perfect condition', '2024-01-18 10:00:00+00'),
('book2222-2222-2222-2222-222222222222', 'car3333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', '2024-01-25', '2024-01-27', 700.00, 'completed', 'Luxury car experience was amazing', '2024-01-23 14:30:00+00'),
('book3333-3333-3333-3333-333333333333', 'car5555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', '66666666-6666-6666-6666-666666666666', '2024-02-01', '2024-02-03', 360.00, 'completed', 'Electric car was very smooth and quiet', '2024-01-30 09:15:00+00'),

-- Active bookings
('book4444-4444-4444-4444-444444444444', 'car2222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', '66666666-6666-6666-6666-666666666666', '2024-03-15', '2024-03-17', 220.00, 'confirmed', 'Looking forward to the trip', '2024-03-10 16:45:00+00'),
('book5555-5555-5555-5555-555555555555', 'car8888-8888-8888-8888-888888888888', '11111111-1111-1111-1111-111111111111', '66666666-6666-6666-6666-666666666666', '2024-03-20', '2024-03-22', 800.00, 'confirmed', 'Special occasion booking', '2024-03-12 11:20:00+00'),

-- Pending bookings
('book6666-6666-6666-6666-666666666666', 'car7777-7777-7777-7777-777777777777', '22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', '2024-04-01', '2024-04-03', 300.00, 'pending', 'Business trip booking', '2024-03-25 13:10:00+00');

-- =====================================================
-- SAMPLE REVIEWS
-- =====================================================

INSERT INTO public.reviews (id, reviewer_id, reviewer_name, reviewer_image, target_id, type, overall_rating, category_ratings, title, content, photos, status, helpful_votes, total_votes, created_at, published_at) VALUES
-- Car reviews
('rev1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Ahmed Benali', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', 'car1111-1111-1111-1111-111111111111', 'car', 4.8, '{"comfort": 5.0, "performance": 4.5, "cleanliness": 5.0, "value": 4.8}', 'Excellent SUV for family trips', 'The Toyota RAV4 was perfect for our family vacation. Clean, comfortable, and fuel-efficient. Hassan was a great host with excellent communication.', '[]', 'approved', 12, 15, '2024-01-23 10:00:00+00', '2024-01-23 10:00:00+00'),

('rev2222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'Fatima Zohra', 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150', 'car3333-3333-3333-3333-333333333333', 'car', 4.9, '{"comfort": 5.0, "performance": 5.0, "cleanliness": 5.0, "value": 4.8}', 'Luxury at its finest', 'The Mercedes S-Class exceeded all expectations. Smooth ride, premium features, and exceptional service from Hassan. Highly recommended!', '[]', 'approved', 18, 20, '2024-01-28 14:30:00+00', '2024-01-28 14:30:00+00'),

('rev3333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'Karim Boudiaf', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150', 'car5555-5555-5555-5555-555555555555', 'car', 4.7, '{"comfort": 4.5, "performance": 5.0, "cleanliness": 5.0, "value": 4.5}', 'Amazing electric experience', 'Tesla Model 3 was incredible! Instant acceleration, autopilot features, and zero emissions. Amina was very helpful with charging instructions.', '[]', 'approved', 8, 10, '2024-02-04 09:15:00+00', '2024-02-04 09:15:00+00'),

-- Host reviews
('rev4444-4444-4444-4444-444444444444', '11111111-1111-1111-1111-111111111111', 'Ahmed Benali', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150', '55555555-5555-5555-5555-555555555555', 'host', 4.9, '{"communication": 5.0, "cleanliness": 5.0, "punctuality": 4.8, "overall": 4.9}', 'Excellent host experience', 'Hassan was an amazing host! Very responsive, clean cars, and great communication throughout the entire process.', '[]', 'approved', 15, 18, '2024-01-23 10:00:00+00', '2024-01-23 10:00:00+00'),

('rev5555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', 'Fatima Zohra', 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150', '66666666-6666-6666-6666-666666666666', 'host', 4.8, '{"communication": 4.8, "cleanliness": 5.0, "punctuality": 4.7, "overall": 4.8}', 'Professional and friendly', 'Amina was very professional and friendly. Her cars are always in perfect condition and she responds quickly to messages.', '[]', 'approved', 12, 15, '2024-01-28 14:30:00+00', '2024-01-28 14:30:00+00');

-- =====================================================
-- SAMPLE FAVORITES
-- =====================================================

INSERT INTO public.favorites (id, user_id, car_id, created_at) VALUES
('fav1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'car1111-1111-1111-1111-111111111111', '2024-01-20 10:00:00+00'),
('fav2222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'car3333-3333-3333-3333-333333333333', '2024-01-25 14:30:00+00'),
('fav3333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'car5555-5555-5555-5555-555555555555', '2024-02-01 09:15:00+00'),
('fav4444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', 'car8888-8888-8888-8888-888888888888', '2024-02-15 12:00:00+00'),
('fav5555-5555-5555-5555-555555555555', '44444444-4444-4444-4444-444444444444', 'car2222-2222-2222-2222-222222222222', '2024-02-20 16:45:00+00');

-- =====================================================
-- SAMPLE NOTIFICATIONS
-- =====================================================

INSERT INTO public.notifications (id, user_id, title, message, type, read, data, created_at) VALUES
('not1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Booking Confirmed', 'Your booking for Toyota RAV4 has been confirmed for March 20-22', 'success', false, '{"booking_id": "book5555-5555-5555-5555-555555555555"}', '2024-03-12 11:20:00+00'),
('not2222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'New Review', 'Ahmed left a 5-star review for your Mercedes S-Class', 'info', false, '{"review_id": "rev2222-2222-2222-2222-222222222222"}', '2024-01-28 14:30:00+00'),
('not3333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'Payment Received', 'Payment of $360 has been received for your Tesla Model 3 rental', 'success', true, '{"payment_id": "pay3333-3333-3333-3333-333333333333"}', '2024-02-01 09:15:00+00'),
('not4444-4444-4444-4444-444444444444', '44444444-4444-4444-4444-444444444444', 'Reminder', 'Your Honda CR-V rental starts tomorrow. Don''t forget to check the car!', 'warning', false, '{"booking_id": "book4444-4444-4444-4444-444444444444"}', '2024-03-14 16:45:00+00');

-- =====================================================
-- SAMPLE PAYMENTS
-- =====================================================

INSERT INTO public.payments (id, user_id, booking_id, type, method, status, amount, currency, final_amount, transaction_id, payment_gateway, created_at, completed_at) VALUES
('pay1111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'book1111-1111-1111-1111-111111111111', 'rental_payment', 'credit_card', 'completed', 240.00, 'USD', 240.00, 'txn_123456789', 'stripe', '2024-01-18 10:00:00+00', '2024-01-18 10:05:00+00'),
('pay2222-2222-2222-2222-222222222222', '22222222-2222-2222-2222-222222222222', 'book2222-2222-2222-2222-222222222222', 'rental_payment', 'credit_card', 'completed', 700.00, 'USD', 700.00, 'txn_987654321', 'stripe', '2024-01-23 14:30:00+00', '2024-01-23 14:35:00+00'),
('pay3333-3333-3333-3333-333333333333', '33333333-3333-3333-3333-333333333333', 'book3333-3333-3333-3333-333333333333', 'rental_payment', 'digital_wallet', 'completed', 360.00, 'USD', 360.00, 'txn_456789123', 'paypal', '2024-01-30 09:15:00+00', '2024-01-30 09:20:00+00'),
('pay4444-4444-4444-4444-444444444444', '44444444-4444-4444-4444-444444444444', 'book4444-4444-4444-4444-444444444444', 'rental_payment', 'credit_card', 'completed', 220.00, 'USD', 220.00, 'txn_789123456', 'stripe', '2024-03-10 16:45:00+00', '2024-03-10 16:50:00+00'),
('pay5555-5555-5555-5555-555555555555', '11111111-1111-1111-1111-111111111111', 'book5555-5555-5555-5555-555555555555', 'rental_payment', 'credit_card', 'completed', 800.00, 'USD', 800.00, 'txn_321654987', 'stripe', '2024-03-12 11:20:00+00', '2024-03-12 11:25:00+00');

-- =====================================================
-- SAMPLE LOCATIONS
-- =====================================================

INSERT INTO public.locations (id, name, city, state, country, latitude, longitude, created_at) VALUES
('loc1111-1111-1111-1111-111111111111', 'Algiers Center', 'Algiers', 'Algiers Province', 'Algeria', 36.7538, 3.0588, '2024-01-01 00:00:00+00'),
('loc2222-2222-2222-2222-222222222222', 'Oran Downtown', 'Oran', 'Oran Province', 'Algeria', 35.6969, -0.6331, '2024-01-01 00:00:00+00'),
('loc3333-3333-3333-3333-333333333333', 'Constantine City', 'Constantine', 'Constantine Province', 'Algeria', 36.3650, 6.6147, '2024-01-01 00:00:00+00'),
('loc4444-4444-4444-4444-444444444444', 'Setif Central', 'Setif', 'Setif Province', 'Algeria', 36.1911, 5.4137, '2024-01-01 00:00:00+00');

-- =====================================================
-- SAMPLE HOST REQUESTS
-- =====================================================

INSERT INTO public.host_requests (id, user_id, request_note, status, created_at) VALUES
('req1111-1111-1111-1111-111111111111', '33333333-3333-3333-3333-333333333333', 'I would like to become a host to share my car collection', 'pending', '2024-02-15 10:00:00+00'),
('req2222-2222-2222-2222-222222222222', '44444444-4444-4444-4444-444444444444', 'Interested in hosting my luxury vehicles', 'approved', '2024-02-10 14:30:00+00');

-- =====================================================
-- SAMPLE AVAILABILITY
-- =====================================================

INSERT INTO public.availability (id, car_id, available_date, is_available, price_override, created_at) VALUES
-- Toyota RAV4 availability
('avail1111-1111-1111-1111-111111111111', 'car1111-1111-1111-1111-111111111111', '2024-04-01', true, NULL, '2024-03-25 10:00:00+00'),
('avail2222-2222-2222-2222-222222222222', 'car1111-1111-1111-1111-111111111111', '2024-04-02', true, NULL, '2024-03-25 10:00:00+00'),
('avail3333-3333-3333-3333-333333333333', 'car1111-1111-1111-1111-111111111111', '2024-04-03', false, NULL, '2024-03-25 10:00:00+00'),

-- Mercedes S-Class availability
('avail4444-4444-4444-4444-444444444444', 'car3333-3333-3333-3333-333333333333', '2024-04-01', true, 380.00, '2024-03-25 10:00:00+00'),
('avail5555-5555-5555-5555-555555555555', 'car3333-3333-3333-3333-333333333333', '2024-04-02', true, 380.00, '2024-03-25 10:00:00+00'),

-- Tesla Model 3 availability
('avail6666-6666-6666-6666-666666666666', 'car5555-5555-5555-5555-555555555555', '2024-04-01', true, NULL, '2024-03-25 10:00:00+00'),
('avail7777-7777-7777-7777-777777777777', 'car5555-5555-5555-5555-555555555555', '2024-04-02', true, NULL, '2024-03-25 10:00:00+00');

-- =====================================================
-- END OF SAMPLE DATA
-- ===================================================== 