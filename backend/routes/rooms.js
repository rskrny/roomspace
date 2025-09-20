const express = require('express');
const router = express.Router();

// GET /api/rooms - Get user's scanned rooms
router.get('/', (req, res) => {
  res.json({ message: 'Get rooms endpoint - coming soon' });
});

// POST /api/rooms - Save a new scanned room
router.post('/', (req, res) => {
  res.json({ message: 'Save room endpoint - coming soon' });
});

// GET /api/rooms/:id - Get specific room details
router.get('/:id', (req, res) => {
  res.json({ message: `Get room ${req.params.id} endpoint - coming soon` });
});

module.exports = router;