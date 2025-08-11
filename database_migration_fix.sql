-- STER Car Rental App - Database Migration Fix
-- This script adds missing columns to existing tables

-- =====================================================
-- ADD MISSING COLUMNS TO EXISTING TABLES
-- =====================================================

-- Add missing columns to cars table
DO $$ 
BEGIN
    -- Add price_per_day column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'price_per_day') THEN
        ALTER TABLE public.cars ADD COLUMN price_per_day NUMERIC NOT NULL DEFAULT 0.0;
        RAISE NOTICE 'Added price_per_day column to cars table';
    END IF;

    -- Add category_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'category_id') THEN
        ALTER TABLE public.cars ADD COLUMN category_id UUID REFERENCES public.categories(id);
        RAISE NOTICE 'Added category_id column to cars table';
    END IF;

    -- Add rating column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'rating') THEN
        ALTER TABLE public.cars ADD COLUMN rating NUMERIC DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5);
        RAISE NOTICE 'Added rating column to cars table';
    END IF;

    -- Add trips column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'trips') THEN
        ALTER TABLE public.cars ADD COLUMN trips INTEGER DEFAULT 0;
        RAISE NOTICE 'Added trips column to cars table';
    END IF;

    -- Add host_rating column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'host_rating') THEN
        ALTER TABLE public.cars ADD COLUMN host_rating NUMERIC DEFAULT 0.0;
        RAISE NOTICE 'Added host_rating column to cars table';
    END IF;

    -- Add response_time column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'response_time') THEN
        ALTER TABLE public.cars ADD COLUMN response_time TEXT;
        RAISE NOTICE 'Added response_time column to cars table';
    END IF;

    -- Add features column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'features') THEN
        ALTER TABLE public.cars ADD COLUMN features JSONB DEFAULT '[]';
        RAISE NOTICE 'Added features column to cars table';
    END IF;

    -- Add images column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'images') THEN
        ALTER TABLE public.cars ADD COLUMN images JSONB DEFAULT '[]';
        RAISE NOTICE 'Added images column to cars table';
    END IF;

    -- Add specs column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'specs') THEN
        ALTER TABLE public.cars ADD COLUMN specs JSONB DEFAULT '{}';
        RAISE NOTICE 'Added specs column to cars table';
    END IF;

    -- Add transmission column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'transmission') THEN
        ALTER TABLE public.cars ADD COLUMN transmission TEXT;
        RAISE NOTICE 'Added transmission column to cars table';
    END IF;

    -- Add fuel_type column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'fuel_type') THEN
        ALTER TABLE public.cars ADD COLUMN fuel_type TEXT;
        RAISE NOTICE 'Added fuel_type column to cars table';
    END IF;

    -- Add passengers column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'passengers') THEN
        ALTER TABLE public.cars ADD COLUMN passengers INTEGER DEFAULT 4;
        RAISE NOTICE 'Added passengers column to cars table';
    END IF;

    -- Add available column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'available') THEN
        ALTER TABLE public.cars ADD COLUMN available BOOLEAN DEFAULT TRUE;
        RAISE NOTICE 'Added available column to cars table';
    END IF;

    -- Add featured column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'featured') THEN
        ALTER TABLE public.cars ADD COLUMN featured BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Added featured column to cars table';
    END IF;

    -- Add name column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'name') THEN
        ALTER TABLE public.cars ADD COLUMN name TEXT NOT NULL DEFAULT 'Car';
        RAISE NOTICE 'Added name column to cars table';
    END IF;

    -- Add image column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'image') THEN
        ALTER TABLE public.cars ADD COLUMN image TEXT;
        RAISE NOTICE 'Added image column to cars table';
    END IF;

    -- Add host_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'host_id') THEN
        ALTER TABLE public.cars ADD COLUMN host_id UUID REFERENCES public.profiles(id);
        RAISE NOTICE 'Added host_id column to cars table';
    END IF;

    -- Add host_name column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'host_name') THEN
        ALTER TABLE public.cars ADD COLUMN host_name TEXT;
        RAISE NOTICE 'Added host_name column to cars table';
    END IF;

    -- Add host_image column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'host_image') THEN
        ALTER TABLE public.cars ADD COLUMN host_image TEXT;
        RAISE NOTICE 'Added host_image column to cars table';
    END IF;

    -- Add description column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'description') THEN
        ALTER TABLE public.cars ADD COLUMN description TEXT;
        RAISE NOTICE 'Added description column to cars table';
    END IF;

    -- Add location column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'location') THEN
        ALTER TABLE public.cars ADD COLUMN location TEXT;
        RAISE NOTICE 'Added location column to cars table';
    END IF;

    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'cars' AND column_name = 'updated_at') THEN
        ALTER TABLE public.cars ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column to cars table';
    END IF;

