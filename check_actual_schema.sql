-- STER Car Rental App - Check Actual Cars Table Schema
-- This script shows the exact structure of the cars table

-- =====================================================
-- CHECK ACTUAL CARS TABLE STRUCTURE
-- =====================================================

-- Show all columns in the cars table with their exact names and constraints
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    ordinal_position
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

-- Show sample data structure (if any exists)
SELECT 
    *
FROM public.cars 
LIMIT 1;

-- Count total cars
SELECT 
    'Total Cars' as metric,
    COUNT(*) as value
FROM public.cars; 