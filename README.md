# RoomSpace MVP

An AR-powered interior design app that lets users scan their rooms and get personalized furniture recommendations.

## 🚀 Features

- **AR Room Scanning**: Use ARKit to capture accurate room dimensions and geometry
- **AI-Powered Design**: OpenAI integration generates personalized furniture layouts
- **Style Customization**: Choose from 5 design styles (Modern, Minimalist, Scandinavian, Industrial, Bohemian)
- **Budget Management**: Set price ranges for realistic furniture recommendations
- **Product Integration**: Search and discover furniture through Amazon affiliate links
- **3D Visualization**: Preview furniture placement in AR before purchasing
- **User Profiles**: Save designs, favorite products, and track room history

## 🛠 Tech Stack

- **Frontend**: Swift/SwiftUI with ARKit for iOS 16+
- **Backend**: Node.js with Express.js REST API
- **Database**: Supabase (PostgreSQL) with Row Level Security
- **AI Services**: OpenAI GPT-4 for intelligent design generation
- **E-commerce**: Amazon Product Advertising API integration
- **Authentication**: JWT tokens with Keychain storage

## 📱 Core User Flow

```
Scan Room → Select Style → AI Generation → AR Preview → Shop Products
```

1. **Room Scanning**: Point camera at room, walk around to capture dimensions
2. **Style Selection**: Choose preferred design aesthetic and budget range  
3. **AI Generation**: Get personalized furniture layout and product recommendations
4. **AR Preview**: Visualize furniture placement in your actual space
5. **Product Shopping**: Browse and purchase recommended furniture items

## 🏗 Project Structure

```
roomspace/
├── ios/                    # SwiftUI iOS app
│   ├── RoomSpace/         
│   │   ├── Views/         # SwiftUI views and screens
│   │   ├── Models/        # Data models and structures
│   │   ├── Services/      # API, Auth, and Room services  
│   │   └── Utils/         # Helper utilities
│   └── RoomSpace.xcodeproj
├── backend/               # Node.js API server
│   ├── src/
│   │   ├── routes/        # API endpoint definitions
│   │   ├── services/      # External service integrations
│   │   ├── middleware/    # Authentication and validation
│   │   └── server.js      # Express app configuration
│   └── package.json
├── database/              # Supabase schema & migrations
│   ├── schema/           # SQL schema definitions
│   └── README.md         # Database setup guide
├── docs/                  # Project documentation
│   ├── API.md            # Complete API reference
│   ├── SETUP.md          # Development setup guide
│   └── ARCHITECTURE.md   # Technical architecture
└── assets/                # Design assets & mockups
```

## 🚦 Quick Start

### Prerequisites
- Node.js 16+ and npm 8+
- Xcode 15+ with iOS 16+ deployment target
- iOS device with ARKit support (iPhone 6s+)
- Supabase account
- OpenAI API key

### 1. Clone Repository
```bash
git clone https://github.com/your-username/roomspace.git
cd roomspace
```

### 2. Setup Backend
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your API keys and database credentials
npm run dev
```

### 3. Setup Database
1. Create a new Supabase project
2. Run the SQL schema from `database/schema/001_initial_schema.sql`
3. Update backend `.env` with Supabase credentials

### 4. Setup iOS App
```bash
cd ios
open RoomSpace.xcodeproj
# Update APIService.swift with your backend URL
# Build and run on iOS device (ARKit requires physical device)
```

## 📖 Documentation

- **[Setup Guide](docs/SETUP.md)** - Complete development environment setup
- **[API Reference](docs/API.md)** - Full REST API documentation
- **[Architecture](docs/ARCHITECTURE.md)** - Technical architecture and design decisions
- **[Database Schema](database/README.md)** - Database structure and relationships

## 🔑 Environment Variables

### Backend (.env)
```env
NODE_ENV=development
PORT=3000
JWT_SECRET=your-jwt-secret
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
OPENAI_API_KEY=your-openai-api-key
AMAZON_ACCESS_KEY=your-amazon-access-key
AMAZON_SECRET_KEY=your-amazon-secret-key
```

## 🧪 Testing

### Backend API Testing
```bash
cd backend
npm test                    # Run test suite
npm run lint               # Check code quality
curl localhost:3000/api/health  # Test server
```

### iOS App Testing
- Use Xcode's built-in testing tools
- Test on physical iOS device for AR functionality
- Verify API integration in network inspector

## 🗄 Database Schema

Key tables:
- **users** - User accounts and profiles
- **room_scans** - AR-captured room data and metadata
- **saved_designs** - AI-generated interior design layouts  
- **product_catalog** - Cached furniture product information
- **user_favorites** - User's saved products and designs

All tables include Row Level Security (RLS) for data protection.

## 🔐 Security Features

- JWT-based authentication with 7-day token expiration
- Keychain storage for sensitive data on iOS
- Row Level Security policies in Supabase
- HTTPS/TLS encryption for all API communication
- Input validation and sanitization on all endpoints

## 🌟 Future Enhancements

- Social sharing and design collaboration
- Advanced AR features (occlusion, lighting)
- Multi-room projects and floor plans  
- Real-time collaborative design sessions
- Machine learning for improved recommendations
- Integration with additional furniture retailers

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For setup issues or questions:
- Check the [Setup Guide](docs/SETUP.md)
- Review [API Documentation](docs/API.md)
- Open an issue on GitHub

## 🙏 Acknowledgments

- ARKit for advanced spatial computing capabilities
- OpenAI for intelligent design generation
- Supabase for backend-as-a-service platform
- Amazon for product catalog and affiliate program