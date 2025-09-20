# RoomSpace MVP

An AR-powered interior design app that lets users scan their rooms and get personalized furniture recommendations using advanced AI and computer vision.

## 🎯 Overview

RoomSpace revolutionizes interior design by combining ARKit's powerful room scanning capabilities with OpenAI's intelligent layout generation. Users can scan their rooms in 3D, specify their style preferences and budget, and receive personalized furniture recommendations with real-time AR preview.

## 🛠 Tech Stack

### Frontend
- **Swift/SwiftUI** - Modern iOS app development
- **ARKit** - 3D room scanning and AR preview
- **RealityKit** - 3D rendering and physics
- **Combine** - Reactive programming

### Backend
- **Node.js + Express** - RESTful API server
- **JWT Authentication** - Secure user sessions
- **bcryptjs** - Password encryption

### Database & Services
- **Supabase (PostgreSQL)** - Real-time database with RLS
- **OpenAI API** - AI-powered layout generation
- **Amazon Product API** - Affiliate product integration

## ✨ Core Features

### 🏠 Room Scanning
- **ARKit Integration**: Real-time 3D room scanning
- **Automatic Detection**: Walls, floors, doors, and windows
- **Quality Assessment**: Scan completeness and accuracy scoring
- **3D Mesh Generation**: High-fidelity room reconstruction

### 🤖 AI-Powered Design
- **Style Selection**: Modern, Traditional, Scandinavian, Industrial, etc.
- **Budget Optimization**: Furniture recommendations within budget
- **Layout Generation**: Intelligent furniture placement and arrangement
- **Custom Preferences**: Personalized design based on user input

### 📱 AR Preview
- **Real-time Visualization**: See furniture in your actual room
- **Interactive Placement**: Move, rotate, and scale furniture
- **Lighting Simulation**: Realistic shadows and lighting
- **Multiple Designs**: Compare different layout options

### 🛒 Shopping Integration
- **Amazon Affiliate**: Curated furniture recommendations
- **Price Tracking**: Real-time pricing and availability
- **Product Details**: Specifications, reviews, and ratings
- **Direct Purchase**: Seamless buying experience

### 👤 User Experience
- **Secure Authentication**: Email/password + social login
- **Design Library**: Save and organize multiple designs
- **Favorites System**: Bookmark preferred products and layouts
- **Sharing**: Share designs with friends and family

## 📁 Project Structure

```
roomspace/
├── backend/                   # Node.js Express API
│   ├── server.js             # Main server configuration
│   ├── routes/               # API endpoints
│   │   ├── auth.js          # User authentication
│   │   ├── rooms.js         # Room management
│   │   ├── designs.js       # Design operations
│   │   ├── ai.js            # AI layout generation
│   │   └── products.js      # Amazon integration
│   ├── middleware/           # Express middleware
│   └── package.json          # Dependencies and scripts
├── ios/                      # SwiftUI iOS Application
│   └── RoomSpace/           # Main iOS project
│       ├── Models/          # Data models and structures
│       ├── Views/           # SwiftUI user interface
│       ├── ViewModels/      # Business logic managers
│       ├── Services/        # API and external services
│       ├── AR/              # ARKit integration
│       └── Utils/           # Helper utilities
├── database/                # Database schema and migrations
│   ├── schemas/             # SQL table definitions
│   └── migrations/          # Database version control
├── docs/                    # Comprehensive documentation
│   ├── README.md           # Technical documentation
│   └── dependencies.md     # Detailed dependency info
└── assets/                  # Design assets and mockups
    ├── icons/              # App and UI icons
    └── mockups/            # Design wireframes
```

## 🚀 Quick Start

### Prerequisites
- **Node.js 16+** - JavaScript runtime
- **iOS device with A12+** - ARKit requirements
- **Xcode 15+** - iOS development environment
- **Supabase account** - Database and authentication
- **OpenAI API key** - AI layout generation

### 1. Backend Setup
```bash
cd backend/
npm install
cp .env.example .env
# Configure your API keys in .env
npm run dev
```

### 2. Database Setup
```sql
-- Run the schema from database/schemas/roomspace_schema.sql
-- in your Supabase SQL editor
```

### 3. iOS Setup
```bash
open ios/RoomSpace.xcodeproj
# Configure signing, bundle ID, and API endpoint
# Build and run on physical device (ARKit requirement)
```

## 🔧 Configuration

### Environment Variables
```env
NODE_ENV=development
PORT=3000
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
JWT_SECRET=your-secure-secret
OPENAI_API_KEY=sk-your-openai-key
AMAZON_ASSOCIATE_TAG=your-amazon-tag
```

### iOS Configuration
- Update API base URL in `APIService.swift`
- Configure app bundle identifier
- Enable ARKit and Camera capabilities
- Set up proper signing certificates

## 📊 API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User authentication  
- `GET /api/auth/profile` - Get user profile

### Room Management
- `GET /api/rooms` - List user's scanned rooms
- `POST /api/rooms` - Save new room scan
- `PUT /api/rooms/:id` - Update room details

### AI Design Generation
- `POST /api/ai/generate-layout` - Generate furniture layout
- `GET /api/ai/styles/:roomType` - Get style recommendations

### Product Integration
- `GET /api/products/search` - Search furniture products
- `GET /api/products/recommendations/:designId` - Get recommendations
- `POST /api/products/track-click` - Track affiliate clicks

## 🔒 Security Features

- **JWT Authentication** - Secure API access
- **Row Level Security** - Database access control
- **Password Encryption** - bcrypt hashing
- **Input Validation** - SQL injection prevention
- **Keychain Storage** - iOS credential security

## 🎨 Design Philosophy

- **User-Centric** - Intuitive and accessible interface
- **AR-First** - Leveraging cutting-edge AR technology
- **AI-Enhanced** - Intelligent recommendations and automation
- **Performance-Optimized** - Smooth 60fps AR experience
- **Privacy-Focused** - Secure data handling and storage

## 📈 Future Enhancements

- **Multi-room Support** - Design entire homes
- **3D Model Library** - Expanded furniture catalog
- **Collaboration Features** - Share and co-design spaces
- **Professional Tools** - Advanced design capabilities
- **Web App** - Cross-platform accessibility

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make changes and test thoroughly
4. Commit changes: `git commit -m 'Add amazing feature'`
5. Push to branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

## 📝 Documentation

- **[Setup Guide](SETUP.md)** - Detailed setup instructions
- **[Technical Docs](docs/README.md)** - Architecture and APIs
- **[Dependencies](docs/dependencies.md)** - Package information

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Documentation**: [/docs](docs/)
- **API Reference**: See individual route files
- **Issue Tracker**: GitHub Issues
- **Discussions**: GitHub Discussions

---

Built with ❤️ using ARKit, SwiftUI, and OpenAI