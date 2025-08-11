-- STER Car Rental App - Add Test Cars (Actual Schema Compliant)
-- This script adds sample cars to the database for testing

-- =====================================================
-- INSERT SAMPLE CARS
-- =====================================================

-- First, let's make sure we have some categories
INSERT INTO public.categories (name, description, icon) VALUES
('Sedan', 'Comfortable family cars', 'sedan'),
('SUV', 'Spacious sport utility vehicles', 'suv'),
('Luxury', 'Premium and luxury vehicles', 'luxury'),
('Electric', 'Environmentally friendly electric cars', 'electric'),
('Sports', 'High-performance sports cars', 'sports')
ON CONFLICT (name) DO NOTHING;

-- Get category IDs for reference
DO $$
DECLARE
    sedan_id UUID;
    suv_id UUID;
    luxury_id UUID;
    electric_id UUID;
    sports_id UUID;
    test_host_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO sedan_id FROM public.categories WHERE name = 'Sedan';
    SELECT id INTO suv_id FROM public.categories WHERE name = 'SUV';
    SELECT id INTO luxury_id FROM public.categories WHERE name = 'Luxury';
    SELECT id INTO electric_id FROM public.categories WHERE name = 'Electric';
    SELECT id INTO sports_id FROM public.categories WHERE name = 'Sports';
    
    -- Get or create a test host (first user in profiles)
    SELECT id INTO test_host_id FROM public.profiles LIMIT 1;
    
    -- If no host exists, create a test host
    IF test_host_id IS NULL THEN
        INSERT INTO public.profiles (id, name, email, role, is_email_verified, created_at)
        VALUES (
            gen_random_uuid(),
            'Test Host',
            'testhost@example.com',
            'host',
            true,
            NOW()
        ) RETURNING id INTO test_host_id;
    END IF;

    -- Insert sample cars (matching actual schema)
    INSERT INTO public.cars (
        id, host_id, name, brand, model, year, image, images, price, daily_rate, weekly_rate, monthly_rate,
        category, rating, trips, review_count, location, latitude, longitude, host_name, host_image, host_rating,
        response_time, host_response_time, description, features, specs, is_available, is_featured, is_favorite,
        transmission, fuel_type, passengers, seats, doors, mileage, color, license_plate, insurance,
        created_at, updated_at, price_per_day, category_id, available, featured
    ) VALUES
    -- Sedan Cars
    (
        gen_random_uuid(),
        test_host_id,
        'Toyota Camry 2023',
        'Toyota',
        'Camry',
        2023,
        'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400',
        ARRAY['https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400'],
        '2500.00',
        2500.00,
        15000.00,
        50000.00,
        'Sedan',
        4.5,
        12,
        8,
        'Algiers, Algeria',
        36.7538,
        3.0588,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 1 hour',
        'Usually responds in 1 hour',
        'Comfortable sedan perfect for city driving and family trips. Well maintained with full service history.',
        ARRAY['Air Conditioning', 'Bluetooth', 'Backup Camera', 'Cruise Control', 'USB Charging'],
        '{"year": 2023, "mileage": 15000, "color": "Silver", "engine": "2.5L 4-Cylinder"}'::jsonb,
        true,
        true,
        false,
        'Automatic',
        'Gasoline',
        5,
        5,
        4,
        15000,
        'Silver',
        'ABC-123',
        'Comprehensive',
        NOW(),
        NOW(),
        2500.00,
        sedan_id,
        true,
        true
    ),
    (
        gen_random_uuid(),
        test_host_id,
        'Honda Civic 2022',
        'Honda',
        'Civic',
        2022,
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400',
        ARRAY['https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400', 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400'],
        '2000.00',
        2000.00,
        12000.00,
        40000.00,
        'Sedan',
        4.3,
        8,
        5,
        'Oran, Algeria',
        35.6971,
        -0.6333,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 30 minutes',
        'Usually responds in 30 minutes',
        'Reliable and fuel-efficient sedan. Great for daily commuting and weekend trips.',
        ARRAY['Air Conditioning', 'Bluetooth', 'Apple CarPlay', 'Android Auto', 'Lane Departure Warning'],
        '{"year": 2022, "mileage": 25000, "color": "White", "engine": "1.5L Turbo"}'::jsonb,
        true,
        false,
        false,
        'Automatic',
        'Gasoline',
        5,
        5,
        4,
        25000,
        'White',
        'DEF-456',
        'Comprehensive',
        NOW(),
        NOW(),
        2000.00,
        sedan_id,
        true,
        false
    ),
    
    -- SUV Cars
    (
        gen_random_uuid(),
        test_host_id,
        'Toyota RAV4 2023',
        'Toyota',
        'RAV4',
        2023,
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=400',
        ARRAY['https://images.unsplash.com/photo-1563720223185-11003d516935?w=400', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400'],
        '3500.00',
        3500.00,
        21000.00,
        70000.00,
        'SUV',
        4.7,
        15,
        12,
        'Constantine, Algeria',
        36.3650,
        6.6147,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 45 minutes',
        'Usually responds in 45 minutes',
        'Spacious SUV perfect for family trips and outdoor adventures. All-wheel drive capability.',
        ARRAY['Air Conditioning', 'Bluetooth', 'Backup Camera', 'All-Wheel Drive', 'Roof Rails', 'Heated Seats'],
        '{"year": 2023, "mileage": 12000, "color": "Blue", "engine": "2.5L 4-Cylinder"}'::jsonb,
        true,
        true,
        false,
        'Automatic',
        'Gasoline',
        5,
        5,
        5,
        12000,
        'Blue',
        'GHI-789',
        'Comprehensive',
        NOW(),
        NOW(),
        3500.00,
        suv_id,
        true,
        true
    ),
    
    -- Luxury Cars
    (
        gen_random_uuid(),
        test_host_id,
        'Mercedes-Benz C-Class 2023',
        'Mercedes-Benz',
        'C-Class',
        2023,
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400',
        ARRAY['https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400'],
        '8000.00',
        8000.00,
        48000.00,
        160000.00,
        'Luxury',
        4.9,
        3,
        2,
        'Algiers, Algeria',
        36.7538,
        3.0588,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 15 minutes',
        'Usually responds in 15 minutes',
        'Premium luxury sedan with advanced technology and superior comfort. Perfect for business trips.',
        ARRAY['Air Conditioning', 'Bluetooth', 'Premium Sound System', 'Leather Seats', 'Heated Seats', 'Ventilated Seats', 'Panoramic Sunroof'],
        '{"year": 2023, "mileage": 8000, "color": "Black", "engine": "2.0L Turbo"}'::jsonb,
        true,
        true,
        false,
        'Automatic',
        'Gasoline',
        5,
        5,
        4,
        8000,
        'Black',
        'JKL-012',
        'Premium',
        NOW(),
        NOW(),
        8000.00,
        luxury_id,
        true,
        true
    ),
    
    -- Electric Cars
    (
        gen_random_uuid(),
        test_host_id,
        'Tesla Model 3 2023',
        'Tesla',
        'Model 3',
        2023,
        'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=400',
        ARRAY['https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=400', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400'],
        '6000.00',
        6000.00,
        36000.00,
        120000.00,
        'Electric',
        4.9,
        2,
        1,
        'Algiers, Algeria',
        36.7538,
        3.0588,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 10 minutes',
        'Usually responds in 10 minutes',
        'Electric vehicle with incredible performance and advanced autopilot features. Zero emissions driving.',
        ARRAY['Air Conditioning', 'Bluetooth', 'Autopilot', 'Supercharging', 'Glass Roof', 'Premium Sound System'],
        '{"year": 2023, "mileage": 5000, "color": "Red", "battery": "75 kWh", "range": "350 km"}'::jsonb,
        true,
        true,
        false,
        'Automatic',
        'Electric',
        5,
        5,
        4,
        5000,
        'Red',
        'MNO-345',
        'Premium',
        NOW(),
        NOW(),
        6000.00,
        electric_id,
        true,
        true
    ),
    
    -- Sports Cars
    (
        gen_random_uuid(),
        test_host_id,
        'Porsche 911 2022',
        'Porsche',
        '911',
        2022,
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400',
        ARRAY['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400', 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400'],
        '15000.00',
        15000.00,
        90000.00,
        300000.00,
        'Sports',
        5.0,
        1,
        1,
        'Algiers, Algeria',
        36.7538,
        3.0588,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 5 minutes',
        'Usually responds in 5 minutes',
        'Iconic sports car with incredible performance and handling. Perfect for special occasions and track days.',
        ARRAY['Air Conditioning', 'Bluetooth', 'Sport Exhaust', 'Carbon Fiber Interior', 'Track Mode', 'Premium Sound System'],
        '{"year": 2022, "mileage": 3000, "color": "Yellow", "engine": "3.0L Twin-Turbo"}'::jsonb,
        true,
        true,
        false,
        'Automatic',
        'Gasoline',
        2,
        2,
        2,
        3000,
        'Yellow',
        'PQR-678',
        'Premium',
        NOW(),
        NOW(),
        15000.00,
        sports_id,
        true,
        true
    )
    ON CONFLICT DO NOTHING;

    RAISE NOTICE '✅ Successfully added 6 sample cars to the database!';
    RAISE NOTICE 'Cars added: Toyota Camry, Honda Civic, Toyota RAV4, Mercedes C-Class, Tesla Model 3, Porsche 911';
    RAISE NOTICE 'Categories: Sedan (2 cars), SUV (1 car), Luxury (1 car), Electric (1 car), Sports (1 car)';
    RAISE NOTICE 'Price range: 2,000 - 15,000 DZD per day';
    RAISE NOTICE 'All cars are available and ready for booking!';

END $$;

-- =====================================================
-- VERIFY THE DATA
-- =====================================================

-- Check how many cars we have
SELECT 
    'Total Cars' as metric,
    COUNT(*) as value
FROM public.cars
UNION ALL
SELECT 
    'Available Cars' as metric,
    COUNT(*) as value
FROM public.cars WHERE available = true
UNION ALL
SELECT 
    'Featured Cars' as metric,
    COUNT(*) as value
FROM public.cars WHERE featured = true;

-- Show cars by category
SELECT 
    category,
    COUNT(*) as car_count,
    AVG(price_per_day) as avg_price,
    AVG(rating) as avg_rating
FROM public.cars
GROUP BY category
ORDER BY car_count DESC;

-- Show sample car details
SELECT 
    name,
    brand,
    model,
    category,
    price,
    price_per_day,
    rating,
    location,
    available,
    featured
FROM public.cars
ORDER BY created_at DESC
LIMIT 5; 