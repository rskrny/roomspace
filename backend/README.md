# RoomSpace Backend Setup & Deployment

## 🚀 Quick Start

### Automated Setup
Run the interactive setup script:
```bash
cd backend
npm install
npm run setup
npm run dev
```

### Manual Setup
1. Install dependencies:
```bash
npm install
```

2. Copy environment file:
```bash
cp .env.example .env
```

3. Edit `.env` with your configuration (see below)

4. Start development server:
```bash
npm run dev
```

## 📋 Environment Configuration

### Required for Production
- `JWT_SECRET` - Secure random string for JWT tokens
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `OPENAI_API_KEY` - OpenAI API key for design generation

### Optional Services
- `AMAZON_ACCESS_KEY` / `AMAZON_SECRET_KEY` - For real Amazon product integration
- `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` - For Google OAuth
- `APPLE_CLIENT_ID` / `APPLE_KEY_ID` / `APPLE_TEAM_ID` - For Apple Sign-In

## 🧪 Testing

Run all tests:
```bash
npm test
```

Run integration tests:
```bash
npm test -- tests/integration.test.js
```

## 🔧 Development Features

### Mock Mode
The backend automatically runs in mock mode when:
- `NODE_ENV=test`
- No Supabase URL configured
- Supabase URL contains placeholder values

In mock mode:
- ✅ Uses in-memory mock database
- ✅ Provides fallback design generation
- ✅ Returns mock Amazon product data
- ✅ All tests pass without external services

### Service Health Monitoring
Check service availability:
```bash
curl http://localhost:3000/api/health
```

Response includes availability of all external services.

## 📦 Production Deployment

### Environment Variables Check
The application validates required environment variables in production mode and will fail to start if any are missing.

### Database Setup
1. Create Supabase project
2. Run SQL schema from `../database/schema/001_initial_schema.sql`
3. Configure Row Level Security policies

### External API Setup
1. **OpenAI**: Get API key from https://platform.openai.com
2. **Amazon**: Apply for Product Advertising API access
3. **Google/Apple**: Set up OAuth applications

## 🔨 Available Scripts

- `npm start` - Production server
- `npm run dev` - Development server with auto-reload
- `npm test` - Run all tests
- `npm run lint` - Code linting
- `npm run lint:fix` - Fix linting issues
- `npm run setup` - Interactive environment setup

## 📁 Project Structure

```
backend/
├── src/
│   ├── config/         # Environment configuration
│   ├── middleware/     # Express middleware
│   ├── routes/         # API route handlers
│   ├── services/       # External service integrations
│   └── server.js       # Main application file
├── tests/              # Test files
├── setup.js            # Interactive setup script
└── package.json
```

## 🛠️ API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/google` - Google OAuth (configured)
- `POST /api/auth/apple` - Apple Sign-In (configured)

### Room Management
- `GET /api/rooms` - List user's rooms
- `POST /api/rooms` - Create room scan
- `GET /api/rooms/:id` - Get room details
- `PUT /api/rooms/:id` - Update room
- `DELETE /api/rooms/:id` - Delete room

### Design Generation
- `POST /api/designs/generate` - Generate design
- `GET /api/designs` - List user's designs
- `GET /api/designs/:id` - Get design details
- `PUT /api/designs/:id` - Update design
- `DELETE /api/designs/:id` - Delete design

### Product Search
- `GET /api/products/search` - Search products
- `POST /api/products/recommendations` - Get recommendations
- `GET /api/products/favorites` - List favorites
- `POST /api/products/favorites` - Add to favorites
- `DELETE /api/products/favorites/:asin` - Remove from favorites

### System
- `GET /api/health` - Health check & service status

## ⚡ Performance & Security

- ✅ Input validation with Joi
- ✅ JWT authentication
- ✅ CORS enabled
- ✅ Helmet security headers
- ✅ Error handling middleware
- ✅ Request rate limiting ready
- ✅ Environment-based configuration

## 🐛 Troubleshooting

### Tests Failing
- Make sure all dependencies are installed: `npm install`
- Environment issues are handled automatically in test mode

### Service Connection Issues
- Check service availability via `/api/health` endpoint
- Verify API keys in environment variables
- Fallback systems activate automatically for development

### Database Issues
- Supabase schema must be set up manually
- Check RLS policies are correctly configured
- Verify connection credentials

## 📞 Support

See the main project documentation in `/docs/` for:
- Complete API reference (`API.md`)
- Architecture overview (`ARCHITECTURE.md`)
- Full setup guide (`SETUP.md`)