# RoomSpace Architecture

This document outlines the technical architecture of the RoomSpace MVP application.

## System Overview

RoomSpace is built as a modern mobile-first application with the following key components:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   iOS App       │◄───┤   Backend API   │◄───┤   Supabase DB   │
│   (SwiftUI)     │    │   (Node.js)     │    │   (PostgreSQL)  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   ARKit         │    │   OpenAI API    │    │   Row Level     │
│   (Room Scan)   │    │   (AI Design)   │    │   Security      │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────┐
                    │                 │
                    │   Amazon API    │
                    │   (Products)    │
                    │                 │
                    └─────────────────┘
```

## Technology Stack

### Frontend (iOS)
- **Framework:** SwiftUI
- **AR Technology:** ARKit
- **Networking:** URLSession with custom APIService
- **Architecture:** MVVM with ObservableObject
- **Authentication:** JWT with Keychain storage
- **Minimum iOS:** 16.0

### Backend (API Server)
- **Runtime:** Node.js 16+
- **Framework:** Express.js
- **Authentication:** JWT (jsonwebtoken)
- **Validation:** Joi
- **Security:** Helmet, CORS
- **Environment:** dotenv

### Database
- **Provider:** Supabase (PostgreSQL)
- **Security:** Row Level Security (RLS)
- **Authentication:** Supabase Auth integration
- **Storage:** Structured JSON for complex data

### External Services
- **AI:** OpenAI GPT-4 for design generation
- **E-commerce:** Amazon Product Advertising API
- **Social Auth:** Google OAuth, Apple Sign In (planned)

## Application Architecture

### iOS App Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App                              │
├─────────────────────────────────────────────────────────────┤
│                        Views                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │ Auth View   │ │  Home View  │ │ Scanner View│  ...     │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                     Services                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Auth      │ │  API Svc    │ │  Room Svc   │  ...     │
│  │  Service    │ │             │ │             │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                      Models                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    User     │ │ Room Scan   │ │   Design    │  ...     │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                   Core Frameworks                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   SwiftUI   │ │    ARKit    │ │  Foundation │  ...     │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

### Backend Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Backend API                              │
├─────────────────────────────────────────────────────────────┤
│                      Routes                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    Auth     │ │   Rooms     │ │  Designs    │  ...     │
│  │   Routes    │ │   Routes    │ │   Routes    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                   Middleware                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │    Auth     │ │ Validation  │ │   Error     │  ...     │
│  │ Middleware  │ │             │ │  Handler    │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                    Services                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │  Supabase   │ │   OpenAI    │ │   Amazon    │  ...     │
│  │   Service   │ │   Service   │ │   Service   │          │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
├─────────────────────────────────────────────────────────────┤
│                 Core Frameworks                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐          │
│  │   Express   │ │   Node.js   │ │    NPM      │  ...     │
│  └─────────────┘ └─────────────┘ └─────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Data Architecture

### Database Schema

```sql
-- Core Tables
users (
  id UUID PRIMARY KEY,
  email VARCHAR UNIQUE,
  password_hash VARCHAR,
  first_name VARCHAR,
  last_name VARCHAR,
  created_at TIMESTAMP
)

room_scans (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  name VARCHAR,
  room_type VARCHAR,
  dimensions JSONB,
  scan_data TEXT,
  budget_min DECIMAL,
  budget_max DECIMAL,
  style VARCHAR,
  created_at TIMESTAMP
)

saved_designs (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  room_id UUID REFERENCES room_scans(id),
  design_data JSONB,
  furniture_items JSONB,
  total_cost DECIMAL,
  created_at TIMESTAMP
)

