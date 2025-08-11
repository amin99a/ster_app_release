-- Comprehensive realistic data seeding for STER Car Rental App
-- This script creates interconnected demo data for development and testing
-- FIXED: Creates auth.users first, then user_profiles

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

BEGIN;

-- =====================================================
-- 1. CREATE AUTH USERS FIRST (Required for foreign keys)
-- =====================================================

-- Note: In production, users are created via Supabase Auth API
-- For demo purposes, we insert directly into auth.users table
-- This is only for development/testing environments

INSERT INTO auth.users (
  id, email, encrypted_password, email_confirmed_at, 
  raw_user_meta_data, created_at, updated_at, confirmation_token, email_change_token_new
) VALUES 
  -- Demo users with confirmed emails
  (
    '11111111-1111-1111-1111-111111111111',
    'sarah.johnson@email.com',
    '$2a$10$demopasswordhash', -- This is just a demo hash
    '2024-01-15 10:30:00+00',
    '{"name": "Sarah Johnson"}',
    '2024-01-15 10:30:00+00',
    '2024-12-15 14:20:00+00',
    '',
    ''
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'ahmed.benali@email.com',
    '$2a$10$demopasswordhash',
    '2024-02-20 09:15:00+00',
    '{"name": "Ahmed Benali"}',
    '2024-02-20 09:15:00+00',
    '2024-12-10 16:45:00+00',
    '',
    ''
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'mohamed.kaci@email.com',
    '$2a$10$demopasswordhash',
    '2023-03-10 12:00:00+00',
    '{"name": "Mohamed Kaci"}',
    '2023-03-10 12:00:00+00',
    '2024-12-14 11:30:00+00',
    '',
    ''
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'fatima.boudiaf@email.com',
    '$2a$10$demopasswordhash',
    '2023-07-15 14:30:00+00',
    '{"name": "Fatima Boudiaf"}',
    '2023-07-15 14:30:00+00',
    '2024-12-14 09:45:00+00',
    '',
    ''
  ),
  (
    '55555555-5555-5555-5555-555555555555',
    'admin@ster.com',
    '$2a$10$demopasswordhash',
    '2023-01-01 08:00:00+00',
    '{"name": "Admin Hadj"}',
    '2023-01-01 08:00:00+00',
    '2024-12-15 15:00:00+00',
    '',
    ''
  ),
  (
    '66666666-6666-6666-6666-666666666666',
    'yacine.meziani@email.com',
    '$2a$10$demopasswordhash',
    '2024-11-01 16:20:00+00',
    '{"name": "Yacine Meziani"}',
    '2024-11-01 16:20:00+00',
    '2024-12-01 10:15:00+00',
    '',
    ''
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 2. CATEGORIES (Foundation data)
-- =====================================================

INSERT INTO public.categories (id, name, description, icon, image) VALUES
  (uuid_generate_v4(), 'Economy', 'Affordable and fuel-efficient cars for budget-conscious travelers', '🚗', 'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=400'),
  (uuid_generate_v4(), 'Compact', 'Small, easy-to-park vehicles perfect for city driving', '🚙', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400'),
  (uuid_generate_v4(), 'SUV', 'Spacious and versatile vehicles for families and adventures', '🚐', 'https://images.unsplash.com/photo-1566473965997-3de9c817e938?w=400'),
  (uuid_generate_v4(), 'Luxury', 'Premium vehicles with top-tier comfort and features', '✨', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400'),
  (uuid_generate_v4(), 'Sports', 'High-performance vehicles for thrill seekers', '🏎️', 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=400'),
  (uuid_generate_v4(), 'Electric', 'Eco-friendly electric and hybrid vehicles', '🔋', 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=400')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 3. USER PROFILES (Now that auth.users exist)
-- =====================================================

INSERT INTO public.user_profiles (
  id, name, email, phone, profile_image, role, is_email_verified, is_phone_verified, 
  location, host_profile, created_at, updated_at
) VALUES 
  -- CUSTOMERS (2)
  (
    '11111111-1111-1111-1111-111111111111',
    'Sarah Johnson',
    'sarah.johnson@email.com',
    '+213555123456',
    'https://images.unsplash.com/photo-1494790108755-2616b612b47c?w=200',
    'user',
    true,
    true,
    '{"city": "Algiers", "country": "Algeria", "latitude": 36.7372, "longitude": 3.0863}',
    null,
    '2024-01-15 10:30:00+00',
    '2024-12-15 14:20:00+00'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Ahmed Benali',
    'ahmed.benali@email.com',
    '+213555234567',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
    'user',
    true,
    false,
    '{"city": "Oran", "country": "Algeria", "latitude": 35.6911, "longitude": -0.6417}',
    null,
    '2024-02-20 09:15:00+00',
    '2024-12-10 16:45:00+00'
  ),
  
  -- HOSTS (2)
  (
    '33333333-3333-3333-3333-333333333333',
    'Mohamed Kaci',
    'mohamed.kaci@email.com',
    '+213555345678',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
    'host',
    true,
    true,
    '{"city": "Constantine", "country": "Algeria", "latitude": 36.3650, "longitude": 6.6147}',
    '{"response_time": "Within an hour", "rating": 4.8, "total_trips": 127, "joined_date": "2023-03-10", "bio": "Professional car rental service with over 3 years of experience. Always keeping my vehicles in top condition.", "languages": ["Arabic", "French", "English"]}',
    '2023-03-10 12:00:00+00',
    '2024-12-14 11:30:00+00'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'Fatima Boudiaf',
    'fatima.boudiaf@email.com',
    '+213555456789',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
    'host',
    true,
    true,
    '{"city": "Annaba", "country": "Algeria", "latitude": 36.9000, "longitude": 7.7667}',
    '{"response_time": "Within 30 minutes", "rating": 4.9, "total_trips": 89, "joined_date": "2023-07-15", "bio": "Passionate about providing excellent service and well-maintained vehicles for your adventures.", "languages": ["Arabic", "French"]}',
    '2023-07-15 14:30:00+00',
    '2024-12-14 09:45:00+00'
  ),
  
  -- ADMIN (1)
  (
    '55555555-5555-5555-5555-555555555555',
    'Admin Hadj',
    'admin@ster.com',
    '+213555567890',
    'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=200',
    'admin',
    true,
    true,
    '{"city": "Algiers", "country": "Algeria", "latitude": 36.7372, "longitude": 3.0863}',
    null,
    '2023-01-01 08:00:00+00',
    '2024-12-15 15:00:00+00'
  ),
  
  -- PENDING HOST (1)
  (
    '66666666-6666-6666-6666-666666666666',
    'Yacine Meziani',
    'yacine.meziani@email.com',
    '+213555678901',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
    'user',
    true,
    true,
    '{"city": "Tlemcen", "country": "Algeria", "latitude": 34.8833, "longitude": -1.3167}',
    null,
    '2024-11-01 16:20:00+00',
    '2024-12-01 10:15:00+00'
  )
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 4. CARS (Realistic vehicle data)
-- =====================================================

-- Get category IDs for reference
DO $$
DECLARE
  economy_id uuid;
  compact_id uuid;
  suv_id uuid;
  luxury_id uuid;
  sports_id uuid;
  electric_id uuid;
BEGIN
  SELECT id INTO economy_id FROM public.categories WHERE name = 'Economy' LIMIT 1;
  SELECT id INTO compact_id FROM public.categories WHERE name = 'Compact' LIMIT 1;
  SELECT id INTO suv_id FROM public.categories WHERE name = 'SUV' LIMIT 1;
  SELECT id INTO luxury_id FROM public.categories WHERE name = 'Luxury' LIMIT 1;
  SELECT id INTO sports_id FROM public.categories WHERE name = 'Sports' LIMIT 1;
  SELECT id INTO electric_id FROM public.categories WHERE name = 'Electric' LIMIT 1;

  -- Mohamed Kaci's Cars (Host 1)
  INSERT INTO public.cars (
    id, host_id, name, brand, model, year, image, images, price, daily_rate, weekly_rate, monthly_rate,
    category, category_id, rating, trips, review_count, location, latitude, longitude,
    host_name, host_image, host_rating, response_time, host_response_time, description, features,
    specs, transmission, fuel_type, passengers, seats, doors, mileage, color, license_plate,
    price_per_day, available, featured, created_at, updated_at
  ) VALUES 
    -- Car 1: Renault Clio
    (
      '77777777-7777-7777-7777-777777777777',
      '33333333-3333-3333-3333-333333333333',
      'Renault Clio 2022 - Economy',
      'Renault',
      'Clio',
      2022,
      'https://images.unsplash.com/photo-1600712242805-5f78671b24da?w=800',
      ARRAY[
        'https://images.unsplash.com/photo-1600712242805-5f78671b24da?w=800',
        'https://images.unsplash.com/photo-1603584173870-7f23fdae1b7a?w=800',
        'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800'
      ],
      '4500 DZD/day',
      4500,
      28000,
      110000,
      'Economy',
      economy_id,
      4.6,
      87,
      23,
      'Constantine, Algeria',
      36.3650,
      6.6147,
      'Mohamed Kaci',
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
      4.8,
      'Within an hour',
      'Within an hour',
      'Perfect for city driving and daily commutes. This Renault Clio 2022 offers excellent fuel economy and comfortable seating for up to 5 passengers. Ideal for exploring Constantine and surrounding areas.',
      ARRAY['Air Conditioning', 'Bluetooth', 'USB Charging', 'GPS Navigation', 'Backup Camera'],
      '{"engine": "1.0L TCe", "power": "100 HP", "consumption": "5.2L/100km", "top_speed": "180 km/h"}',
      'Manual',
      'Petrol',
      5,
      5,
      5,
      45000,
      'White',
      '25-123-456',
      4500,
      true,
      false,
      '2024-03-15 10:00:00+00',
      '2024-12-14 14:30:00+00'
    ),
    
    -- Car 2: Hyundai Tucson
    (
      '88888888-8888-8888-8888-888888888888',
      '33333333-3333-3333-3333-333333333333',
      'Hyundai Tucson 2023 - SUV',
      'Hyundai',
      'Tucson',
      2023,
      'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800',
      ARRAY[
        'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800',
        'https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800',
        'https://images.unsplash.com/photo-1549399605-e5c39db0d9a7?w=800'
      ],
      '8500 DZD/day',
      8500,
      55000,
      210000,
      'SUV',
      suv_id,
      4.8,
      65,
      18,
      'Constantine, Algeria',
      36.3650,
      6.6147,
      'Mohamed Kaci',
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
      4.8,
      'Within an hour',
      'Within an hour',
      'Spacious and versatile SUV perfect for families and adventure trips. Features all-wheel drive, premium interior, and advanced safety features. Great for mountain trips and family vacations.',
      ARRAY['AWD', 'Leather Seats', 'Sunroof', 'Apple CarPlay', 'Lane Assist', 'Heated Seats'],
      '{"engine": "2.0L GDI", "power": "161 HP", "consumption": "7.8L/100km", "top_speed": "190 km/h"}',
      'Automatic',
      'Petrol',
      5,
      5,
      5,
      32000,
      'Dark Blue',
      '25-234-567',
      8500,
      true,
      true,
      '2024-04-20 11:30:00+00',
      '2024-12-14 16:45:00+00'
    ),
    
    -- Car 3: Mercedes C-Class
    (
      '99999999-9999-9999-9999-999999999999',
      '33333333-3333-3333-3333-333333333333',
      'Mercedes C-Class 2023 - Luxury',
      'Mercedes-Benz',
      'C-Class',
      2023,
      'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
      ARRAY[
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=800',
        'https://images.unsplash.com/photo-1621135802920-133df287f89c?w=800'
      ],
      '15000 DZD/day',
      15000,
      95000,
      360000,
      'Luxury',
      luxury_id,
      4.9,
      45,
      12,
      'Constantine, Algeria',
      36.3650,
      6.6147,
      'Mohamed Kaci',
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
      4.8,
      'Within an hour',
      'Within an hour',
      'Experience luxury with this Mercedes C-Class 2023. Premium materials, advanced technology, and exceptional comfort make every journey special. Perfect for business trips and special occasions.',
      ARRAY['Premium Sound', 'Ambient Lighting', 'Wireless Charging', 'Massage Seats', 'Parking Assist', '360° Camera'],
      '{"engine": "2.0L Turbo", "power": "255 HP", "consumption": "6.9L/100km", "top_speed": "250 km/h"}',
      'Automatic',
      'Petrol',
      5,
      5,
      4,
      28000,
      'Silver',
      '25-345-678',
      15000,
      true,
      true,
      '2024-05-10 09:15:00+00',
      '2024-12-14 12:20:00+00'
    );

  -- Fatima Boudiaf's Cars (Host 2)
  INSERT INTO public.cars (
    id, host_id, name, brand, model, year, image, images, price, daily_rate, weekly_rate, monthly_rate,
    category, category_id, rating, trips, review_count, location, latitude, longitude,
    host_name, host_image, host_rating, response_time, host_response_time, description, features,
    specs, transmission, fuel_type, passengers, seats, doors, mileage, color, license_plate,
    price_per_day, available, featured, created_at, updated_at
  ) VALUES 
    -- Car 4: Volkswagen Golf
    (
      'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      '44444444-4444-4444-4444-444444444444',
      'Volkswagen Golf 2022 - Compact',
      'Volkswagen',
      'Golf',
      2022,
      'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
      ARRAY[
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
        'https://images.unsplash.com/photo-1567515004624-219c11d31f2e?w=800',
        'https://images.unsplash.com/photo-1606016159991-2c98e1e0ed71?w=800'
      ],
      '5500 DZD/day',
      5500,
      35000,
      135000,
      'Compact',
      compact_id,
      4.5,
      72,
      19,
      'Annaba, Algeria',
      36.9000,
      7.7667,
      'Fatima Boudiaf',
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
      4.9,
      'Within 30 minutes',
      'Within 30 minutes',
      'Reliable and efficient Volkswagen Golf 2022. Perfect balance of comfort, technology, and fuel efficiency. Great for coastal drives around Annaba and day trips.',
      ARRAY['Digital Cockpit', 'Auto AC', 'Cruise Control', 'Keyless Entry', 'Rear Camera'],
      '{"engine": "1.4L TSI", "power": "150 HP", "consumption": "5.7L/100km", "top_speed": "205 km/h"}',
      'Automatic',
      'Petrol',
      5,
      5,
      5,
      38000,
      'Red',
      '23-456-789',
      5500,
      true,
      false,
      '2024-06-05 13:45:00+00',
      '2024-12-14 08:30:00+00'
    ),
    
    -- Car 5: Tesla Model 3
    (
      'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      '44444444-4444-4444-4444-444444444444',
      'Tesla Model 3 2023 - Electric',
      'Tesla',
      'Model 3',
      2023,
      'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800',
      ARRAY[
        'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800',
        'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800',
        'https://images.unsplash.com/photo-1593941707874-ef25b8b4a92b?w=800'
      ],
      '12000 DZD/day',
      12000,
      75000,
      285000,
      'Electric',
      electric_id,
      4.7,
      34,
      9,
      'Annaba, Algeria',
      36.9000,
      7.7667,
      'Fatima Boudiaf',
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200',
      4.9,
      'Within 30 minutes',
      'Within 30 minutes',
      'Experience the future of driving with this Tesla Model 3 2023. Zero emissions, cutting-edge technology, and incredible performance. Autopilot features and supercharging network access included.',
      ARRAY['Autopilot', 'Supercharging', 'Premium Audio', 'Glass Roof', 'Mobile Connector', 'Over-the-Air Updates'],
      '{"motor": "Dual Motor AWD", "power": "434 HP", "range": "507 km", "acceleration": "4.4s 0-100km/h"}',
      'Single Speed',
      'Electric',
      5,
      5,
      4,
      15000,
      'Pearl White',
      '23-567-890',
      12000,
      true,
      true,
      '2024-07-12 15:20:00+00',
      '2024-12-14 17:10:00+00'
    );
END $$;

-- =====================================================
-- 5. BOOKINGS (Realistic booking history)
-- =====================================================

INSERT INTO public.bookings (
  id, car_id, user_id, host_id, start_date, end_date, total_price, status, notes, created_at, updated_at
) VALUES
  -- Sarah Johnson's bookings
  (
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '77777777-7777-7777-7777-777777777777', -- Renault Clio
    '11111111-1111-1111-1111-111111111111', -- Sarah Johnson
    '33333333-3333-3333-3333-333333333333', -- Mohamed Kaci
    '2024-11-15 09:00:00+00',
    '2024-11-18 18:00:00+00',
    13500, -- 3 days * 4500
    'completed',
    'Great car for exploring Constantine! Very clean and well-maintained.',
    '2024-11-10 14:30:00+00',
    '2024-11-18 19:15:00+00'
  ),
  (
    'dddddddd-dddd-dddd-dddd-dddddddddddd',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- VW Golf
    '11111111-1111-1111-1111-111111111111', -- Sarah Johnson
    '44444444-4444-4444-4444-444444444444', -- Fatima Boudiaf
    '2024-12-20 10:00:00+00',
    '2024-12-23 16:00:00+00',
    16500, -- 3 days * 5500
    'confirmed',
    'Looking forward to the coastal drive in Annaba!',
    '2024-12-12 11:20:00+00',
    '2024-12-12 11:20:00+00'
  ),
  
  -- Ahmed Benali's bookings
  (
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    '88888888-8888-8888-8888-888888888888', -- Hyundai Tucson
    '22222222-2222-2222-2222-222222222222', -- Ahmed Benali
    '33333333-3333-3333-3333-333333333333', -- Mohamed Kaci
    '2024-10-05 08:00:00+00',
    '2024-10-12 20:00:00+00',
    59500, -- 7 days * 8500
    'completed',
    'Perfect SUV for our family mountain trip. Very spacious and comfortable.',
    '2024-09-28 16:45:00+00',
    '2024-10-12 21:30:00+00'
  ),
  (
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', -- Tesla Model 3
    '22222222-2222-2222-2222-222222222222', -- Ahmed Benali
    '44444444-4444-4444-4444-444444444444', -- Fatima Boudiaf
    '2024-09-01 12:00:00+00',
    '2024-09-03 12:00:00+00',
    24000, -- 2 days * 12000
    'completed',
    'Amazing experience with electric car! Very smooth and quiet.',
    '2024-08-25 09:15:00+00',
    '2024-09-03 13:45:00+00'
  ),
  (
    'e0000000-0000-0000-0000-000000000005',
    '99999999-9999-9999-9999-999999999999', -- Mercedes C-Class
    '22222222-2222-2222-2222-222222222222', -- Ahmed Benali
    '33333333-3333-3333-3333-333333333333', -- Mohamed Kaci
    '2024-12-25 14:00:00+00',
    '2024-12-30 10:00:00+00',
    75000, -- 5 days * 15000
    'pending',
    'Special occasion rental for New Year celebration.',
    '2024-12-14 18:30:00+00',
    '2024-12-14 18:30:00+00'
  );

-- =====================================================
-- 6. REVIEWS (Realistic customer feedback)
-- =====================================================

INSERT INTO public.reviews (
  id, booking_id, reviewer_id, reviewed_id, car_id, rating, comment, is_car_review, is_host_review, 
  created_at, updated_at
) VALUES
  -- Sarah's review for Renault Clio & Mohamed
  (
    'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh',
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '11111111-1111-1111-1111-111111111111', -- Sarah Johnson
    '33333333-3333-3333-3333-333333333333', -- Mohamed Kaci
    '77777777-7777-7777-7777-777777777777', -- Renault Clio
    5,
    'Excellent experience! Mohamed was very responsive and helpful. The Renault Clio was perfect for exploring Constantine - clean, fuel-efficient, and comfortable. The pickup was smooth and the car was exactly as described. Highly recommended!',
    true,
    true,
    '2024-11-19 10:30:00+00',
    '2024-11-19 10:30:00+00'
  ),
  
  -- Ahmed's review for Hyundai Tucson & Mohamed
  (
    'iiiiiiii-iiii-iiii-iiii-iiiiiiiiiiii',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    '22222222-2222-2222-2222-222222222222', -- Ahmed Benali
    '33333333-3333-3333-3333-333333333333', -- Mohamed Kaci
    '88888888-8888-8888-8888-888888888888', -- Hyundai Tucson
    5,
    'Outstanding SUV for our week-long family trip! The Tucson handled mountain roads beautifully and had plenty of space for our luggage. Mohamed was professional and accommodating. The car was spotless and well-maintained.',
    true,
    true,
    '2024-10-13 14:20:00+00',
    '2024-10-13 14:20:00+00'
  ),
  
  -- Ahmed's review for Tesla Model 3 & Fatima
  (
    'jjjjjjjj-jjjj-jjjj-jjjj-jjjjjjjjjjjj',
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    '22222222-2222-2222-2222-222222222222', -- Ahmed Benali
    '44444444-4444-4444-4444-444444444444', -- Fatima Boudiaf
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', -- Tesla Model 3
    4,
    'Great experience with the Tesla! Very smooth and quiet ride. Fatima was quick to respond and very helpful with explaining the charging process. Only minor issue was finding charging stations, but overall fantastic car.',
    true,
    true,
    '2024-09-04 16:45:00+00',
    '2024-09-04 16:45:00+00'
  );

-- =====================================================
-- 7. HOST REQUESTS (Become Host Applications)
-- =====================================================

INSERT INTO public.host_requests (
  id, user_id, request_note, status, reviewed_by, reviewed_at, created_at
) VALUES
  -- Pending request from Yacine
  (
    'kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk',
    '66666666-6666-6666-6666-666666666666', -- Yacine Meziani
    'Hello! I would like to become a host on STER. I own a well-maintained Peugeot 3008 2021 and have experience renting it privately. I have a clean driving record and am passionate about providing excellent customer service. I understand the responsibilities of being a host and am committed to maintaining high standards.',
    'pending',
    null,
    null,
    '2024-11-25 14:30:00+00'
  ),
  
  -- Approved request (historical - shows how Mohamed became a host)
  (
    'llllllll-llll-llll-llll-llllllllllll',
    '33333333-3333-3333-3333-333333333333', -- Mohamed Kaci (now host)
    'I am interested in becoming a host. I have two vehicles: a Renault Clio 2022 and a Hyundai Tucson 2023. Both are well-maintained and have all necessary insurance. I have experience in customer service and am available to respond quickly to requests.',
    'approved',
    '55555555-5555-5555-5555-555555555555', -- Admin Hadj
    '2023-03-15 09:30:00+00',
    '2023-03-10 16:45:00+00'
  );

-- =====================================================
-- 8. ADMIN ACTIONS/LOGS (Administrative activities)
-- =====================================================

INSERT INTO public.admin_logs (
  id, admin_id, action, target_table, target_id, details, created_at
) VALUES
  -- Approved Mohamed's host request
  (
    'a0000000-0000-0000-0000-000000000001',
    '55555555-5555-5555-5555-555555555555', -- Admin Hadj
    'HOST_REQUEST_APPROVED',
    'host_requests',
    'llllllll-llll-llll-llll-llllllllllll',
    '{"reason": "Application meets all requirements", "user_name": "Mohamed Kaci", "action_taken": "Approved host request and updated user role"}',
    '2023-03-15 09:30:00+00'
  ),
  
  -- Removed inappropriate review
  (
    'a0000000-0000-0000-0000-000000000002',
    '55555555-5555-5555-5555-555555555555', -- Admin Hadj
    'REVIEW_MODERATED',
    'reviews',
    'a0000000-0000-0000-0000-000000000003', -- Fictitious review ID
    '{"reason": "Inappropriate language", "original_rating": 1, "action_taken": "Review removed for violating community guidelines"}',
    '2024-11-30 15:45:00+00'
  ),
  
  -- Verified new car listing
  (
    'a0000000-0000-0000-0000-000000000004',
    '55555555-5555-5555-5555-555555555555', -- Admin Hadj
    'CAR_VERIFIED',
    'cars',
    '99999999-9999-9999-9999-999999999999', -- Mercedes C-Class
    '{"verification_status": "approved", "car_name": "Mercedes C-Class 2023", "host_name": "Mohamed Kaci", "action_taken": "Car listing verified and approved"}',
    '2024-05-10 10:30:00+00'
  );

-- =====================================================
-- 9. ADDITIONAL REALISTIC DATA
-- =====================================================

-- Car availability entries (some blocked dates)
INSERT INTO public.car_availability (
  id, car_id, start_date, end_date, is_blocked, reason, created_at
) VALUES
  (
    'b0000000-0000-0000-0000-000000000001',
    '77777777-7777-7777-7777-777777777777', -- Renault Clio
    '2025-01-05',
    '2025-01-07',
    true,
    'Scheduled maintenance',
    '2024-12-14 09:00:00+00'
  ),
  (
    'b0000000-0000-0000-0000-000000000002',
    '88888888-8888-8888-8888-888888888888', -- Hyundai Tucson
    '2024-12-31',
    '2025-01-02',
    true,
    'Personal use during holidays',
    '2024-12-10 14:20:00+00'
  );

-- Favorites (users saving cars)
INSERT INTO public.favorites (id, user_id, car_id, created_at) VALUES
  (
    'c0000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111', -- Sarah Johnson
    '99999999-9999-9999-9999-999999999999', -- Mercedes C-Class
    '2024-12-01 10:15:00+00'
  ),
  (
    'c0000000-0000-0000-0000-000000000002',
    '22222222-2222-2222-2222-222222222222', -- Ahmed Benali
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', -- Tesla Model 3
    '2024-11-20 16:30:00+00'
  );

-- Notifications for users
INSERT INTO public.notifications (
  id, user_id, title, message, type, read, data, created_at
) VALUES
  (
    'd0000000-0000-0000-0000-000000000001',
    '11111111-1111-1111-1111-111111111111', -- Sarah Johnson
    'Booking Confirmed',
    'Your booking for Volkswagen Golf has been confirmed for Dec 20-23, 2024.',
    'success',
    false,
    '{"booking_id": "dddddddd-dddd-dddd-dddd-dddddddddddd", "car_name": "Volkswagen Golf 2022"}',
    '2024-12-12 11:21:00+00'
  ),
  (
    'd0000000-0000-0000-0000-000000000002',
    '66666666-6666-6666-6666-666666666666', -- Yacine Meziani
    'Host Request Received',
    'Thank you for your host application. We will review it within 3-5 business days.',
    'info',
    true,
    '{"request_id": "kkkkkkkk-kkkk-kkkk-kkkk-kkkkkkkkkkkk"}',
    '2024-11-25 14:31:00+00'
  );

COMMIT;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Summary report
DO $$
DECLARE
  user_count INTEGER;
  car_count INTEGER;
  booking_count INTEGER;
  review_count INTEGER;
  host_request_count INTEGER;
  admin_log_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO user_count FROM public.user_profiles;
  SELECT COUNT(*) INTO car_count FROM public.cars;
  SELECT COUNT(*) INTO booking_count FROM public.bookings;
  SELECT COUNT(*) INTO review_count FROM public.reviews;
  SELECT COUNT(*) INTO host_request_count FROM public.host_requests;
  SELECT COUNT(*) INTO admin_log_count FROM public.admin_logs;
  
  RAISE NOTICE '=== STER DATABASE SEEDING COMPLETE ===';
  RAISE NOTICE 'Users created: %', user_count;
  RAISE NOTICE 'Cars listed: %', car_count;
  RAISE NOTICE 'Bookings created: %', booking_count;
  RAISE NOTICE 'Reviews added: %', review_count;
  RAISE NOTICE 'Host requests: %', host_request_count;
  RAISE NOTICE 'Admin actions logged: %', admin_log_count;
  RAISE NOTICE '';
  RAISE NOTICE '🧪 Demo users created:';
  RAISE NOTICE '📧 Customers: sarah.johnson@email.com, ahmed.benali@email.com';
  RAISE NOTICE '🏠 Hosts: mohamed.kaci@email.com, fatima.boudiaf@email.com';
  RAISE NOTICE '⚡ Admin: admin@ster.com';
  RAISE NOTICE '⏳ Pending Host: yacine.meziani@email.com';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Ready for UI testing with realistic interconnected data!';
  RAISE NOTICE '🔑 All demo users have password: demo123 (configure in auth settings)';
END $$;