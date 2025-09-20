# RoomSpace Setup Guide

This guide will help you set up the RoomSpace MVP for development and testing.

## Prerequisites

### System Requirements
- **Node.js** 16.0+ and npm 8.0+
- **Xcode** 15.0+ (for iOS development)
- **iOS Device** with ARKit support (iPhone 6s or later)
- **Supabase** account
- **OpenAI** API access
- **Amazon Product Advertising API** access (optional for development)

### Hardware Requirements
- iOS device with A9 processor or later
- Device running iOS 12.0 or later
- Adequate lighting for AR scanning

## Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Environment Configuration

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` with your actual credentials:

```env
# Server Configuration
NODE_ENV=development
PORT=3000

# JWT Secret (generate a secure random string)
JWT_SECRET=your-secure-jwt-secret-key

# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key

# OpenAI API Configuration
OPENAI_API_KEY=sk-your-openai-api-key

# Amazon Product Advertising API (Optional)
AMAZON_ACCESS_KEY=your-access-key
AMAZON_SECRET_KEY=your-secret-key
AMAZON_PARTNER_TAG=your-partner-tag
AMAZON_REGION=us-east-1
```

### 3. Start the Development Server

```bash
npm run dev
```

The server will start on `http://localhost:3000`

### 4. Verify Backend Setup

Test the health endpoint:
```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "status": "OK",
  "timestamp": "2023-12-01T10:00:00.000Z",
  "version": "1.0.0"
}
```

## Database Setup (Supabase)

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note your project URL and API keys

### 2. Run Database Schema

1. Open Supabase SQL Editor
2. Copy the contents of `database/schema/001_initial_schema.sql`
3. Execute the SQL script

This will create:
- All necessary tables
- Row Level Security policies
- Database indexes
- UUID extensions

### 3. Verify Database Setup

Check that these tables were created:
- `users`
- `room_scans`
- `saved_designs`
- `product_catalog`
- `user_favorites`
- `design_shares`

## iOS App Setup

### 1. Prerequisites

- Xcode 15.0 or later
- iOS 16.0+ deployment target
- Apple Developer account (for device testing)

### 2. Open Project

```bash
cd ios
open RoomSpace.xcodeproj
```

### 3. Configure App Settings

In Xcode:
1. Select the RoomSpace target
2. Update the Bundle Identifier to your unique identifier
3. Select your Development Team
4. Ensure ARKit capability is enabled

### 4. Update API Endpoint

Edit `ios/RoomSpace/Services/APIService.swift`:

```swift
private let baseURL = "http://your-backend-url/api"
```

For local development:
```swift
private let baseURL = "http://localhost:3000/api"
```

For iOS Simulator, use your computer's IP:
```swift
private let baseURL = "http://192.168.1.100:3000/api"
```

### 5. Build and Run

1. Connect an iOS device (ARKit requires physical device)
2. Select your device as the build target
3. Build and run the app (⌘R)

## External Service Setup

### OpenAI API Setup

1. Go to [platform.openai.com](https://platform.openai.com)
2. Create an API key
3. Add the key to your backend `.env` file
4. Ensure you have sufficient API credits

### Amazon Product Advertising API (Optional)

For development, the app uses mock Amazon data. To enable real Amazon integration:

1. Apply for Amazon Associates Program
2. Get approved for Product Advertising API
3. Generate API credentials
4. Update backend `.env` file
5. Replace mock implementation in `backend/src/services/amazon.js`

### Google Sign-In (Optional)

To enable Google authentication:

1. Create a Google Cloud Console project
2. Enable Google+ API
3. Create OAuth 2.0 credentials
4. Add credentials to backend `.env`
5. Implement Google Sign-In in iOS app

### Apple Sign-In (Optional)

To enable Apple Sign-In:

1. Enable Sign In with Apple in your Apple Developer account
2. Configure your app identifier
3. Update backend to handle Apple tokens
4. Implement Sign In with Apple in iOS app

## Development Workflow

### Running the Full Stack

1. **Start Backend:**
   ```bash
   cd backend
   npm run dev
   ```

2. **Start iOS App:**
   - Open Xcode
   - Build and run on device

3. **Database Management:**
   - Use Supabase Dashboard for data inspection
   - SQL Editor for schema changes

### Testing Features

#### Test User Registration/Login
1. Launch iOS app
2. Create a test account
3. Verify JWT token storage
4. Test sign out/sign in flow

#### Test Room Scanning
1. Navigate to Scanner tab
2. Complete the setup flow
3. Use the mock AR scanning interface
4. Verify room data is saved

#### Test Design Generation
1. Create a room scan
2. Navigate to the room detail
3. Generate a design (uses OpenAI API)
4. View generated furniture recommendations

#### Test Product Search
1. Search for furniture items
2. View product details (mock Amazon data)
3. Save products to favorites

## Troubleshooting

### Common Issues

#### Backend Not Starting
- Check Node.js version: `node --version`
- Verify all environment variables are set
- Check for port conflicts

#### iOS Build Errors
- Clean build folder (⌘⇧K)
- Update Xcode and iOS deployment target
- Verify provisioning profiles

#### ARKit Not Working
- ARKit requires a physical device
- Ensure good lighting conditions
- Check camera permissions

#### Database Connection Issues
- Verify Supabase credentials
- Check internet connection
- Ensure RLS policies are correctly set

#### API Integration Issues
- Check API keys and quotas
- Verify network connectivity
- Review API documentation

### Debug Mode

Enable debug logging:

**Backend:**
```env
NODE_ENV=development
```

**iOS:**
Add debug prints in APIService for network requests

### Performance Optimization

For production deployment:

1. **Backend:**
   - Use PM2 for process management
   - Enable Redis for caching
   - Set up load balancing

2. **iOS:**
   - Optimize AR scanning performance
   - Implement image caching
   - Use background queues for API calls

3. **Database:**
   - Monitor query performance
   - Set up database backups
   - Configure connection pooling

## Next Steps

After successful setup:

1. **Customize Design Styles:** Add your own furniture catalogs and design preferences
2. **Enhance AR Experience:** Implement advanced ARKit features
3. **Add Analytics:** Track user behavior and app performance
4. **Deploy to Production:** Set up CI/CD pipeline and hosting
5. **App Store Submission:** Prepare for iOS App Store review

## Support

For setup issues or questions:
- Check the troubleshooting section above
- Review API documentation in `docs/API.md`
- Open an issue in the project repository