product_catalog (
  id UUID PRIMARY KEY,
  asin VARCHAR UNIQUE,
  title TEXT,
  price_amount DECIMAL,
  images JSONB,
  created_at TIMESTAMP
)
```

### Data Flow

```
User Action → iOS App → API Request → Backend Validation → Database Query → External API → Response Processing → iOS App Update
```

#### Example: Room Scanning Flow

1. **User starts AR scan** → iOS ARKit captures room geometry
2. **Scan completion** → iOS processes ARKit data, converts to base64
3. **API request** → POST /rooms with scan data and metadata
4. **Backend validation** → Joi validates request structure
5. **Authentication** → JWT middleware verifies user identity
6. **Database storage** → Supabase stores room scan with RLS
7. **Response** → Return room object with generated UUID
8. **UI update** → iOS updates room list and navigation

## Security Architecture

### Authentication & Authorization

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   iOS Keychain  │────┤   JWT Token     │────┤   Backend Auth  │
│   (Secure)      │    │   (Stateless)   │    │   Middleware    │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────┐
                    │                 │
                    │   Supabase RLS  │
                    │   (Row Level)   │
                    │                 │
                    └─────────────────┘
```

### Data Protection

- **In Transit:** HTTPS/TLS encryption
- **At Rest:** Supabase encryption
- **Authentication:** JWT with 7-day expiration
- **Authorization:** Row Level Security policies
- **API Keys:** Environment variables only
- **Sensitive Data:** Keychain storage on iOS

## API Architecture

### RESTful Design

```
GET    /api/rooms           # List user's rooms
POST   /api/rooms           # Create new room scan
GET    /api/rooms/:id       # Get specific room
PUT    /api/rooms/:id       # Update room
DELETE /api/rooms/:id       # Delete room

POST   /api/designs/generate # Generate AI design
GET    /api/designs         # List user's designs
GET    /api/designs/:id     # Get specific design

GET    /api/products/search # Search furniture products
POST   /api/products/favorites # Save to favorites
```

### Error Handling

```javascript
// Standardized error responses
{
  "message": "Human readable error",
  "details": "Specific validation error", // optional
  "code": "ERROR_CODE",                   // optional
  "timestamp": "2023-12-01T10:00:00Z"
}
```

## AR Architecture

### ARKit Integration

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   ARKit         │────┤   Room Mesh     │────┤   3D Models     │
│   Session       │    │   Generation    │    │   Placement     │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│                 │    │                 │    │                 │
│   Camera Feed   │    │   Spatial Map   │    │   Furniture     │
│   Processing    │    │   Storage       │    │   Visualization │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### AR Data Pipeline

1. **Scene Understanding:** ARKit world tracking and plane detection
2. **Geometry Capture:** Room boundaries and spatial mapping
3. **Data Serialization:** Convert ARKit data to transferable format
4. **Cloud Processing:** AI analysis of room dimensions and features
5. **Furniture Placement:** 3D model positioning based on AI recommendations
6. **Real-time Rendering:** AR overlay with furniture previews

## Scalability Considerations

### Current MVP Limitations
- Single-threaded backend processing
- No caching layer
- Direct database queries
- Mock Amazon API integration

### Future Scaling Plans
- **Microservices:** Split services (Auth, Rooms, Designs, Products)
- **Caching:** Redis for API responses and user sessions
- **CDN:** CloudFront for 3D model and image delivery
- **Queue System:** Background processing for AI generation
- **Database:** Read replicas and connection pooling

## Performance Metrics

### Target Performance Goals
- **API Response Time:** < 200ms for CRUD operations
- **AI Design Generation:** < 30 seconds
- **AR Scanning:** Real-time at 30fps
- **App Launch:** < 3 seconds cold start
- **Database Queries:** < 100ms average

### Monitoring & Analytics
- API request/response times
- Error rates and types  
- User engagement metrics
- AR scanning success rates
- Design generation completion rates

## Development Workflow

### CI/CD Pipeline (Future)
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│             │    │             │    │             │    │             │
│   Git Push  │────┤   Tests     │────┤   Build     │────┤   Deploy    │
│             │    │   (Jest)    │    │   (Docker)  │    │   (AWS)     │
│             │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### Local Development
- **Backend:** nodemon for hot reloading
- **iOS:** Xcode with device testing
- **Database:** Supabase local development
- **API Testing:** Postman/curl scripts

This architecture provides a solid foundation for the RoomSpace MVP while maintaining flexibility for future enhancements and scaling needs.