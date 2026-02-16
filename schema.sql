-- Farmer Crop Intelligence Database Schema
-- Optimized for Supabase (PostgreSQL)

-- Enable relevant extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles Table (Extends Supabase Auth)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    phone_number TEXT,
    role TEXT CHECK (role IN ('farmer', 'advisor', 'researcher', 'admin')),
    location_json JSONB, -- Coordinates and city name
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Farms Table
CREATE TABLE IF NOT EXISTS public.farms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    location TEXT,
    size_hectares NUMERIC,
    soil_type TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Crops Table
CREATE TABLE IF NOT EXISTS public.crops (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID REFERENCES public.farms(id) ON DELETE CASCADE NOT NULL,
    variety TEXT NOT NULL,
    planting_date DATE,
    expected_harvest_date DATE,
    status TEXT CHECK (status IN ('planted', 'growing', 'harvested', 'unhealthy')),
    health_score INTEGER DEFAULT 100,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Health Logs (Intelligence Data)
CREATE TABLE IF NOT EXISTS public.health_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_id UUID REFERENCES public.crops(id) ON DELETE CASCADE NOT NULL,
    reporter_id UUID REFERENCES public.profiles(id),
    observation TEXT NOT NULL,
    diagnosis TEXT, -- AI or expert diagnosis
    severity TEXT CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    image_url TEXT, -- Path to Supabase Storage
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Market Prices
CREATE TABLE IF NOT EXISTS public.market_prices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crop_type TEXT NOT NULL,
    region TEXT NOT NULL,
    price_per_kg NUMERIC NOT NULL,
    currency TEXT DEFAULT 'USD',
    source TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add comments for documentation
COMMENT ON TABLE public.profiles IS 'User profile data extending Supabase Auth.';
COMMENT ON TABLE public.farms IS 'Physical farm locations and metadata.';
COMMENT ON TABLE public.crops IS 'Specific crop instances within a farm.';
COMMENT ON TABLE public.health_logs IS 'AI-generated or manual observations of crop health.';
COMMENT ON TABLE public.market_prices IS 'Real-time or daily market price tracking for crops.';

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.farms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crops ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_prices ENABLE ROW LEVEL SECURITY;

-- Policies (Example: Users can see their own data)
CREATE POLICY "Users can view their own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Farmers can view their own farms" ON public.farms FOR SELECT USING (auth.uid() = owner_id);
