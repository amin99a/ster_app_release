-- STER Car Rental App - Add Test Cars (Simplified)
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

    -- Insert sample cars (simplified with JSONB arrays)
    INSERT INTO public.cars (
        id, name, image, price_per_day, category_id, rating, trips,
        location, host_id, host_name, host_image, host_rating,
        response_time, description, features, images, specs,
        transmission, fuel_type, passengers, available, featured,
        created_at, updated_at
    ) VALUES
    -- Sedan Cars
    (
        gen_random_uuid(),
        'Toyota Camry 2023',
        'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400',
        2500.00,
        sedan_id,
        4.5,
        12,
        'Algiers, Algeria',
        test_host_id,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 1 hour',
        'Comfortable sedan perfect for city driving and family trips. Well maintained with full service history.',
        '["Air Conditioning", "Bluetooth", "Backup Camera", "Cruise Control", "USB Charging"]'::jsonb,
        '["https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400", "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]'::jsonb,
        '{"year": 2023, "mileage": 15000, "color": "Silver", "engine": "2.5L 4-Cylinder"}'::jsonb,
        'Automatic',
        'Gasoline',
        5,
        true,
        true,
        NOW(),
        NOW()
    ),
    (
        gen_random_uuid(),
        'Honda Civic 2022',
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400',
        2000.00,
        sedan_id,
        4.3,
        8,
        'Oran, Algeria',
        test_host_id,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 30 minutes',
        'Reliable and fuel-efficient sedan. Great for daily commuting and weekend trips.',
        '["Air Conditioning", "Bluetooth", "Apple CarPlay", "Android Auto", "Lane Departure Warning"]'::jsonb,
        '["https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400", "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400"]'::jsonb,
        '{"year": 2022, "mileage": 25000, "color": "White", "engine": "1.5L Turbo"}'::jsonb,
        'Automatic',
        'Gasoline',
        5,
        true,
        false,
        NOW(),
        NOW()
    ),
    
    -- SUV Cars
    (
        gen_random_uuid(),
        'Toyota RAV4 2023',
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=400',
        3500.00,
        suv_id,
        4.7,
        15,
        'Constantine, Algeria',
        test_host_id,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 45 minutes',
        'Spacious SUV perfect for family trips and outdoor adventures. All-wheel drive capability.',
        '["Air Conditioning", "Bluetooth", "Backup Camera", "All-Wheel Drive", "Roof Rails", "Heated Seats"]'::jsonb,
        '["https://images.unsplash.com/photo-1563720223185-11003d516935?w=400", "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]'::jsonb,
        '{"year": 2023, "mileage": 12000, "color": "Blue", "engine": "2.5L 4-Cylinder"}'::jsonb,
        'Automatic',
        'Gasoline',
        5,
        true,
        true,
        NOW(),
        NOW()
    ),
    
    -- Luxury Cars
    (
        gen_random_uuid(),
        'Mercedes-Benz C-Class 2023',
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400',
        8000.00,
        luxury_id,
        4.9,
        3,
        'Algiers, Algeria',
        test_host_id,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 15 minutes',
        'Premium luxury sedan with advanced technology and superior comfort. Perfect for business trips.',
        '["Air Conditioning", "Bluetooth", "Premium Sound System", "Leather Seats", "Heated Seats", "Ventilated Seats", "Panoramic Sunroof"]'::jsonb,
        '["https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400", "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]'::jsonb,
        '{"year": 2023, "mileage": 8000, "color": "Black", "engine": "2.0L Turbo"}'::jsonb,
        'Automatic',
        'Gasoline',
        5,
        true,
        true,
        NOW(),
        NOW()
    ),
    
    -- Electric Cars
    (
        gen_random_uuid(),
        'Tesla Model 3 2023',
        'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=400',
        6000.00,
        electric_id,
        4.9,
        2,
        'Algiers, Algeria',
        test_host_id,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 10 minutes',
        'Electric vehicle with incredible performance and advanced autopilot features. Zero emissions driving.',
        '["Air Conditioning", "Bluetooth", "Autopilot", "Supercharging", "Glass Roof", "Premium Sound System"]'::jsonb,
        '["https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=400", "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]'::jsonb,
        '{"year": 2023, "mileage": 5000, "color": "Red", "battery": "75 kWh", "range": "350 km"}'::jsonb,
        'Automatic',
        'Electric',
        5,
        true,
        true,
        NOW(),
        NOW()
    ),
    
    -- Sports Cars
    (
        gen_random_uuid(),
        'Porsche 911 2022',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400',
        15000.00,
        sports_id,
        5.0,
        1,
        'Algiers, Algeria',
        test_host_id,
        'Test Host',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        4.8,
        'Usually responds in 5 minutes',
        'Iconic sports car with incredible performance and handling. Perfect for special occasions and track days.',
        '["Air Conditioning", "Bluetooth", "Sport Exhaust", "Carbon Fiber Interior", "Track Mode", "Premium Sound System"]'::jsonb,
        '["https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400", "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]'::jsonb,
        '{"year": 2022, "mileage": 3000, "color": "Yellow", "engine": "3.0L Twin-Turbo"}'::jsonb,
        'Automatic',
        'Gasoline',
        2,
        true,
        true,
        NOW(),
        NOW()
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
    c.name as category,
    COUNT(cars.id) as car_count,
    AVG(cars.price_per_day) as avg_price,
    AVG(cars.rating) as avg_rating
FROM public.categories c
LEFT JOIN public.cars ON cars.category_id = c.id
GROUP BY c.id, c.name
ORDER BY car_count DESC;

-- Show sample car details
SELECT 
    name,
    price_per_day,
    rating,
    location,
    available,
    featured
FROM public.cars
ORDER BY created_at DESC
LIMIT 5; 