END $$;

-- Add missing columns to profiles table
DO $$ 
BEGIN
    -- Add phone column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'phone') THEN
        ALTER TABLE public.profiles ADD COLUMN phone TEXT;
        RAISE NOTICE 'Added phone column to profiles table';
    END IF;

    -- Add profile_image column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'profile_image') THEN
        ALTER TABLE public.profiles ADD COLUMN profile_image TEXT;
        RAISE NOTICE 'Added profile_image column to profiles table';
    END IF;

    -- Add is_email_verified column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'is_email_verified') THEN
        ALTER TABLE public.profiles ADD COLUMN is_email_verified BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Added is_email_verified column to profiles table';
    END IF;

    -- Add is_phone_verified column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'is_phone_verified') THEN
        ALTER TABLE public.profiles ADD COLUMN is_phone_verified BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Added is_phone_verified column to profiles table';
    END IF;

    -- Add preferences column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'preferences') THEN
        ALTER TABLE public.profiles ADD COLUMN preferences JSONB DEFAULT '{}';
        RAISE NOTICE 'Added preferences column to profiles table';
    END IF;

    -- Add saved_cars column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'saved_cars') THEN
        ALTER TABLE public.profiles ADD COLUMN saved_cars TEXT[] DEFAULT '{}';
        RAISE NOTICE 'Added saved_cars column to profiles table';
    END IF;

    -- Add booking_history column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'booking_history') THEN
        ALTER TABLE public.profiles ADD COLUMN booking_history TEXT[] DEFAULT '{}';
        RAISE NOTICE 'Added booking_history column to profiles table';
    END IF;

    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'updated_at') THEN
        ALTER TABLE public.profiles ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column to profiles table';
    END IF;

    -- Add name column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'name') THEN
        ALTER TABLE public.profiles ADD COLUMN name TEXT NOT NULL DEFAULT 'User';
        RAISE NOTICE 'Added name column to profiles table';
    END IF;

    -- Add email column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'email') THEN
        ALTER TABLE public.profiles ADD COLUMN email TEXT UNIQUE NOT NULL DEFAULT 'user@example.com';
        RAISE NOTICE 'Added email column to profiles table';
    END IF;

    -- Add role column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'role') THEN
        ALTER TABLE public.profiles ADD COLUMN role TEXT DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin'));
        RAISE NOTICE 'Added role column to profiles table';
    END IF;

    -- Add created_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'created_at') THEN
        ALTER TABLE public.profiles ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added created_at column to profiles table';
    END IF;

    -- Add last_login_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'profiles' AND column_name = 'last_login_at') THEN
        ALTER TABLE public.profiles ADD COLUMN last_login_at TIMESTAMP WITH TIME ZONE;
        RAISE NOTICE 'Added last_login_at column to profiles table';
    END IF;

END $$;

-- =====================================================
-- CREATE MISSING TABLES
-- =====================================================

