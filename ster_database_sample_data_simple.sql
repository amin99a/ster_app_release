-- STER Car Rental App - Simplified Sample Data
-- This file contains sample data for tables that don't require auth.users references

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
-- SAMPLE LOCATIONS
-- =====================================================

INSERT INTO public.locations (id, name, city, state, country, latitude, longitude, created_at) VALUES
('loc1111-1111-1111-1111-111111111111', 'Algiers Center', 'Algiers', 'Algiers Province', 'Algeria', 36.7538, 3.0588, '2024-01-01 00:00:00+00'),
('loc2222-2222-2222-2222-222222222222', 'Oran Downtown', 'Oran', 'Oran Province', 'Algeria', 35.6969, -0.6331, '2024-01-01 00:00:00+00'),
('loc3333-3333-3333-3333-333333333333', 'Constantine City', 'Constantine', 'Constantine Province', 'Algeria', 36.3650, 6.6147, '2024-01-01 00:00:00+00'),
('loc4444-4444-4444-4444-444444444444', 'Setif Central', 'Setif', 'Setif Province', 'Algeria', 36.1911, 5.4137, '2024-01-01 00:00:00+00');

-- =====================================================
-- SAMPLE CARS (without host_id references)
-- =====================================================

INSERT INTO public.cars (id, name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at) VALUES
-- SUV Category
('car1111-1111-1111-1111-111111111111', 'Toyota RAV4 2023', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400', 120.00, 'c1111111-1111-1111-1111-111111111111', 4.8, 45, 'Algiers', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 1 hour', 'Perfect SUV for family trips with excellent fuel economy and spacious interior.', '["GPS Navigation", "Bluetooth", "Backup Camera", "Cruise Control", "Heated Seats"]', '["https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400", "https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "2.5L 4-Cylinder", "Power": "203 HP", "Fuel Economy": "28 MPG", "Seating": "5 passengers"}', 'Automatic', 'Hybrid', 5, true, true, '2024-01-15 10:00:00+00'),

