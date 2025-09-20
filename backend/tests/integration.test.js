const request = require('supertest');
const app = require('../src/server');

describe('RoomSpace API Integration Tests', () => {
  let authToken;
  let testUser;
  let testRoom;
  let testDesign;

  // Test user registration and login flow
  describe('Complete Authentication Flow', () => {
    it('should register a new user successfully', async () => {
      const userData = {
        email: 'test@example.com',
        password: 'testpassword123',
        firstName: 'Test',
        lastName: 'User'
      };

      const res = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(res.body.message).toBe('User created successfully');
      expect(res.body.token).toBeDefined();
      expect(res.body.user.email).toBe(userData.email);
      expect(res.body.user.firstName).toBe(userData.firstName);
      
      authToken = res.body.token;
      testUser = res.body.user;
    });

    it('should login with correct credentials', async () => {
      const loginData = {
        email: 'test@example.com',
        password: 'testpassword123'
      };

      const res = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(200);

      expect(res.body.message).toBe('Login successful');
      expect(res.body.token).toBeDefined();
    });

    it('should reject login with incorrect password', async () => {
      const loginData = {
        email: 'test@example.com',
        password: 'wrongpassword'
      };

      await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(401);
    });
  });

  describe('Room Management', () => {
    it('should create a new room scan', async () => {
      const roomData = {
        name: 'Test Living Room',
        dimensions: {
          width: 12,
          length: 15,
          height: 9
        },
        scanData: 'base64-encoded-mock-scan-data',
        roomType: 'living_room',
        budget: {
          min: 500,
          max: 2000
        },
        style: 'modern'
      };

      const res = await request(app)
        .post('/api/rooms')
        .set('Authorization', `Bearer ${authToken}`)
        .send(roomData)
        .expect(201);

      expect(res.body.message).toBe('Room scan saved successfully');
      expect(res.body.room.name).toBe(roomData.name);
      expect(res.body.room.room_type).toBe(roomData.roomType);
      
      testRoom = res.body.room;
    });

    it('should get all user rooms', async () => {
      const res = await request(app)
        .get('/api/rooms')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.rooms).toBeDefined();
      expect(Array.isArray(res.body.rooms)).toBe(true);
      expect(res.body.rooms.length).toBeGreaterThan(0);
    });

    it('should get specific room by ID', async () => {
      const res = await request(app)
        .get(`/api/rooms/${testRoom.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.room.id).toBe(testRoom.id);
      expect(res.body.room.name).toBe('Test Living Room');
    });
  });

  describe('Design Generation', () => {
    it('should generate a design for a room', async () => {
      const designData = {
        roomId: testRoom.id,
        style: 'modern',
        budget: {
          min: 500,
          max: 2000
        },
        preferences: {
          colors: ['blue', 'white'],
          furniture: ['sofa', 'coffee table']
        }
      };

      const res = await request(app)
        .post('/api/designs/generate')
        .set('Authorization', `Bearer ${authToken}`)
        .send(designData)
        .expect(200);

      expect(res.body.message).toBe('Design generated successfully');
      expect(res.body.design.style).toBe(designData.style);
      expect(res.body.design.design_data).toBeDefined();
      
      testDesign = res.body.design;
    });

    it('should get all user designs', async () => {
      const res = await request(app)
        .get('/api/designs')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.designs).toBeDefined();
      expect(Array.isArray(res.body.designs)).toBe(true);
      expect(res.body.designs.length).toBeGreaterThan(0);
    });

    it('should get specific design by ID', async () => {
      const res = await request(app)
        .get(`/api/designs/${testDesign.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.design.id).toBe(testDesign.id);
      expect(res.body.design.style).toBe('modern');
    });

    it('should update a design', async () => {
      const updateData = {
        furniture_items: [
          {
            name: 'Modern Sofa',
            category: 'Seating',
            estimatedPrice: 800
          }
        ]
      };

      const res = await request(app)
        .put(`/api/designs/${testDesign.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(updateData)
        .expect(200);

      expect(res.body.message).toBe('Design updated successfully');
    });
  });

  describe('Product Search and Favorites', () => {
    it('should search for products', async () => {
      const res = await request(app)
        .get('/api/products/search?keywords=sofa&sortBy=price_low')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.products).toBeDefined();
      expect(Array.isArray(res.body.products)).toBe(true);
      expect(res.body.total).toBeDefined();
    });

    it('should add product to favorites', async () => {
      const favoriteData = {
        asin: 'B08MOCK001',
        title: 'Test Sofa',
        price: 599,
        imageUrl: 'https://example.com/image.jpg',
        designId: testDesign.id
      };

      const res = await request(app)
        .post('/api/products/favorites')
        .set('Authorization', `Bearer ${authToken}`)
        .send(favoriteData)
        .expect(201);

      expect(res.body.message).toBe('Product saved to favorites');
    });

    it('should get user favorites', async () => {
      const res = await request(app)
        .get('/api/products/favorites')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.favorites).toBeDefined();
      expect(Array.isArray(res.body.favorites)).toBe(true);
    });

    it('should remove product from favorites', async () => {
      const res = await request(app)
        .delete('/api/products/favorites/B08MOCK001')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.message).toBe('Product removed from favorites');
    });
  });

  describe('Service Health and Status', () => {
    it('should return comprehensive health check', async () => {
      const res = await request(app)
        .get('/api/health')
        .expect(200);

      expect(res.body.status).toBe('OK');
      expect(res.body.version).toBe('1.0.0');
      expect(res.body.environment).toBeDefined();
      expect(res.body.services).toBeDefined();
      expect(res.body.services.supabase).toBeDefined();
      expect(res.body.services.openai).toBeDefined();
    });
  });

  // Clean up - delete test data
  describe('Cleanup', () => {
    it('should delete test design', async () => {
      const res = await request(app)
        .delete(`/api/designs/${testDesign.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.message).toBe('Design deleted successfully');
    });

    it('should delete test room', async () => {
      const res = await request(app)
        .delete(`/api/rooms/${testRoom.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(res.body.message).toBe('Room deleted successfully');
    });
  });
});