# RoomSpace Setup Guide

## Quick Start

### Prerequisites
- Node.js 16+ 
- iOS device with A12 chip or later
- Xcode 15+
- Supabase account
- OpenAI API key
- Amazon Associate account

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd backend/
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your actual values
   ```

4. **Start development server**
   ```bash
   npm run dev
   ```

### iOS Setup

1. **Open Xcode project**
   ```bash
   open ios/RoomSpace.xcodeproj
   ```

2. **Configure project**
   - Update bundle identifier
   - Configure signing & capabilities
   - Ensure ARKit capability is enabled

3. **Update API endpoint**
   - Edit `APIService.swift`
   - Update `baseURL` to your backend server

4. **Build and run on device**
   - ARKit requires physical device
   - Simulator will not work for scanning

### Database Setup

1. **Create Supabase project**
   - Go to https://supabase.com
   - Create new project

2. **Run database schema**
   ```sql
   -- Copy and paste content from database/schemas/roomspace_schema.sql
   -- into Supabase SQL editor
   ```

3. **Configure RLS policies**
   - Policies are included in schema file
   - Adjust as needed for your use case

## Environment Variables

Create `.env` file in backend directory:

```env
NODE_ENV=development
PORT=3000
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
JWT_SECRET=your-very-secure-secret-key
OPENAI_API_KEY=sk-your-openai-key
AMAZON_ASSOCIATE_TAG=your-amazon-tag
```

## Testing the Setup

1. **Backend health check**
   ```bash
   curl http://localhost:3000/health
   ```

2. **iOS app**
   - Build and run on device
   - Check camera permissions
   - Test user registration

## Troubleshooting

### Common Issues

1. **ARKit not working**
   - Ensure running on physical device
   - Check camera permissions
   - Verify A12 chip or later

2. **API connection failed**
   - Check backend server is running
   - Verify network connectivity
   - Update API base URL in iOS app

3. **Database errors**
   - Verify Supabase configuration
   - Check API keys and URL
   - Ensure schema is properly applied

## Next Steps

1. Configure real API keys for production
2. Set up proper error logging and monitoring
3. Implement push notifications
4. Add comprehensive testing
5. Set up CI/CD pipeline

## Support

- Review documentation in `docs/` folder
- Check GitHub issues
- Refer to API documentation