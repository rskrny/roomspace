# API Documentation

Base URL: `http://localhost:3000/api`

## Health Check
```
GET /health
```
Returns server status.

## Rooms API

### Get All Rooms
```
GET /api/rooms
```
Get all rooms for the current user.

### Create Room
```
POST /api/rooms
```
Save a new scanned room.

**Request Body:**
```json
{
  "name": "Living Room",
  "room_type": "living_room",
  "dimensions": {...},
  "scan_data": {...}
}
```

### Get Room Details
```
GET /api/rooms/:id
```
Get specific room details including furniture recommendations.

## Furniture API

### Get Furniture Recommendations
```
GET /api/furniture
```
Get furniture recommendations based on room data.

### AI Recommendations
```
POST /api/furniture/recommendations
```
Get AI-powered furniture recommendations.

**Request Body:**
```json
{
  "room_id": "uuid",
  "style_preferences": ["modern", "minimalist"],
  "budget_range": {"min": 500, "max": 2000}
}
```

## Users API

### Get User Profile
```
GET /api/users/profile
```
Get current user profile.

### Update User Profile
```
POST /api/users/profile
```
Update user profile information.

### Get Saved Designs
```
GET /api/users/designs
```
Get user's saved room designs.