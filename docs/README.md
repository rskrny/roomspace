# RoomSpace Project Documentation

## Project Overview
RoomSpace is an AR-powered interior design application that helps users scan their rooms and get personalized furniture recommendations using AI.

## Architecture

### Backend Architecture
- **Framework**: Node.js with Express
- **Database**: Supabase (PostgreSQL)
- **Authentication**: JWT tokens with bcrypt password hashing
- **AI Integration**: OpenAI API for layout generation
- **Affiliate Program**: Amazon Product Advertising API

### iOS App Architecture
- **Framework**: SwiftUI with UIKit integration
- **AR Framework**: ARKit with RealityKit
- **Architecture Pattern**: MVVM with ObservableObject
- **Data Management**: Combine framework for reactive programming
- **Security**: Keychain Services for token storage

## Project Structure

```
roomspace/
├── backend/               # Node.js Express API server
│   ├── server.js         # Main server file
│   ├── routes/           # API route handlers
│   │   ├── auth.js       # Authentication endpoints
│   │   ├── rooms.js      # Room management endpoints
│   │   ├── designs.js    # Design management endpoints
│   │   ├── ai.js         # AI layout generation
│   │   └── products.js   # Amazon affiliate integration
│   ├── middleware/       # Express middleware
│   │   └── auth.js       # JWT authentication middleware
│   ├── config/           # Configuration files
│   └── package.json      # Dependencies and scripts
├── ios/                  # SwiftUI iOS application
│   └── RoomSpace/        # Main iOS project
│       ├── Models/       # Data models
│       ├── Views/        # SwiftUI views
│       ├── ViewModels/   # Business logic managers
│       ├── Services/     # API and external services
│       ├── AR/           # ARKit integration
│       └── Utils/        # Helper utilities
├── database/             # Supabase database schema
│   ├── schemas/          # SQL schema definitions
│   └── migrations/       # Database migrations
├── docs/                 # Project documentation
└── assets/              # Design assets and mockups
```

## Core Features

### 1. User Authentication
- Email/password registration and login
- JWT-based authentication
- Social login support (Apple, Google) - placeholder implementation
- Secure token storage in iOS Keychain

### 2. Room Scanning with ARKit
- Real-time room scanning using ARKit
- Automatic wall, floor, door, and window detection
- 3D mesh generation and processing
- Scan quality assessment and feedback

### 3. AI-Powered Layout Generation
- Integration with OpenAI API for intelligent furniture placement
- Style-based recommendations (Modern, Traditional, Scandinavian, etc.)
- Budget-conscious furniture selection
- Customizable user preferences

### 4. AR Preview
- Real-time furniture placement preview in AR
- Interactive furniture positioning and rotation
- Scale-accurate 3D models
- Lighting and shadow simulation

### 5. Amazon Affiliate Integration
- Product search and recommendations
- Real-time pricing and availability
- Affiliate link tracking and analytics
- Product detail views with specifications

### 6. Design Management
- Save and organize multiple room designs
- Favorite designs system
- Design sharing capabilities
- Custom layout modifications

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile
- `PUT /api/auth/profile` - Update user profile

### Room Management
- `GET /api/rooms` - Get user's rooms
- `POST /api/rooms` - Create new room from scan
- `GET /api/rooms/:id` - Get specific room
- `PUT /api/rooms/:id` - Update room details
- `DELETE /api/rooms/:id` - Delete room

### Design Generation
- `POST /api/ai/generate-layout` - Generate AI layout
- `GET /api/ai/styles/:roomType` - Get style recommendations
- `GET /api/designs` - Get user's designs
- `GET /api/designs/:id` - Get specific design
- `PUT /api/designs/:id` - Update design
- `GET /api/designs/favorites/list` - Get favorite designs

### Product Integration
- `GET /api/products/search` - Search products
- `GET /api/products/:id` - Get product details
- `GET /api/products/recommendations/:designId` - Get recommendations
- `POST /api/products/track-click` - Track affiliate clicks

## Database Schema

### Core Tables
- `users` - User accounts and profiles
- `rooms` - Scanned room data and metadata
- `designs` - AI-generated and custom layouts
- `furniture_items` - Individual furniture pieces
- `user_favorites` - User's favorite products
- `affiliate_clicks` - Tracking for affiliate program

### Security Features
- Row Level Security (RLS) enabled
- JWT token validation
- Input sanitization and validation
- Rate limiting (to be implemented)

## Development Setup

### Backend Setup
1. Install Node.js (16+)
2. Navigate to `backend/` directory
3. Install dependencies: `npm install`
4. Copy `.env.example` to `.env` and configure
5. Start development server: `npm run dev`

### iOS Setup
1. Open `ios/RoomSpace.xcodeproj` in Xcode
2. Ensure iOS 16+ deployment target
3. Enable ARKit capability
4. Configure signing and capabilities
5. Build and run on device (ARKit requires physical device)

### Database Setup
1. Create Supabase project
2. Run schema from `database/schemas/roomspace_schema.sql`
3. Configure environment variables
4. Enable Row Level Security policies

## Configuration

### Environment Variables
```bash
# Backend (.env)
NODE_ENV=development
PORT=3000
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
JWT_SECRET=your-jwt-secret
OPENAI_API_KEY=your-openai-api-key
AMAZON_ASSOCIATE_TAG=your-amazon-tag
```

### iOS Configuration
- Update API base URL in `APIService.swift`
- Configure app bundle identifier
- Set up signing certificates
- Enable ARKit capability

## Deployment

### Backend Deployment
- Deploy to services like Railway, Render, or Heroku
- Set up environment variables
- Configure CORS for production domains
- Set up monitoring and logging

### iOS Deployment
- Archive and distribute through TestFlight
- Submit to App Store Connect
- Configure App Store metadata
- Set up crash reporting and analytics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the coding standards
4. Test thoroughly on both backend and iOS
5. Submit a pull request with detailed description

## Support

For technical support or questions:
- Create an issue on GitHub
- Check documentation in the `docs/` folder
- Review API documentation and examples