-- RoomSpace Database Schema
-- This file contains the complete database schema for the RoomSpace application

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table for authentication and profiles
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    preferences JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Rooms table for storing scanned room data
CREATE TABLE rooms (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    room_type VARCHAR(50) NOT NULL DEFAULT 'living_room', -- living_room, bedroom, kitchen, etc.
    dimensions JSONB NOT NULL, -- {width: number, height: number, depth: number}
    scan_data JSONB NOT NULL, -- ARKit scan data, walls, windows, doors, etc.
    image_url TEXT, -- Preview image of the room scan
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Designs table for AI-generated and custom layouts
CREATE TABLE designs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    style VARCHAR(50) NOT NULL, -- modern, traditional, minimalist, etc.
    budget DECIMAL(10,2) NOT NULL,
    ai_response JSONB NOT NULL, -- Full AI layout response
    custom_layout JSONB, -- User modifications to AI layout
    preferences TEXT, -- Additional user preferences
    notes TEXT, -- User notes about the design
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Furniture items table for storing individual furniture pieces
CREATE TABLE furniture_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL, -- seating, tables, storage, lighting, etc.
    position JSONB NOT NULL, -- {x: number, y: number, z: number}
    rotation DECIMAL(5,2) DEFAULT 0,
    dimensions JSONB NOT NULL, -- {width: number, height: number, depth: number}
    color VARCHAR(50),
    material VARCHAR(100),
    estimated_cost DECIMAL(8,2),
    product_id VARCHAR(255), -- Amazon ASIN or product identifier
    is_placed BOOLEAN DEFAULT FALSE, -- Whether user has placed in AR
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Product wishlist/favorites
CREATE TABLE user_favorites (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id VARCHAR(255) NOT NULL, -- Amazon ASIN
    product_data JSONB NOT NULL, -- Cached product information
    added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

-- Design sharing and collaboration
CREATE TABLE design_shares (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,
    shared_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    shared_with_email VARCHAR(255),
    access_level VARCHAR(20) DEFAULT 'view', -- view, comment, edit
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics and usage tracking
CREATE TABLE user_activities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL, -- scan_room, generate_design, view_product, etc.
    activity_data JSONB DEFAULT '{}',
    session_id VARCHAR(255),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Affiliate click tracking
CREATE TABLE affiliate_clicks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    product_id VARCHAR(255) NOT NULL,
    design_id UUID REFERENCES designs(id) ON DELETE SET NULL,
    click_source VARCHAR(50), -- design_view, search_results, recommendations
    session_id VARCHAR(255),
    ip_address INET,
    converted BOOLEAN DEFAULT FALSE,
    conversion_value DECIMAL(8,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_rooms_user_id ON rooms(user_id);
CREATE INDEX idx_rooms_created_at ON rooms(created_at DESC);
CREATE INDEX idx_designs_user_id ON designs(user_id);
CREATE INDEX idx_designs_room_id ON designs(room_id);
CREATE INDEX idx_designs_created_at ON designs(created_at DESC);
CREATE INDEX idx_designs_is_favorite ON designs(is_favorite) WHERE is_favorite = TRUE;
CREATE INDEX idx_furniture_items_design_id ON furniture_items(design_id);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_created_at ON user_activities(created_at DESC);
CREATE INDEX idx_affiliate_clicks_user_id ON affiliate_clicks(user_id);
CREATE INDEX idx_affiliate_clicks_created_at ON affiliate_clicks(created_at DESC);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE designs ENABLE ROW LEVEL SECURITY;
ALTER TABLE furniture_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE design_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own rooms" ON rooms
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view own designs" ON designs
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view furniture items in own designs" ON furniture_items
    FOR ALL USING (auth.uid() IN (
        SELECT user_id FROM designs WHERE id = furniture_items.design_id
    ));

CREATE POLICY "Users can manage own favorites" ON user_favorites
    FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "Users can view shared designs" ON design_shares
    FOR SELECT USING (
        auth.uid() = shared_by OR 
        auth.email() = shared_with_email
    );

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for updated_at columns
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rooms_updated_at BEFORE UPDATE ON rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_designs_updated_at BEFORE UPDATE ON designs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_furniture_items_updated_at BEFORE UPDATE ON furniture_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();