-- Create categories table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  image TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add missing columns to bookings table
DO $$ 
BEGIN
    -- Add car_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'car_id') THEN
        ALTER TABLE public.bookings ADD COLUMN car_id UUID REFERENCES public.cars(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added car_id column to bookings table';
    END IF;

    -- Add user_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'user_id') THEN
        ALTER TABLE public.bookings ADD COLUMN user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added user_id column to bookings table';
    END IF;

    -- Add host_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'host_id') THEN
        ALTER TABLE public.bookings ADD COLUMN host_id UUID REFERENCES public.profiles(id);
        RAISE NOTICE 'Added host_id column to bookings table';
    END IF;

    -- Add start_date column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'start_date') THEN
        ALTER TABLE public.bookings ADD COLUMN start_date DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Added start_date column to bookings table';
    END IF;

    -- Add end_date column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'end_date') THEN
        ALTER TABLE public.bookings ADD COLUMN end_date DATE NOT NULL DEFAULT CURRENT_DATE;
        RAISE NOTICE 'Added end_date column to bookings table';
    END IF;

    -- Add total_price column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'total_price') THEN
        ALTER TABLE public.bookings ADD COLUMN total_price NUMERIC NOT NULL DEFAULT 0.0;
        RAISE NOTICE 'Added total_price column to bookings table';
    END IF;

    -- Add status column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'status') THEN
        ALTER TABLE public.bookings ADD COLUMN status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled'));
        RAISE NOTICE 'Added status column to bookings table';
    END IF;

    -- Add notes column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'notes') THEN
        ALTER TABLE public.bookings ADD COLUMN notes TEXT;
        RAISE NOTICE 'Added notes column to bookings table';
    END IF;

    -- Add created_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'created_at') THEN
        ALTER TABLE public.bookings ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added created_at column to bookings table';
    END IF;

    -- Add updated_at column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'bookings' AND column_name = 'updated_at') THEN
        ALTER TABLE public.bookings ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column to bookings table';
    END IF;

END $$;

-- Create availability table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  car_id UUID REFERENCES public.cars(id) ON DELETE CASCADE,
  available_date DATE NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  price_override NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(car_id, available_date)
);

-- Create reviews table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reviewer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  target_id UUID NOT NULL,
  target_type TEXT NOT NULL CHECK (target_type IN ('car', 'host', 'user')),
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create payments table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  amount NUMERIC NOT NULL,
  currency TEXT DEFAULT 'USD',
  payment_method TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create favorites table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  car_id UUID REFERENCES public.cars(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, car_id)
);

-- Create notifications table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'general',
  related_id TEXT,
  read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create messages table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file')),
  read BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create disputes table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.disputes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  initiator_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'investigating', 'resolved', 'closed')),
  resolution TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create host_requests table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.host_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  documents JSONB DEFAULT '[]',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create locations table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT,
  country TEXT NOT NULL,
  latitude NUMERIC,
  longitude NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create admin_logs table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.admin_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  target_type TEXT,
  target_id TEXT,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INSERT SAMPLE CATEGORIES
-- =====================================================

-- Insert sample categories if they don't exist
INSERT INTO public.categories (name, description, icon) VALUES
('Sedan', 'Comfortable family cars', 'sedan'),
('SUV', 'Spacious sport utility vehicles', 'suv'),
('Luxury', 'Premium and luxury vehicles', 'luxury'),
('Electric', 'Environmentally friendly electric cars', 'electric'),
('Sports', 'High-performance sports cars', 'sports')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- CREATE INDEXES
-- =====================================================

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_cars_category_id ON public.cars(category_id);
CREATE INDEX IF NOT EXISTS idx_cars_available ON public.cars(available);
CREATE INDEX IF NOT EXISTS idx_cars_featured ON public.cars(featured);
CREATE INDEX IF NOT EXISTS idx_cars_location ON public.cars(location);
CREATE INDEX IF NOT EXISTS idx_cars_rating ON public.cars(rating DESC);
CREATE INDEX IF NOT EXISTS idx_cars_price ON public.cars(price_per_day);
CREATE INDEX IF NOT EXISTS idx_cars_created_at ON public.cars(created_at DESC);

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE 'Database migration completed successfully!';
  RAISE NOTICE 'All missing columns have been added to existing tables.';
  RAISE NOTICE 'Sample categories have been inserted.';
  RAISE NOTICE 'Indexes have been created for optimal performance.';
END $$; 