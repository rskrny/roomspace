const request = require('supertest');
const app = require('../src/server');

describe('RoomSpace API', () => {
  describe('Health Check', () => {
    it('should return 200 and status OK', async () => {
      const res = await request(app)
        .get('/api/health')
        .expect(200);
      
      expect(res.body.status).toBe('OK');
      expect(res.body.version).toBe('1.0.0');
      expect(res.body.timestamp).toBeDefined();
    });
  });

  describe('Authentication', () => {
    it('should return 400 for invalid registration data', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'invalid-email',
          password: '123' // Too short
        })
        .expect(400);
      
      expect(res.body.message).toBe('Validation error');
    });

    it('should return 400 for invalid login data', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'test@example.com'
          // Missing password
        })
        .expect(400);
      
      expect(res.body.message).toBe('Validation error');
    });
  });

  describe('Protected Routes', () => {
    it('should return 401 for rooms without auth token', async () => {
      const res = await request(app)
        .get('/api/rooms')
        .expect(401);
      
      expect(res.body.message).toBe('Access token required');
    });

    it('should return 401 for designs without auth token', async () => {
      const res = await request(app)
        .get('/api/designs')
        .expect(401);
      
      expect(res.body.message).toBe('Access token required');
    });

    it('should return 401 for products without auth token', async () => {
      const res = await request(app)
        .get('/api/products/search?keywords=sofa')
        .expect(401);
      
      expect(res.body.message).toBe('Access token required');
    });
  });

  describe('404 Handler', () => {
    it('should return 404 for non-existent routes', async () => {
      const res = await request(app)
        .get('/api/nonexistent')
        .expect(404);
      
      expect(res.body.message).toBe('Route not found');
    });
  });
});