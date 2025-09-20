const express = require('express');
const router = express.Router();

// GET /api/furniture - Get furniture recommendations
router.get('/', (req, res) => {
  res.json({ message: 'Get furniture recommendations endpoint - coming soon' });
});

// POST /api/furniture/recommendations - Get AI-powered recommendations
router.post('/recommendations', (req, res) => {
  res.json({ message: 'AI furniture recommendations endpoint - coming soon' });
});

module.exports = router;