-- STER Car Rental App - Check Cars Table Schema
-- This script shows the actual structure of the cars table

-- =====================================================
-- CHECK CARS TABLE STRUCTURE
-- =====================================================

-- Show all columns in the cars table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'cars'
ORDER BY ordinal_position;

-- Show table constraints
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    ccu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.constraint_column_usage ccu 
ON tc.constraint_name = ccu.constraint_name
WHERE tc.table_schema = 'public' 
AND tc.table_name = 'cars';

-- Show sample data (if any exists)
SELECT 
    name,
    price,
    price_per_day,
    rating,
    available,
    featured
FROM public.cars 
LIMIT 5;

-- Count total cars
SELECT 
    'Total Cars' as metric,
    COUNT(*) as value
FROM public.cars; 