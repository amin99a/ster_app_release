-- STER Car Rental App - Safe Sample Data
-- This file checks for existing data before inserting to avoid duplicate key errors

-- =====================================================
-- SAMPLE CATEGORIES (with existence check)
-- =====================================================

-- Insert categories only if they don't exist
INSERT INTO public.categories (name, description, icon, image, created_at)
SELECT 'SUV', 'Sport Utility Vehicles perfect for family trips and off-road adventures', '🚙', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400', '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'SUV');

INSERT INTO public.categories (name, description, icon, image, created_at)
SELECT 'Luxury', 'Premium vehicles for special occasions and business travel', '🏎️', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400', '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Luxury');

INSERT INTO public.categories (name, description, icon, image, created_at)
SELECT 'Electric', 'Environmentally friendly electric cars for eco-conscious travelers', '⚡', 'https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400', '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Electric');

INSERT INTO public.categories (name, description, icon, image, created_at)
SELECT 'Convertible', 'Open-top driving experience for sunny days', '🌞', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Convertible');

INSERT INTO public.categories (name, description, icon, image, created_at)
SELECT 'Business', 'Professional vehicles for business travel and meetings', '💼', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Business');

INSERT INTO public.categories (name, description, icon, image, created_at)
SELECT 'Sport', 'High-performance sports cars for thrill seekers', '🏁', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Sport');

INSERT INTO public.categories (name, description, icon, image, created_at)
SELECT 'Mini', 'Compact cars perfect for city driving and parking', '🚗', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.categories WHERE name = 'Mini');

-- =====================================================
-- SAMPLE LOCATIONS (with existence check)
-- =====================================================

INSERT INTO public.locations (name, city, state, country, latitude, longitude, created_at)
SELECT 'Algiers Center', 'Algiers', 'Algiers Province', 'Algeria', 36.7538, 3.0588, '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.locations WHERE name = 'Algiers Center');

INSERT INTO public.locations (name, city, state, country, latitude, longitude, created_at)
SELECT 'Oran Downtown', 'Oran', 'Oran Province', 'Algeria', 35.6969, -0.6331, '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.locations WHERE name = 'Oran Downtown');

INSERT INTO public.locations (name, city, state, country, latitude, longitude, created_at)
SELECT 'Constantine City', 'Constantine', 'Constantine Province', 'Algeria', 36.3650, 6.6147, '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.locations WHERE name = 'Constantine City');

INSERT INTO public.locations (name, city, state, country, latitude, longitude, created_at)
SELECT 'Setif Central', 'Setif', 'Setif Province', 'Algeria', 36.1911, 5.4137, '2024-01-01 00:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.locations WHERE name = 'Setif Central');

-- =====================================================
-- SAMPLE CARS (with existence check and dynamic category lookup)
-- =====================================================

