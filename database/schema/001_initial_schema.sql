-- RoomSpace Database Schema for Supabase

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE
);

-- Room scans table
CREATE TABLE room_scans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    room_type VARCHAR(50) NOT NULL CHECK (room_type IN ('living_room', 'bedroom', 'kitchen', 'dining_room', 'office', 'other')),
    dimensions JSONB NOT NULL, -- {width: number, length: number, height: number}
    scan_data TEXT NOT NULL, -- Base64 encoded ARKit scan data
    budget_min DECIMAL(10, 2) NOT NULL DEFAULT 0,
    budget_max DECIMAL(10, 2) NOT NULL,
    style VARCHAR(50) NOT NULL CHECK (style IN ('modern', 'minimalist', 'scandinavian', 'industrial', 'bohemian')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Saved designs table
CREATE TABLE saved_designs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES room_scans(id) ON DELETE CASCADE,
    style VARCHAR(50) NOT NULL,
    budget_min DECIMAL(10, 2) NOT NULL DEFAULT 0,
    budget_max DECIMAL(10, 2) NOT NULL,
    design_data JSONB NOT NULL, -- AI generated layout and design information
    furniture_items JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of furniture items with positions
    total_cost DECIMAL(10, 2) DEFAULT 0,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Product catalog table (for caching Amazon products)
CREATE TABLE product_catalog (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asin VARCHAR(20) UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    category VARCHAR(100),
    price_amount DECIMAL(10, 2),
    price_currency VARCHAR(5) DEFAULT 'USD',
    images JSONB, -- URLs for product images
    rating DECIMAL(3, 2),
    review_count INTEGER DEFAULT 0,
    features JSONB, -- Array of product features
    availability VARCHAR(50),
    affiliate_url TEXT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User favorites table
CREATE TABLE user_favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_asin VARCHAR(20) NOT NULL REFERENCES product_catalog(asin),
    design_id UUID REFERENCES saved_designs(id) ON DELETE SET NULL,
    product_title TEXT NOT NULL,
    product_price DECIMAL(10, 2),
    product_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_asin)
);

-- Design sharing table (for future feature)
CREATE TABLE design_shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id UUID NOT NULL REFERENCES saved_designs(id) ON DELETE CASCADE,
    shared_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    share_token VARCHAR(255) UNIQUE NOT NULL,
    is_public BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_room_scans_user_id ON room_scans(user_id);
CREATE INDEX idx_room_scans_created_at ON room_scans(created_at DESC);
CREATE INDEX idx_room_scans_room_type ON room_scans(room_type);

CREATE INDEX idx_saved_designs_user_id ON saved_designs(user_id);
CREATE INDEX idx_saved_designs_room_id ON saved_designs(room_id);
CREATE INDEX idx_saved_designs_created_at ON saved_designs(created_at DESC);
CREATE INDEX idx_saved_designs_style ON saved_designs(style);

CREATE INDEX idx_product_catalog_asin ON product_catalog(asin);
CREATE INDEX idx_product_catalog_category ON product_catalog(category);
CREATE INDEX idx_product_catalog_price ON product_catalog(price_amount);

CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_created_at ON user_favorites(created_at DESC);

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_scans ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_designs ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- Users can only see and update their own data
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

-- Room scans policies
CREATE POLICY "Users can view own room scans" ON room_scans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own room scans" ON room_scans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own room scans" ON room_scans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own room scans" ON room_scans FOR DELETE USING (auth.uid() = user_id);

-- Saved designs policies
CREATE POLICY "Users can view own designs" ON saved_designs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own designs" ON saved_designs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own designs" ON saved_designs FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own designs" ON saved_designs FOR DELETE USING (auth.uid() = user_id);

-- User favorites policies
CREATE POLICY "Users can view own favorites" ON user_favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own favorites" ON user_favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON user_favorites FOR DELETE USING (auth.uid() = user_id);

-- Product catalog is publicly readable
CREATE POLICY "Product catalog is publicly readable" ON product_catalog FOR SELECT TO public USING (true);