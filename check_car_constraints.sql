-- Check Car Table Constraints
-- Run this in your Supabase SQL Editor

-- Check all constraints on the cars table
SELECT 
  tc.constraint_name,
  tc.constraint_type,
  kcu.column_name,
  cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
LEFT JOIN information_schema.check_constraints cc
  ON tc.constraint_name = cc.constraint_name
  AND tc.table_schema = cc.table_schema
WHERE tc.table_name = 'cars'
AND tc.table_schema = 'public'
AND tc.constraint_type = 'CHECK';

-- Check the specific fuel_type constraint
SELECT 
  constraint_name,
  check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'cars_fuel_type_check';

-- Show the current fuel_type values in the table
SELECT DISTINCT fuel_type FROM cars WHERE fuel_type IS NOT NULL;

-- Show the table structure again
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'cars' 
AND table_schema = 'public'
ORDER BY ordinal_position; 