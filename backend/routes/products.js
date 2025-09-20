const express = require('express');
const auth = require('../middleware/auth');

const router = express.Router();

// Search products by category and budget
router.get('/search', auth, async (req, res) => {
  try {
    const { category, minPrice, maxPrice, style, keywords } = req.query;

    // Mock Amazon Product Advertising API response
    // In production, this would integrate with actual Amazon API
    const mockProducts = [
      {
        id: 'B08N5WRWNW',
        title: 'Modern Sectional Sofa',
        price: 899.99,
        originalPrice: 1199.99,
        category: 'seating',
        brand: 'Article',
        rating: 4.5,
        reviewCount: 1234,
        imageUrl: 'https://example.com/sofa1.jpg',
        amazonUrl: 'https://amazon.com/dp/B08N5WRWNW?tag=roomspace-20',
        description: 'Contemporary sectional sofa with clean lines and neutral upholstery',
        features: ['Pet-friendly fabric', 'Easy assembly', 'Free shipping'],
        dimensions: { width: 84, height: 32, depth: 60 },
        colors: ['Charcoal', 'Cream', 'Navy'],
        inStock: true,
        primeEligible: true
      },
      {
        id: 'B07X4K3P2M',
        title: 'Glass Coffee Table',
        price: 299.99,
        originalPrice: 399.99,
        category: 'tables',
        brand: 'Walker Edison',
        rating: 4.2,
        reviewCount: 856,
        imageUrl: 'https://example.com/table1.jpg',
        amazonUrl: 'https://amazon.com/dp/B07X4K3P2M?tag=roomspace-20',
        description: 'Tempered glass coffee table with metal frame',
        features: ['Tempered safety glass', 'Easy to clean', 'Modern design'],
        dimensions: { width: 48, height: 18, depth: 24 },
        colors: ['Clear Glass', 'Smoked Glass'],
        inStock: true,
        primeEligible: true
      },
      {
        id: 'B09KL2M3N4',
        title: 'Accent Chair',
        price: 449.99,
        originalPrice: 549.99,
        category: 'seating',
        brand: 'West Elm',
        rating: 4.7,
        reviewCount: 432,
        imageUrl: 'https://example.com/chair1.jpg',
        amazonUrl: 'https://amazon.com/dp/B09KL2M3N4?tag=roomspace-20',
        description: 'Mid-century modern accent chair with velvet upholstery',
        features: ['Velvet upholstery', 'Solid wood legs', 'Swivel base'],
        dimensions: { width: 28, height: 32, depth: 30 },
        colors: ['Emerald', 'Navy', 'Blush'],
        inStock: true,
        primeEligible: false
      }
    ];

    // Filter products based on query parameters
    let filteredProducts = mockProducts;

    if (category) {
      filteredProducts = filteredProducts.filter(p => p.category === category);
    }

    if (minPrice) {
      filteredProducts = filteredProducts.filter(p => p.price >= parseFloat(minPrice));
    }

    if (maxPrice) {
      filteredProducts = filteredProducts.filter(p => p.price <= parseFloat(maxPrice));
    }

    if (keywords) {
      const keywordArray = keywords.toLowerCase().split(' ');
      filteredProducts = filteredProducts.filter(p => 
        keywordArray.some(keyword => 
          p.title.toLowerCase().includes(keyword) ||
          p.description.toLowerCase().includes(keyword)
        )
      );
    }

    res.json({
      products: filteredProducts,
      totalCount: filteredProducts.length,
      filters: {
        category,
        minPrice,
        maxPrice,
        style,
        keywords
      }
    });

  } catch (error) {
    console.error('Product search error:', error);
    res.status(500).json({ error: 'Failed to search products' });
  }
});

// Get product details by ID
router.get('/:productId', auth, async (req, res) => {
  try {
    const { productId } = req.params;

    // Mock product detail
    const mockProduct = {
      id: productId,
      title: 'Modern Sectional Sofa',
      price: 899.99,
      originalPrice: 1199.99,
      category: 'seating',
      brand: 'Article',
      rating: 4.5,
      reviewCount: 1234,
      imageUrl: 'https://example.com/sofa1.jpg',
      imageGallery: [
        'https://example.com/sofa1.jpg',
        'https://example.com/sofa1-side.jpg',
        'https://example.com/sofa1-detail.jpg'
      ],
      amazonUrl: 'https://amazon.com/dp/' + productId + '?tag=roomspace-20',
      description: 'Contemporary sectional sofa with clean lines and neutral upholstery. Perfect for modern living rooms.',
      longDescription: 'This modern sectional sofa features a sleek design with clean lines and neutral upholstery that complements any contemporary decor. The high-quality construction ensures durability while the comfortable cushioning provides excellent support for daily use.',
      features: ['Pet-friendly fabric', 'Easy assembly', 'Free shipping', 'Stain-resistant'],
      specifications: {
        dimensions: { width: 84, height: 32, depth: 60 },
        weight: 150,
        material: 'Polyester blend fabric',
        frameMaterial: 'Solid wood',
        seatDepth: 22,
        seatHeight: 18
      },
      colors: [
        { name: 'Charcoal', hex: '#36454F', available: true },
        { name: 'Cream', hex: '#F5F5DC', available: true },
        { name: 'Navy', hex: '#000080', available: false }
      ],
      inStock: true,
      primeEligible: true,
      deliveryInfo: {
        freeShipping: true,
        estimatedDelivery: '3-5 business days',
        whiteGloveDelivery: true,
        assemblyIncluded: false
      },
      warranty: '2 years manufacturer warranty',
      returnPolicy: '30 day return policy'
    };

    res.json({ product: mockProduct });

  } catch (error) {
    console.error('Product detail error:', error);
    res.status(500).json({ error: 'Failed to get product details' });
  }
});

