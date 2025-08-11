-- STER Car Rental App - Clean Test Cars Script
-- This script adds sample cars to the database using only essential columns

-- =====================================================
-- STEP 1: CREATE CATEGORIES (if they don't exist)
-- =====================================================

INSERT INTO public.categories (name, description, icon) VALUES
('Sedan', 'Comfortable family cars', 'sedan'),
('SUV', 'Spacious sport utility vehicles', 'suv'),
('Luxury', 'Premium and luxury vehicles', 'luxury'),
('Electric', 'Environmentally friendly electric cars', 'electric'),
('Sports', 'High-performance sports cars', 'sports')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- STEP 2: GET OR CREATE A TEST HOST
-- =====================================================

DO $$
DECLARE
    test_host_id UUID;
BEGIN
    -- Try to get an existing host from user_profiles table
    SELECT id INTO test_host_id FROM public.user_profiles LIMIT 1;
    
    -- If no host exists, create one in user_profiles table
    IF test_host_id IS NULL THEN
        INSERT INTO public.user_profiles (id, name, email, role, is_email_verified, created_at)
        VALUES (
            gen_random_uuid(),
            'Test Host',
            'testhost@example.com',
            'host',
            true,
            NOW()
        ) RETURNING id INTO test_host_id;
    END IF;

    -- =====================================================
    -- STEP 3: INSERT CARS WITH MINIMAL REQUIRED FIELDS
    -- =====================================================
    
    -- Car 1: Toyota Camry
    INSERT INTO public.cars (
        id, host_id, name, image, price, price_per_day, category, 
        location, host_name, description, available, featured, created_at
    ) VALUES (
        gen_random_uuid(),
        test_host_id,
        'Toyota Camry 2023',
        'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400',
        '2500.00',
        2500.00,
        'Sedan',
        'Algiers, Algeria',
        'Test Host',
        'Comfortable sedan perfect for city driving and family trips.',
        true,
        true,
        NOW()
    );

    -- Car 2: Honda Civic
    INSERT INTO public.cars (
        id, host_id, name, image, price, price_per_day, category,
        location, host_name, description, available, featured, created_at
    ) VALUES (
        gen_random_uuid(),
        test_host_id,
        'Honda Civic 2022',
        'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400',
        '2000.00',
        2000.00,
        'Sedan',
        'Oran, Algeria',
        'Test Host',
        'Reliable and fuel-efficient sedan. Great for daily commuting.',
        true,
        false,
        NOW()
    );

    -- Car 3: Toyota RAV4
    INSERT INTO public.cars (
        id, host_id, name, image, price, price_per_day, category,
        location, host_name, description, available, featured, created_at
    ) VALUES (
        gen_random_uuid(),
        test_host_id,
        'Toyota RAV4 2023',
        'https://images.unsplash.com/photo-1563720223185-11003d516935?w=400',
        '3500.00',
        3500.00,
        'SUV',
        'Constantine, Algeria',
        'Test Host',
        'Spacious SUV perfect for family trips and outdoor adventures.',
        true,
        true,
        NOW()
    );

    -- Car 4: Mercedes C-Class
    INSERT INTO public.cars (
        id, host_id, name, image, price, price_per_day, category,
        location, host_name, description, available, featured, created_at
    ) VALUES (
        gen_random_uuid(),
        test_host_id,
        'Mercedes-Benz C-Class 2023',
        'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=400',
        '8000.00',
        8000.00,
        'Luxury',
        'Algiers, Algeria',
        'Test Host',
        'Premium luxury sedan with advanced technology and superior comfort.',
        true,
        true,
        NOW()
    );

    -- Car 5: Tesla Model 3
    INSERT INTO public.cars (
        id, host_id, name, image, price, price_per_day, category,
        location, host_name, description, available, featured, created_at
    ) VALUES (
        gen_random_uuid(),
        test_host_id,
        'Tesla Model 3 2023',
        'https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=400',
        '6000.00',
        6000.00,
        'Electric',
        'Algiers, Algeria',
        'Test Host',
        'Electric vehicle with incredible performance and advanced autopilot features.',
        true,
        true,
        NOW()
    );

    -- Car 6: Porsche 911
    INSERT INTO public.cars (
        id, host_id, name, image, price, price_per_day, category,
        location, host_name, description, available, featured, created_at
    ) VALUES (
        gen_random_uuid(),
        test_host_id,
        'Porsche 911 2022',
        'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400',
        '15000.00',
        15000.00,
        'Sports',
        'Algiers, Algeria',
        'Test Host',
        'Iconic sports car with incredible performance and handling.',
        true,
        true,
        NOW()
    );

    RAISE NOTICE '✅ Successfully added 6 test cars to the database!';
    RAISE NOTICE 'Cars: Toyota Camry, Honda Civic, Toyota RAV4, Mercedes C-Class, Tesla Model 3, Porsche 911';
    RAISE NOTICE 'Price range: 2,000 - 15,000 DZD per day';

END $$;

-- =====================================================
-- STEP 4: VERIFY THE DATA
-- =====================================================

-- Show total cars count
SELECT 
    'Total Cars' as metric,
    COUNT(*) as value
FROM public.cars;

-- Show cars by category
SELECT 
    category,
    COUNT(*) as car_count,
    AVG(price_per_day) as avg_price
FROM public.cars
GROUP BY category
ORDER BY car_count DESC;

-- Show sample car details
SELECT 
    name,
    category,
    price,
    price_per_day,
    location,
    available,
    featured
FROM public.cars
ORDER BY created_at DESC
LIMIT 5; 