-- Insert cars only if they don't exist, using category names instead of IDs
INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'Toyota RAV4 2023', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400', 120.00, 
  (SELECT id FROM public.categories WHERE name = 'SUV' LIMIT 1), 
  4.8, 45, 'Algiers', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 1 hour', 
  'Perfect SUV for family trips with excellent fuel economy and spacious interior.', 
  '["GPS Navigation", "Bluetooth", "Backup Camera", "Cruise Control", "Heated Seats"]', 
  '["https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400", "https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', 
  '{"Engine": "2.5L 4-Cylinder", "Power": "203 HP", "Fuel Economy": "28 MPG", "Seating": "5 passengers"}', 
  'Automatic', 'Hybrid', 5, true, true, '2024-01-15 10:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'Toyota RAV4 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'Honda CR-V 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 110.00, 
  (SELECT id FROM public.categories WHERE name = 'SUV' LIMIT 1), 
  4.6, 32, 'Oran', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 30 minutes', 
  'Reliable SUV with great safety features and comfortable ride.', 
  '["Apple CarPlay", "Android Auto", "Lane Departure Warning", "Blind Spot Monitor", "Emergency Braking"]', 
  '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', 
  '{"Engine": "1.5L Turbo", "Power": "190 HP", "Fuel Economy": "30 MPG", "Seating": "5 passengers"}', 
  'Automatic', 'Gasoline', 5, true, false, '2024-01-20 14:30:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'Honda CR-V 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'Mercedes-Benz S-Class 2023', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400', 350.00, 
  (SELECT id FROM public.categories WHERE name = 'Luxury' LIMIT 1), 
  4.9, 18, 'Algiers', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 15 minutes', 
  'Ultimate luxury sedan with premium features and exceptional comfort.', 
  '["Massage Seats", "Burmester Sound System", "Ambient Lighting", "Heads-up Display", "Night Vision"]', 
  '["https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400"]', 
  '{"Engine": "3.0L 6-Cylinder", "Power": "429 HP", "Fuel Economy": "22 MPG", "Seating": "5 passengers"}', 
  'Automatic', 'Gasoline', 5, true, true, '2024-02-01 09:15:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'Mercedes-Benz S-Class 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'BMW 7 Series 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 320.00, 
  (SELECT id FROM public.categories WHERE name = 'Luxury' LIMIT 1), 
  4.7, 25, 'Constantine', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 45 minutes', 
  'Executive sedan with cutting-edge technology and refined performance.', 
  '["Gesture Control", "Wireless Charging", "Panoramic Roof", "Premium Audio", "Driver Assistance"]', 
  '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', 
  '{"Engine": "2.0L 6-Cylinder", "Power": "335 HP", "Fuel Economy": "25 MPG", "Seating": "5 passengers"}', 
  'Automatic', 'Gasoline', 5, true, false, '2024-02-10 16:45:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'BMW 7 Series 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'Tesla Model 3 2023', 'https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400', 180.00, 
  (SELECT id FROM public.categories WHERE name = 'Electric' LIMIT 1), 
  4.8, 38, 'Algiers', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 20 minutes', 
  'Zero-emission electric vehicle with instant acceleration and autopilot features.', 
  '["Autopilot", "Supercharging", "Glass Roof", "Premium Audio", "Over-the-air Updates"]', 
  '["https://images.unsplash.com/photo-1593941707882-a5bac6861d10?w=400"]', 
  '{"Battery": "75 kWh", "Range": "358 miles", "Power": "450 HP", "Seating": "5 passengers"}', 
  'Automatic', 'Electric', 5, true, true, '2024-01-25 13:10:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'Tesla Model 3 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'BMW Z4 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 200.00, 
  (SELECT id FROM public.categories WHERE name = 'Convertible' LIMIT 1), 
  4.6, 22, 'Oran', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 1 hour', 
  'Open-top sports car perfect for coastal drives and weekend getaways.', 
  '["Convertible Top", "Sport Seats", "Premium Audio", "Navigation", "Parking Sensors"]', 
  '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', 
  '{"Engine": "2.0L 4-Cylinder", "Power": "255 HP", "Fuel Economy": "28 MPG", "Seating": "2 passengers"}', 
  'Automatic', 'Gasoline', 2, true, false, '2024-02-05 11:20:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'BMW Z4 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'Audi A6 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 150.00, 
  (SELECT id FROM public.categories WHERE name = 'Business' LIMIT 1), 
  4.5, 28, 'Constantine', 'Hassan Host', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150', 4.9, 'Usually responds in 30 minutes', 
  'Professional sedan ideal for business meetings and corporate travel.', 
  '["Quattro AWD", "Virtual Cockpit", "MMI Navigation", "Bang & Olufsen Audio", "Driver Assistance"]', 
  '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', 
  '{"Engine": "2.0L 4-Cylinder", "Power": "248 HP", "Fuel Economy": "27 MPG", "Seating": "5 passengers"}', 
  'Automatic', 'Gasoline', 5, true, false, '2024-01-30 15:45:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'Audi A6 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'Porsche 911 2023', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 400.00, 
  (SELECT id FROM public.categories WHERE name = 'Sport' LIMIT 1), 
  4.9, 15, 'Algiers', 'Amina Host', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150', 4.7, 'Usually responds in 15 minutes', 
  'Iconic sports car with legendary performance and precision engineering.', 
  '["Sport Chrono Package", "PASM Suspension", "Sport Exhaust", "Carbon Fiber Interior", "Track Mode"]', 
  '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]', 
  '{"Engine": "3.0L 6-Cylinder", "Power": "379 HP", "Fuel Economy": "20 MPG", "Seating": "4 passengers"}', 
  'Manual', 'Gasoline', 4, true, true, '2024-02-15 12:00:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'Porsche 911 2023');

