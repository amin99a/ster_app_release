-- STER Car Rental App - Database Verification
-- This script verifies that the database is properly set up

-- =====================================================
-- CHECK DATABASE STRUCTURE
-- =====================================================

DO $$
DECLARE
    table_count INTEGER;
    car_count INTEGER;
    category_count INTEGER;
    profile_count INTEGER;
BEGIN
    -- Check if tables exist
    SELECT COUNT(*) INTO table_count 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name IN ('cars', 'profiles', 'categories', 'bookings', 'reviews', 'payments', 'favorites', 'notifications', 'messages');
    
    RAISE NOTICE 'Database Tables: %/9 tables found', table_count;
    
    -- Check car data
    SELECT COUNT(*) INTO car_count FROM public.cars;
    RAISE NOTICE 'Cars in database: % cars', car_count;
    
    -- Check categories
    SELECT COUNT(*) INTO category_count FROM public.categories;
    RAISE NOTICE 'Categories: % categories', category_count;
    
    -- Check profiles
    SELECT COUNT(*) INTO profile_count FROM public.profiles;
    RAISE NOTICE 'Profiles: % profiles', profile_count;
    
    -- Summary
    IF table_count = 9 AND car_count > 0 AND category_count > 0 THEN
        RAISE NOTICE '✅ Database is properly set up and ready for testing!';
    ELSE
        RAISE NOTICE '⚠️ Database needs setup. Run database_migration_fix.sql first.';
    END IF;
    
END $$;

-- =====================================================
-- SHOW SAMPLE DATA
-- =====================================================

-- Show categories
SELECT 'Categories' as table_name, name, description FROM public.categories ORDER BY name;

-- Show sample cars
SELECT 'Cars' as table_name, name, price_per_day, rating, location, available FROM public.cars ORDER BY created_at DESC LIMIT 5;

-- Show sample profiles
SELECT 'Profiles' as table_name, name, email, role, created_at FROM public.profiles ORDER BY created_at DESC LIMIT 3;

-- =====================================================
-- TEST QUERIES
-- =====================================================

-- Test car search (similar to what the app will do)
SELECT 
    name,
    price_per_day,
    rating,
    location,
    available
FROM public.cars 
WHERE available = true 
ORDER BY rating DESC, price_per_day ASC 
LIMIT 5;

-- Test category filtering
SELECT 
    c.name as category,
    COUNT(cars.id) as car_count,
    AVG(cars.price_per_day) as avg_price
FROM public.categories c
LEFT JOIN public.cars cars ON cars.category_id = c.id
WHERE cars.available = true
GROUP BY c.id, c.name
ORDER BY car_count DESC;

-- Test price range filtering
SELECT 
    name,
    price_per_day,
    rating
FROM public.cars 
WHERE available = true 
    AND price_per_day BETWEEN 2000 AND 5000
ORDER BY price_per_day ASC;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'DATABASE VERIFICATION COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'If you see cars listed above, your database is ready!';
    RAISE NOTICE 'You can now test your Flutter app with real data.';
    RAISE NOTICE '========================================';
END $$; 