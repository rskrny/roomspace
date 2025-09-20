# RoomSpace MVP

An AR-powered interior design app that lets users scan their rooms and get personalized furniture recommendations.

## Tech Stack
- **Frontend**: Swift/SwiftUI with ARKit for iOS
- **Backend**: Node.js with Express
- **Database**: Supabase (PostgreSQL)
- **AI Services**: OpenAI API for layout generation
- **Affiliate**: Amazon Product Advertising API

## Features
- Room scanning with ARKit
- AI-powered furniture recommendations
- Style & budget customization (4-5 core styles)
- AR preview of furniture placement
- Amazon affiliate product integration
- User profiles and saved designs

## Quick Start

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your API keys
npm run dev
```

### iOS Setup
1. Open `ios/` directory in Xcode
2. Build and run on iOS device or simulator
3. Requires iOS 16+ with ARKit support

### Database Setup
1. Create Supabase project
2. Run `database/schemas/initial_schema.sql`
3. Run `database/migrations/001_seed_data.sql`

## Project Structure
```
roomspace/
├── ios/                    # SwiftUI iOS app with ARKit
├── backend/               # Node.js Express API server  
├── docs/                  # Project documentation
├── database/              # Supabase schema & migrations
└── assets/                # Design assets & mockups
```

## Documentation
See [docs/README.md](docs/README.md) for detailed documentation including:
- [Setup Guide](docs/setup.md)
- [API Documentation](docs/api.md)
- Architecture overview and integrations

## Development Status
✅ Project structure created  
✅ Backend API foundation with Express  
✅ iOS SwiftUI app structure with ARKit integration  
✅ Database schema and migrations  
✅ Documentation structure  

**Next Steps:** Configure API keys, implement ARKit scanning, integrate AI recommendations