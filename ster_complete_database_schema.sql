-- STER Car Rental App - Complete Supabase Database Schema
-- Generated based on Flutter app analysis

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Note: JWT secret is managed by Supabase automatically
-- No need to set app.jwt_secret manually

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Users/Profiles Table
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  profile_image TEXT,
  role TEXT DEFAULT 'user' CHECK (role IN ('guest', 'user', 'host', 'admin')),
  is_email_verified BOOLEAN DEFAULT FALSE,
  is_phone_verified BOOLEAN DEFAULT FALSE,
  preferences JSONB DEFAULT '{}',
  saved_cars TEXT[] DEFAULT '{}',
  booking_history TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE
);

-- Categories Table
CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  icon TEXT,
  image TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cars Table
CREATE TABLE public.cars (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  image TEXT,
  price_per_day NUMERIC NOT NULL,
  category_id UUID REFERENCES public.categories(id),
  rating NUMERIC DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
  trips INTEGER DEFAULT 0,
  location TEXT,
  host_id UUID REFERENCES public.profiles(id),
  host_name TEXT,
  host_image TEXT,
  host_rating NUMERIC DEFAULT 0.0,
  response_time TEXT,
  description TEXT,
  features JSONB DEFAULT '[]',
  images JSONB DEFAULT '[]',
  specs JSONB DEFAULT '{}',
  transmission TEXT,
  fuel_type TEXT,
  passengers INTEGER DEFAULT 4,
  available BOOLEAN DEFAULT TRUE,
  featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Bookings Table
CREATE TABLE public.bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  car_id UUID REFERENCES public.cars(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  host_id UUID REFERENCES public.profiles(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_price NUMERIC NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- SUPPORTING TABLES
-- =====================================================

-- Availability Table
CREATE TABLE public.availability (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  car_id UUID REFERENCES public.cars(id) ON DELETE CASCADE,
  available_date DATE NOT NULL,
  is_available BOOLEAN DEFAULT TRUE,
  price_override NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(car_id, available_date)
);

-- Reviews Table
CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reviewer_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  reviewer_name TEXT NOT NULL,
  reviewer_image TEXT,
  target_id UUID NOT NULL, -- car_id, host_id, or rental_id
  type TEXT DEFAULT 'car' CHECK (type IN ('car', 'host', 'rental_experience', 'app_experience')),
  overall_rating NUMERIC NOT NULL CHECK (overall_rating >= 1 AND overall_rating <= 5),
  category_ratings JSONB DEFAULT '{}',
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  photos TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'flagged')),
  helpful_votes INTEGER DEFAULT 0,
  total_votes INTEGER DEFAULT 0,
  helpful_voters TEXT[] DEFAULT '{}',
  reported_by TEXT[] DEFAULT '{}',
  moderator_notes TEXT,
  is_verified_rental BOOLEAN DEFAULT FALSE,
  rental_id UUID,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  published_at TIMESTAMP WITH TIME ZONE
);

-- Payments Table
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  booking_id UUID REFERENCES public.bookings(id),
  rental_id UUID,
  type TEXT DEFAULT 'rental_payment' CHECK (type IN ('rental_payment', 'deposit', 'insurance', 'additional_services', 'late_fees', 'damage_charges', 'refund', 'subscription')),
  method TEXT DEFAULT 'credit_card' CHECK (method IN ('credit_card', 'debit_card', 'bank_transfer', 'cash', 'digital_wallet', 'cryptocurrency', 'check', 'money_order')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded', 'partially_refunded', 'disputed')),
  amount NUMERIC NOT NULL,
  currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'EUR', 'GBP', 'SAR', 'AED', 'QAR', 'KWD', 'BHD', 'OMR', 'JOD', 'EGP', 'MAD', 'TND', 'DZD', 'LYD')),
  tax_amount NUMERIC,
  service_fee NUMERIC,
  discount_amount NUMERIC,
  final_amount NUMERIC NOT NULL,
  transaction_id TEXT,
  payment_gateway TEXT,
  card_last_four TEXT,
  card_brand TEXT,
  card_holder_name TEXT,
  failure_reason TEXT,
  refund_reason TEXT,
  payment_details JSONB,
  billing_address JSONB,
  shipping_address JSONB,
  receipt_url TEXT,
  invoice_url TEXT,
  attachments TEXT[],
  notes TEXT,
  metadata JSONB,
  is_recurring BOOLEAN DEFAULT FALSE,
  recurring_payment_id TEXT,
  next_payment_date DATE,
  installment_number INTEGER,
  total_installments INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  failed_at TIMESTAMP WITH TIME ZONE,
  refunded_at TIMESTAMP WITH TIME ZONE
);

-- Favorites Table
CREATE TABLE public.favorites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  car_id UUID REFERENCES public.cars(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, car_id)
);

-- Notifications Table
CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error')),
  read BOOLEAN DEFAULT FALSE,
  data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages Table
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  receiver_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'location')),
  attachments TEXT[] DEFAULT '{}',
  is_read BOOLEAN DEFAULT FALSE,
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE
);

-- Disputes Table
CREATE TABLE public.disputes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  booking_id UUID REFERENCES public.bookings(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  reason TEXT NOT NULL,
  description TEXT,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'under_review', 'resolved', 'closed')),
  resolution TEXT,
  evidence TEXT[] DEFAULT '{}',
  moderator_id UUID REFERENCES public.profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Host Requests Table