('car2222-2222-2222-2222-222222222222', 'Honda CR-V 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 110.00, 'c1111111-1111-1111-1111-111111111111', 4.6, 32, 'Oran', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 30 minutes', 'Reliable SUV with great safety features and comfortable ride.', '["Apple CarPlay", "Android Auto", "Lane Departure Warning", "Blind Spot Monitor", "Emergency Braking"]', '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "1.5L Turbo", "Power": "190 HP", "Fuel Economy": "30 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, false, '2024-01-20 14:30:00+00'),

-- Luxury Category
('car3333-3333-3333-3333-333333333333', 'Mercedes-Benz S-Class 2023', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400', 350.00, 'c2222222-2222-2222-2222-222222222222', 4.9, 18, 'Algiers', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 15 minutes', 'Ultimate luxury sedan with premium features and exceptional comfort.', '["Massage Seats", "Burmester Sound System", "Ambient Lighting", "Heads-up Display", "Night Vision"]', '["https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400"]', '{"Engine": "3.0L 6-Cylinder", "Power": "429 HP", "Fuel Economy": "22 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, true, '2024-02-01 09:15:00+00'),

('car4444-4444-4444-4444-444444444444', 'BMW 7 Series 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 320.00, 'c2222222-2222-2222-2222-222222222222', 4.7, 25, 'Constantine', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 45 minutes', 'Executive sedan with cutting-edge technology and refined performance.', '["Gesture Control", "Wireless Charging", "Panoramic Roof", "Premium Audio", "Driver Assistance"]', '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', '{"Engine": "2.0L 6-Cylinder", "Power": "335 HP", "Fuel Economy": "25 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, false, '2024-02-10 16:45:00+00'),

-- Electric Category
('car5555-5555-5555-5555-555555555555', 'Tesla Model 3 2023', 'https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400', 180.00, 'c3333333-3333-3333-3333-333333333333', 4.8, 38, 'Algiers', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 20 minutes', 'Zero-emission electric vehicle with instant acceleration and autopilot features.', '["Autopilot", "Supercharging", "Glass Roof", "Premium Audio", "Over-the-air Updates"]', '["https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400"]', '{"Battery": "75 kWh", "Range": "358 miles", "Power": "450 HP", "Seating": "5 passengers"}', 'Automatic', 'Electric', 5, true, true, '2024-01-25 13:10:00+00'),

-- Convertible Category
('car6666-6666-6666-6666-666666666666', 'BMW Z4 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 200.00, 'c4444444-4444-4444-4444-444444444444', 4.6, 22, 'Oran', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 1 hour', 'Open-top sports car perfect for coastal drives and weekend getaways.', '["Convertible Top", "Sport Seats", "Premium Audio", "Navigation", "Parking Sensors"]', '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', '{"Engine": "2.0L 4-Cylinder", "Power": "255 HP", "Fuel Economy": "28 MPG", "Seating": "2 passengers"}', 'Automatic', 'Gasoline', 2, true, false, '2024-02-05 11:20:00+00'),

-- Business Category
('car7777-7777-7777-7777-777777777777', 'Audi A6 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 150.00, 'c5555555-5555-5555-5555-555555555555', 4.5, 28, 'Constantine', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 30 minutes', 'Professional sedan ideal for business meetings and corporate travel.', '["Quattro AWD", "Virtual Cockpit", "MMI Navigation", "Bang & Olufsen Audio", "Driver Assistance"]', '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "2.0L 4-Cylinder", "Power": "248 HP", "Fuel Economy": "27 MPG", "Seating": "5 passengers"}', 'Automatic', 'Gasoline', 5, true, false, '2024-01-30 15:45:00+00'),

-- Sport Category
('car8888-8888-8888-8888-888888888888', 'Porsche 911 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 400.00, 'c6666666-6666-6666-6666-666666666666', 4.9, 15, 'Algiers', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 15 minutes', 'Iconic sports car with legendary performance and precision engineering.', '["Sport Chrono Package", "PASM Suspension", "Sport Exhaust", "Carbon Fiber Interior", "Track Mode"]', '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', '{"Engine": "3.0L 6-Cylinder", "Power": "379 HP", "Fuel Economy": "20 MPG", "Seating": "4 passengers"}', 'Manual', 'Gasoline', 4, true, true, '2024-02-15 12:00:00+00'),

-- Mini Category
('car9999-9999-9999-9999-999999999999', 'Mini Cooper 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 80.00, 'c7777777-7777-7777-7777-777777777777', 4.4, 35, 'Oran', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 45 minutes', 'Compact and stylish city car perfect for urban driving and parking.', '["Mini Connected", "LED Headlights", "Sport Suspension", "Premium Audio", "Parking Sensors"]', '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', '{"Engine": "1.5L 3-Cylinder", "Power": "134 HP", "Fuel Economy": "32 MPG", "Seating": "4 passengers"}', 'Automatic', 'Gasoline', 4, true, false, '2024-02-20 09:30:00+00');

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
-- NOTES FOR USER-DEPENDENT TABLES
-- =====================================================

/*
The following tables require valid user UUIDs from auth.users:

1. profiles - Requires auth.users entries
2. bookings - References user_id and host_id
3. reviews - References reviewer_id
4. favorites - References user_id
5. notifications - References user_id
6. payments - References user_id
7. messages - References sender_id and receiver_id
8. disputes - References user_id
9. host_requests - References user_id

To populate these tables:

1. First create users through your app's authentication system
2. Or manually create users in Supabase Auth dashboard
3. Then use the sample data from the original file, replacing UUIDs with actual user IDs

Example after creating users:
INSERT INTO public.bookings (id, car_id, user_id, host_id, start_date, end_date, total_price, status, notes, created_at) VALUES
('book1111-1111-1111-1111-111111111111', 'car1111-1111-1111-1111-111111111111', 'ACTUAL_USER_UUID', 'ACTUAL_HOST_UUID', '2024-01-20', '2024-01-22', 240.00, 'completed', 'Great experience, car was in perfect condition', '2024-01-18 10:00:00+00');
*/

-- =====================================================
-- END OF SIMPLIFIED SAMPLE DATA
-- ===================================================== 