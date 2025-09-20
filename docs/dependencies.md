# Backend Dependencies and Packages

## Node.js Backend

### Production Dependencies

#### Core Framework
- **express** (^5.1.0) - Fast, unopinionated web framework for Node.js
- **cors** (^2.8.5) - Enable Cross-Origin Resource Sharing
- **helmet** (^8.1.0) - Security middleware for Express apps
- **morgan** (^1.10.1) - HTTP request logger middleware
- **dotenv** (^17.2.2) - Load environment variables from .env file

#### Authentication & Security
- **bcryptjs** (^3.0.2) - Password hashing library
- **jsonwebtoken** (^9.0.2) - JSON Web Token implementation

#### Database & APIs
- **@supabase/supabase-js** (^2.57.4) - Supabase JavaScript client
- **openai** (^5.22.0) - OpenAI API client library

### Development Dependencies
- **nodemon** (^3.1.10) - Monitor for changes and automatically restart server

### Scripts
- `npm start` - Start production server
- `npm run dev` - Start development server with hot reload
- `npm test` - Run tests (placeholder)

### Package Manager
Using npm with package-lock.json for deterministic builds.

### Node.js Version
Requires Node.js 16.0.0 or higher for optimal compatibility.

## iOS App Dependencies

### iOS Platform
- **Minimum iOS Version**: 16.0
- **Xcode Version**: 15.0+
- **Swift Version**: 5.0

### Apple Frameworks
- **SwiftUI** - Declarative UI framework
- **UIKit** - Legacy UI components integration
- **ARKit** - Augmented Reality framework
- **RealityKit** - 3D rendering and AR experiences
- **Combine** - Reactive programming framework
- **Foundation** - Core system services
- **Security** - Keychain and cryptographic services

### Third-Party Dependencies (Future)
Placeholder for potential future dependencies:
- **Alamofire** - HTTP networking library
- **SDWebImageSwiftUI** - Async image loading
- **Firebase** - Analytics and crash reporting

### Device Requirements
- **ARKit Support**: Requires A12 Bionic chip or later
- **Camera Access**: Required for room scanning
- **Storage**: Minimum 1GB available space

### Capabilities Required
- **Camera** - Room scanning and AR preview
- **ARKit** - 3D world tracking and scene reconstruction
- **Network** - API communication
- **Keychain** - Secure credential storage

## Development Tools

### Backend Development
- **Node.js** - JavaScript runtime
- **npm** - Package manager
- **Postman/Insomnia** - API testing
- **PostgreSQL** - Database (via Supabase)

### iOS Development
- **Xcode** - IDE and build tools
- **iOS Simulator** - Testing environment
- **Physical iOS Device** - Required for ARKit testing

### Database
- **Supabase** - Backend-as-a-Service
- **PostgreSQL** - Relational database
- **Supabase Studio** - Database management interface

### External Services
- **OpenAI API** - AI layout generation
- **Amazon Product Advertising API** - Product data and affiliate links
- **Apple Developer Program** - iOS app distribution