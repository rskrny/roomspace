# RoomSpace API Documentation

Base URL: `http://localhost:3000/api`

## Authentication

All protected endpoints require a JWT token in the Authorization header:
```
Authorization: Bearer <your-jwt-token>
```

## Authentication Endpoints

### POST /auth/register
Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response:**
```json
{
  "message": "User created successfully",
  "token": "jwt-token-string",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

### POST /auth/login
Authenticate an existing user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "token": "jwt-token-string",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe"
  }
}
```

### POST /auth/google
Google OAuth authentication (Not implemented yet)

### POST /auth/apple
Apple Sign In authentication (Not implemented yet)

## Room Management

### POST /rooms
Create a new room scan.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "name": "Living Room",
  "dimensions": {
    "width": 12.5,
    "length": 15.0,
    "height": 9.0
  },
  "scanData": "base64-encoded-arkit-data",
  "roomType": "living_room",
  "budget": {
    "min": 500,
    "max": 2000
  },
  "style": "modern"
}
```

**Response:**
```json
{
  "message": "Room scan saved successfully",
  "room": {
    "id": "uuid",
    "user_id": "uuid",
    "name": "Living Room",
    "room_type": "living_room",
    "dimensions": {
      "width": 12.5,
      "length": 15.0,
      "height": 9.0
    },
    "scan_data": "base64-encoded-arkit-data",
    "budget_min": 500,
    "budget_max": 2000,
    "style": "modern",
    "created_at": "2023-12-01T10:00:00Z"
  }
}
```

### GET /rooms
Get all room scans for the authenticated user.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "rooms": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "name": "Living Room",
      "room_type": "living_room",
      "dimensions": {
        "width": 12.5,
        "length": 15.0,
        "height": 9.0
      },
      "budget_min": 500,
      "budget_max": 2000,
      "style": "modern",
      "created_at": "2023-12-01T10:00:00Z"
    }
  ]
}
```

### GET /rooms/:roomId
Get a specific room scan.

**Headers:** `Authorization: Bearer <token>`

**Response:** Single room object (same as POST /rooms response)

### PUT /rooms/:roomId
Update a room scan.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** Same as POST /rooms

### DELETE /rooms/:roomId
Delete a room scan.

**Headers:** `Authorization: Bearer <token>`

**Response:**
```json
{
  "message": "Room deleted successfully"
}
```

## Design Generation

### POST /designs/generate
Generate an AI-powered interior design for a room.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "roomId": "uuid",
  "style": "modern",
  "budget": {
    "min": 500,
    "max": 2000
  },
  "preferences": {
    "colors": ["blue", "white", "gray"],
    "furniture": ["sectional", "coffee table"],
    "avoid": ["leather", "dark colors"]
  }
}
```

**Response:**
```json
{
  "message": "Design generated successfully",
  "design": {
    "id": "uuid",
    "user_id": "uuid",
    "room_id": "uuid",
    "style": "modern",
    "budget_min": 500,
    "budget_max": 2000,
    "design_data": {
      "layout": {
        "description": "Modern living room layout",
        "zones": [
          {
            "name": "Seating area",
            "furniture": ["Sofa", "Coffee table"],
            "position": {"x": 0, "y": 0, "rotation": 0}
          }
        ]
      },
      "colorScheme": {
        "primary": "#2C3E50",
        "secondary": "#ECF0F1",
        "accent": "#E74C3C"
      },
      "furnitureItems": [
        {
          "name": "Modern Sectional Sofa",
          "category": "Seating",
          "estimatedPrice": 899.99,
          "position": {"x": 0, "y": 0, "z": 0},
          "dimensions": {"width": 72, "depth": 36, "height": 32},
          "searchTerms": ["modern", "sectional", "sofa"]
        }
      ],
      "lighting": ["Natural light", "Floor lamps"],
      "accessories": ["Throw pillows", "Wall art"],
      "totalCost": 1500.00
    },
    "total_cost": 1500.00,
    "created_at": "2023-12-01T10:00:00Z"
  }
}
```

### GET /designs
Get all saved designs for the authenticated user.

**Headers:** `Authorization: Bearer <token>`

### GET /designs/:designId
Get a specific design.

**Headers:** `Authorization: Bearer <token>`

### PUT /designs/:designId
Update a design.

**Headers:** `Authorization: Bearer <token>`

### DELETE /designs/:designId
Delete a design.

**Headers:** `Authorization: Bearer <token>`

## Product Search

### GET /products/search
Search for furniture products on Amazon.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `keywords` (required): Search keywords
- `category` (optional): Product category
- `minPrice` (optional): Minimum price filter
- `maxPrice` (optional): Maximum price filter
- `sortBy` (optional): Sort by relevance, price_low, price_high, rating

**Response:**
```json
{
  "products": [
    {
      "asin": "B08MOCK001",
      "title": "Modern Sectional Sofa",
      "price": {
        "amount": 899.99,
        "currency": "USD"
      },
      "images": {
        "primary": "https://example.com/image.jpg",
        "thumbnails": ["https://example.com/thumb.jpg"]
      },
      "rating": "4.5",
      "review_count": 234,
      "features": ["High-quality materials", "Easy assembly"],
      "affiliate_url": "https://amazon.com/dp/B08MOCK001?tag=roomspace-20",
      "availability": "In Stock"
    }
  ],
  "total": 1
}
```

### POST /products/recommendations
Get furniture recommendations based on a design.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "designId": "uuid"
}
```

**Response:**
```json
{
  "message": "Furniture recommendations generated",
  "recommendations": [
    {
      "item": "Modern Sectional Sofa",
      "category": "Seating",
      "estimatedPrice": 899.99,
      "products": [
        // Array of Product objects (same as search response)
      ]
    }
  ]
}
```

### POST /products/favorites
Save a product to favorites.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "asin": "B08MOCK001",
  "title": "Modern Sectional Sofa",
  "price": 899.99,
  "imageUrl": "https://example.com/image.jpg",
  "designId": "uuid" // optional
}
```

### GET /products/favorites
Get user's favorite products.

**Headers:** `Authorization: Bearer <token>`

## Error Responses

All endpoints may return these error responses:

### 400 Bad Request
```json
{
  "message": "Validation error",
  "details": "Email is required"
}
```

### 401 Unauthorized
```json
{
  "message": "Access token required"
}
```

### 403 Forbidden
```json
{
  "message": "Invalid or expired token"
}
```

### 404 Not Found
```json
{
  "message": "Resource not found"
}
```

### 500 Internal Server Error
```json
{
  "message": "Internal server error"
}
```

## Data Types

### Room Types
- `living_room`
- `bedroom`
- `kitchen`
- `dining_room`
- `office`
- `other`

### Design Styles
- `modern`
- `minimalist`
- `scandinavian`
- `industrial`
- `bohemian`

### Product Sort Options
- `relevance` (default)
- `price_low`
- `price_high`
- `rating`

## Rate Limits

- 100 requests per minute per user
- 1000 requests per hour per user

Exceeded rate limits will return HTTP 429 with:
```json
{
  "message": "Rate limit exceeded",
  "retry_after": 60
}
```