CREATE TABLE public.host_requests (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  request_note TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  reviewed_by UUID REFERENCES public.profiles(id),
  reviewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Locations Table
CREATE TABLE public.locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  city TEXT NOT NULL,
  state TEXT,
  country TEXT DEFAULT 'Algeria',
  latitude NUMERIC,
  longitude NUMERIC,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Admin Logs Table
CREATE TABLE public.admin_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID REFERENCES public.profiles(id),
  action TEXT NOT NULL,
  target_table TEXT,
  target_id UUID,
  details JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Cars indexes
CREATE INDEX idx_cars_host_id ON public.cars(host_id);
CREATE INDEX idx_cars_category_id ON public.cars(category_id);
CREATE INDEX idx_cars_available ON public.cars(available);
CREATE INDEX idx_cars_featured ON public.cars(featured);
CREATE INDEX idx_cars_location ON public.cars(location);
CREATE INDEX idx_cars_rating ON public.cars(rating DESC);

-- Bookings indexes
CREATE INDEX idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX idx_bookings_car_id ON public.bookings(car_id);
CREATE INDEX idx_bookings_host_id ON public.bookings(host_id);
CREATE INDEX idx_bookings_status ON public.bookings(status);
CREATE INDEX idx_bookings_dates ON public.bookings(start_date, end_date);

-- Reviews indexes
CREATE INDEX idx_reviews_reviewer_id ON public.reviews(reviewer_id);
CREATE INDEX idx_reviews_target_id ON public.reviews(target_id);
CREATE INDEX idx_reviews_type ON public.reviews(type);
CREATE INDEX idx_reviews_status ON public.reviews(status);

-- Payments indexes
CREATE INDEX idx_payments_user_id ON public.payments(user_id);
CREATE INDEX idx_payments_booking_id ON public.payments(booking_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_payments_created_at ON public.payments(created_at DESC);

-- Favorites indexes
CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX idx_favorites_car_id ON public.favorites(car_id);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_read ON public.notifications(read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

-- Messages indexes
CREATE INDEX idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON public.messages(receiver_id);
CREATE INDEX idx_messages_sent_at ON public.messages(sent_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.host_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_logs ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Cars policies
CREATE POLICY "Anyone can view available cars" ON public.cars
  FOR SELECT USING (available = true);

CREATE POLICY "Hosts can manage their own cars" ON public.cars
  FOR ALL USING (auth.uid() = host_id);

CREATE POLICY "Admins can manage all cars" ON public.cars
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.profiles 
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Bookings policies
CREATE POLICY "Users can view their own bookings" ON public.bookings
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = host_id);

CREATE POLICY "Users can create their own bookings" ON public.bookings
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bookings" ON public.bookings
  FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = host_id);

-- Reviews policies
CREATE POLICY "Anyone can view approved reviews" ON public.reviews
  FOR SELECT USING (status = 'approved');

CREATE POLICY "Users can create reviews" ON public.reviews
  FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

CREATE POLICY "Users can update their own reviews" ON public.reviews
  FOR UPDATE USING (auth.uid() = reviewer_id);

-- Favorites policies
CREATE POLICY "Users can view their own favorites" ON public.favorites
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage their own favorites" ON public.favorites
  FOR ALL USING (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can view their own notifications" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id);

-- Messages policies
CREATE POLICY "Users can view messages they sent or received" ON public.messages
  FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send messages" ON public.messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- =====================================================
-- FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cars_updated_at BEFORE UPDATE ON public.cars
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_disputes_updated_at BEFORE UPDATE ON public.disputes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, role)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'name', NEW.email, 'user');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create profile on user signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- SAMPLE DATA INSERTION
-- =====================================================

-- Insert sample categories
INSERT INTO public.categories (name, description, icon) VALUES
('SUV', 'Sport Utility Vehicles for family trips', '🚙'),
('Luxury', 'Premium vehicles for special occasions', '🏎️'),
('Electric', 'Environmentally friendly electric cars', '⚡'),
('Convertible', 'Open-top driving experience', '🌞'),
('Business', 'Professional vehicles for business travel', '💼'),
('Sport', 'High-performance sports cars', '🏁'),
('Mini', 'Compact cars for city driving', '🚗');

-- Insert sample cars (these will be added by hosts)
-- Sample data can be inserted through the app interface

-- =====================================================
-- VIEWS FOR COMMON QUERIES
-- =====================================================

-- View for available cars with host information
CREATE VIEW public.available_cars AS
SELECT 
  c.*,
  p.name as host_full_name,
  p.profile_image as host_profile_image,
  cat.name as category_name
FROM public.cars c
JOIN public.profiles p ON c.host_id = p.id
JOIN public.categories cat ON c.category_id = cat.id
WHERE c.available = true;

-- View for user bookings with car details
CREATE VIEW public.user_bookings AS
SELECT 
  b.*,
  c.name as car_name,
  c.image as car_image,
  c.location as car_location,
  p.name as host_name
FROM public.bookings b
JOIN public.cars c ON b.car_id = c.id
JOIN public.profiles p ON c.host_id = p.id;

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE public.profiles IS 'User profiles with role-based access';
COMMENT ON TABLE public.cars IS 'Car listings with availability and pricing';
COMMENT ON TABLE public.bookings IS 'Car rental bookings with status tracking';
COMMENT ON TABLE public.reviews IS 'User reviews and ratings for cars and hosts';
COMMENT ON TABLE public.payments IS 'Payment processing with multiple methods';
COMMENT ON TABLE public.favorites IS 'User saved cars for quick access';
COMMENT ON TABLE public.notifications IS 'User notifications and alerts';
COMMENT ON TABLE public.messages IS 'User messaging system';
COMMENT ON TABLE public.disputes IS 'Dispute resolution system';
COMMENT ON TABLE public.host_requests IS 'Host application process';
COMMENT ON TABLE public.admin_logs IS 'Administrative activity tracking';

-- =====================================================
-- END OF SCHEMA
-- ===================================================== 