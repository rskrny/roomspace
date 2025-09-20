# RoomSpace Database Setup

This directory contains the database schema and migration files for the RoomSpace application using Supabase (PostgreSQL).

## Files

- `schema/001_initial_schema.sql` - Initial database schema with all tables and policies
- `migrations/` - Database migration files (to be added as the application evolves)

## Tables

### Core Tables

1. **users** - User profile information (extends Supabase auth)
2. **room_scans** - AR room scan data and metadata
3. **saved_designs** - AI-generated interior design layouts
4. **product_catalog** - Cached Amazon product information
5. **user_favorites** - User's saved/favorited products
6. **design_shares** - Design sharing functionality (future feature)

### Schema Overview

```
users (id, email, first_name, last_name, ...)
├── room_scans (user_id → users.id)
│   └── saved_designs (room_id → room_scans.id)
│       └── user_favorites (design_id → saved_designs.id)
└── user_favorites (user_id → users.id)

product_catalog (asin, title, price, ...)
└── user_favorites (product_asin → product_catalog.asin)
```

## Setup Instructions

### 1. Supabase Project Setup

1. Create a new project in [Supabase Dashboard](https://supabase.com/dashboard)
2. Note down your project URL and anon key
3. Go to SQL Editor in your Supabase dashboard

### 2. Run Initial Schema

Copy the contents of `schema/001_initial_schema.sql` and run it in the Supabase SQL Editor.

This will create:
- All necessary tables with proper relationships
- Indexes for optimal performance
- Row Level Security (RLS) policies for data protection
- UUID extensions for primary keys

### 3. Environment Variables

Update your backend `.env` file with your Supabase credentials:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key
```

### 4. Verify Setup

You can verify the setup by checking the tables in your Supabase dashboard under "Database" → "Tables".

## Security Features

- **Row Level Security (RLS)** enabled on all user-facing tables
- Users can only access their own data
- Product catalog is publicly readable for all authenticated users
- JWT-based authentication through Supabase Auth

## Data Types

### Room Dimensions (JSONB)
```json
{
  "width": 12.5,
  "length": 15.0,
  "height": 9.0
}
```

### Design Data (JSONB)
```json
{
  "layout": {
    "description": "Modern living room layout",
    "zones": [...]
  },
  "colorScheme": {
    "primary": "#2C3E50",
    "secondary": "#ECF0F1", 
    "accent": "#E74C3C"
  },
  "furnitureItems": [...],
  "totalCost": 2500.00
}
```

### Furniture Items (JSONB Array)
```json
[
  {
    "name": "Modern Sofa",
    "category": "Seating",
    "estimatedPrice": 899.99,
    "position": {"x": 0, "y": 0, "z": 0},
    "dimensions": {"width": 72, "depth": 36, "height": 32},
    "searchTerms": ["modern", "sofa", "sectional"]
  }
]
```

## Future Migrations

As the application evolves, add new migration files in the `migrations/` directory following the naming convention:
- `002_add_feature_x.sql`
- `003_update_table_y.sql`
- etc.

Each migration should be idempotent and include both UP and DOWN scripts when possible.