INSERT INTO public.cars (name, image, price_per_day, category_id, rating, trips, location, host_name, host_image, host_rating, response_time, description, features, images, specs, transmission, fuel_type, passengers, available, featured, created_at)
SELECT 
  'Mini Cooper 2023', 'https://images.unsplash.com/photo-1549924231-f129b911e442?w=400', 80.00, 
  (SELECT id FROM public.categories WHERE name = 'Mini' LIMIT 1), 
  4.4, 35, 'Oran', 'Omar Host', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150', 4.8, 'Usually responds in 45 minutes', 
  'Compact and stylish city car perfect for urban driving and parking.', 
  '["Mini Connected", "LED Headlights", "Sport Suspension", "Premium Audio", "Parking Sensors"]', 
  '["https://images.unsplash.com/photo-1549924231-f129b911e442?w=400"]', 
  '{"Engine": "1.5L 3-Cylinder", "Power": "134 HP", "Fuel Economy": "32 MPG", "Seating": "4 passengers"}', 
  'Automatic', 'Gasoline', 4, true, false, '2024-02-20 09:30:00+00'
WHERE NOT EXISTS (SELECT 1 FROM public.cars WHERE name = 'Mini Cooper 2023');

-- =====================================================
-- SAMPLE AVAILABILITY (with existence check and dynamic car lookup)
-- =====================================================

INSERT INTO public.availability (car_id, available_date, is_available, price_override, created_at)
SELECT 
  (SELECT id FROM public.cars WHERE name = 'Toyota RAV4 2023' LIMIT 1), '2024-04-01', true, NULL, '2024-03-25 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.availability a 
  JOIN public.cars c ON a.car_id = c.id 
  WHERE c.name = 'Toyota RAV4 2023' AND a.available_date = '2024-04-01'
);

INSERT INTO public.availability (car_id, available_date, is_available, price_override, created_at)
SELECT 
  (SELECT id FROM public.cars WHERE name = 'Toyota RAV4 2023' LIMIT 1), '2024-04-02', true, NULL, '2024-03-25 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.availability a 
  JOIN public.cars c ON a.car_id = c.id 
  WHERE c.name = 'Toyota RAV4 2023' AND a.available_date = '2024-04-02'
);

INSERT INTO public.availability (car_id, available_date, is_available, price_override, created_at)
SELECT 
  (SELECT id FROM public.cars WHERE name = 'Toyota RAV4 2023' LIMIT 1), '2024-04-03', false, NULL, '2024-03-25 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.availability a 
  JOIN public.cars c ON a.car_id = c.id 
  WHERE c.name = 'Toyota RAV4 2023' AND a.available_date = '2024-04-03'
);

INSERT INTO public.availability (car_id, available_date, is_available, price_override, created_at)
SELECT 
  (SELECT id FROM public.cars WHERE name = 'Mercedes-Benz S-Class 2023' LIMIT 1), '2024-04-01', true, 380.00, '2024-03-25 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.availability a 
  JOIN public.cars c ON a.car_id = c.id 
  WHERE c.name = 'Mercedes-Benz S-Class 2023' AND a.available_date = '2024-04-01'
);

INSERT INTO public.availability (car_id, available_date, is_available, price_override, created_at)
SELECT 
  (SELECT id FROM public.cars WHERE name = 'Mercedes-Benz S-Class 2023' LIMIT 1), '2024-04-02', true, 380.00, '2024-03-25 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.availability a 
  JOIN public.cars c ON a.car_id = c.id 
  WHERE c.name = 'Mercedes-Benz S-Class 2023' AND a.available_date = '2024-04-02'
);

INSERT INTO public.availability (car_id, available_date, is_available, price_override, created_at)
SELECT 
  (SELECT id FROM public.cars WHERE name = 'Tesla Model 3 2023' LIMIT 1), '2024-04-01', true, NULL, '2024-03-25 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.availability a 
  JOIN public.cars c ON a.car_id = c.id 
  WHERE c.name = 'Tesla Model 3 2023' AND a.available_date = '2024-04-01'
);

INSERT INTO public.availability (car_id, available_date, is_available, price_override, created_at)
SELECT 
  (SELECT id FROM public.cars WHERE name = 'Tesla Model 3 2023' LIMIT 1), '2024-04-02', true, NULL, '2024-03-25 10:00:00+00'
WHERE NOT EXISTS (
  SELECT 1 FROM public.availability a 
  JOIN public.cars c ON a.car_id = c.id 
  WHERE c.name = 'Tesla Model 3 2023' AND a.available_date = '2024-04-02'
);

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

-- This will show a success message if the script runs without errors
DO $$
BEGIN
  RAISE NOTICE 'Sample data inserted successfully! No duplicate key errors occurred.';
END $$;

-- =====================================================
-- END OF SAFE SAMPLE DATA
-- ===================================================== 