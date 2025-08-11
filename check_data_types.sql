-- STER Car Rental App - Check Data Types
-- This script shows the exact data types of features and images columns

-- =====================================================
-- CHECK FEATURES AND IMAGES DATA TYPES
-- =====================================================

-- Show data types for features and images columns
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'cars'
AND column_name IN ('features', 'images', 'specs')
ORDER BY column_name;

-- Show all columns for reference
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'cars'
ORDER BY ordinal_position; 