// Get product recommendations for a specific design
router.get('/recommendations/:designId', auth, async (req, res) => {
  try {
    const { designId } = req.params;
    
    // This would typically analyze the design and return matching products
    // For now, return mock recommendations
    const recommendations = [
      {
        furnitureItem: 'Sofa',
        products: [
          {
            id: 'B08N5WRWNW',
            title: 'Modern Sectional Sofa',
            price: 899.99,
            rating: 4.5,
            imageUrl: 'https://example.com/sofa1.jpg',
            amazonUrl: 'https://amazon.com/dp/B08N5WRWNW?tag=roomspace-20',
            matchScore: 95
          },
          {
            id: 'B08M6Y7H5K',
            title: 'Contemporary 3-Seat Sofa',
            price: 749.99,
            rating: 4.3,
            imageUrl: 'https://example.com/sofa2.jpg',
            amazonUrl: 'https://amazon.com/dp/B08M6Y7H5K?tag=roomspace-20',
            matchScore: 88
          }
        ]
      },
      {
        furnitureItem: 'Coffee Table',
        products: [
          {
            id: 'B07X4K3P2M',
            title: 'Glass Coffee Table',
            price: 299.99,
            rating: 4.2,
            imageUrl: 'https://example.com/table1.jpg',
            amazonUrl: 'https://amazon.com/dp/B07X4K3P2M?tag=roomspace-20',
            matchScore: 92
          }
        ]
      }
    ];

    res.json({
      designId,
      recommendations,
      totalProducts: recommendations.reduce((acc, cat) => acc + cat.products.length, 0)
    });

  } catch (error) {
    console.error('Product recommendations error:', error);
    res.status(500).json({ error: 'Failed to get product recommendations' });
  }
});

// Get popular products by category
router.get('/popular/:category', auth, async (req, res) => {
  try {
    const { category } = req.params;
    const { limit = 10 } = req.query;

    // Mock popular products
    const popularProducts = [
      {
        id: 'B08N5WRWNW',
        title: 'Modern Sectional Sofa',
        price: 899.99,
        rating: 4.5,
        reviewCount: 1234,
        imageUrl: 'https://example.com/sofa1.jpg',
        amazonUrl: 'https://amazon.com/dp/B08N5WRWNW?tag=roomspace-20',
        salesRank: 1
      },
      {
        id: 'B09KL2M3N4',
        title: 'Accent Chair',
        price: 449.99,
        rating: 4.7,
        reviewCount: 432,
        imageUrl: 'https://example.com/chair1.jpg',
        amazonUrl: 'https://amazon.com/dp/B09KL2M3N4?tag=roomspace-20',
        salesRank: 2
      }
    ];

    const filteredProducts = category === 'all' 
      ? popularProducts 
      : popularProducts.filter(p => p.category === category);

    res.json({
      category,
      products: filteredProducts.slice(0, parseInt(limit)),
      totalAvailable: filteredProducts.length
    });

  } catch (error) {
    console.error('Popular products error:', error);
    res.status(500).json({ error: 'Failed to get popular products' });
  }
});

// Track affiliate click
router.post('/track-click', auth, async (req, res) => {
  try {
    const { productId, designId, clickSource } = req.body;

    // In a real implementation, you would:
    // 1. Log the click for analytics
    // 2. Track conversion rates
    // 3. Generate detailed affiliate reports
    
    console.log('Affiliate click tracked:', {
      userId: req.user.userId,
      productId,
      designId,
      clickSource,
      timestamp: new Date().toISOString()
    });

    res.json({ 
      message: 'Click tracked successfully',
      tracked: true 
    });

  } catch (error) {
    console.error('Track click error:', error);
    res.status(500).json({ error: 'Failed to track click' });
  }
});

module.exports = router;