const express = require('express');
const Joi = require('joi');
const { authenticateToken } = require('../middleware/auth');
const { searchAmazonProducts } = require('../services/amazon');

const router = express.Router();

const searchSchema = Joi.object({
  keywords: Joi.string().required(),
  category: Joi.string().optional(),
  minPrice: Joi.number().min(0).optional(),
  maxPrice: Joi.number().min(0).optional(),
  sortBy: Joi.string().valid('relevance', 'price_low', 'price_high', 'rating').default('relevance')
});

// Search products on Amazon
router.get('/search', authenticateToken, async (req, res) => {
  try {
    const { error, value } = searchSchema.validate(req.query);
    if (error) {
      return res.status(400).json({
        message: 'Validation error',
        details: error.details[0].message
      });
    }

    const { keywords, category, minPrice, maxPrice, sortBy } = value;

    const products = await searchAmazonProducts({
      keywords,
      category,
      minPrice,
      maxPrice,
      sortBy
    });

    res.json({
      products,
      total: products.length
    });
  } catch (error) {
    console.error('Product search error:', error);
    res.status(500).json({
      message: 'Failed to search products',
      error: error.message
    });
  }
});

// Get product details by ASIN
router.get('/details/:asin', authenticateToken, async (req, res) => {
  try {
    const { asin } = req.params;

    if (!asin) {
      return res.status(400).json({
        message: 'ASIN is required'
      });
    }

    // In a real implementation, this would fetch detailed product info from Amazon
    // For now, returning a placeholder response
    res.json({
      message: 'Product details endpoint - implementation pending',
      asin,
      placeholder: true
    });
  } catch (error) {
    console.error('Product details error:', error);
    res.status(500).json({
      message: 'Failed to get product details'
    });
  }
});

// Get furniture recommendations based on design
router.post('/recommendations', authenticateToken, async (req, res) => {
  try {
    const { designId, furnitureItems } = req.body;

    if (!designId && !furnitureItems) {
      return res.status(400).json({
        message: 'Either designId or furnitureItems array is required'
      });
    }

    let itemsToSearch = furnitureItems;

    // If designId is provided, fetch the design's furniture items
    if (designId) {
      const { supabase } = require('../services/supabase');
      const { data: design, error } = await supabase
        .from('saved_designs')
        .select('furniture_items')
        .eq('id', designId)
        .eq('user_id', req.user.userId)
        .single();

      if (error || !design) {
        return res.status(404).json({
          message: 'Design not found'
        });
      }

      itemsToSearch = design.furniture_items;
    }

    // Search for each furniture item
    const recommendations = [];
    
    for (const item of itemsToSearch || []) {
      try {
        const searchTerms = item.searchTerms || [item.name];
        const products = await searchAmazonProducts({
          keywords: searchTerms.join(' '),
          category: 'Home & Kitchen',
          maxPrice: item.estimatedPrice ? item.estimatedPrice * 1.5 : undefined
        });

        recommendations.push({
          item: item.name,
          category: item.category,
          estimatedPrice: item.estimatedPrice,
          products: products.slice(0, 5) // Top 5 recommendations per item
        });
      } catch (searchError) {
        console.error(`Failed to search for ${item.name}:`, searchError);
        recommendations.push({
          item: item.name,
          category: item.category,
          estimatedPrice: item.estimatedPrice,
          products: [],
          error: 'Search failed'
        });
      }
    }

    res.json({
      message: 'Furniture recommendations generated',
      recommendations,
      total: recommendations.length
    });
  } catch (error) {
    console.error('Recommendations error:', error);
    res.status(500).json({
      message: 'Failed to generate recommendations'
    });
  }
});

// Save product to user's favorites
router.post('/favorites', authenticateToken, async (req, res) => {
  try {
    const { asin, title, price, imageUrl, designId } = req.body;

    if (!asin || !title) {
      return res.status(400).json({
        message: 'ASIN and title are required'
      });
    }

    const { supabase } = require('../services/supabase');
    
    const { data: favorite, error } = await supabase
      .from('user_favorites')
      .insert([
        {
          user_id: req.user.userId,
          product_asin: asin,
          product_title: title,
          product_price: price,
          product_image_url: imageUrl,
          design_id: designId,
          created_at: new Date().toISOString()
        }
      ])
      .select()
      .single();

    if (error) {
      console.error('Failed to save favorite:', error);
      return res.status(500).json({
        message: 'Failed to save favorite'
      });
    }

    res.status(201).json({
      message: 'Product saved to favorites',
      favorite
    });
  } catch (error) {
    console.error('Save favorite error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Get user's favorite products
router.get('/favorites', authenticateToken, async (req, res) => {
  try {
    const { supabase } = require('../services/supabase');
    
    const { data: favorites, error } = await supabase
      .from('user_favorites')
      .select('*')
      .eq('user_id', req.user.userId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Failed to fetch favorites:', error);
      return res.status(500).json({
        message: 'Failed to fetch favorites'
      });
    }

    res.json({
      favorites
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Remove product from user's favorites
router.delete('/favorites/:asin', authenticateToken, async (req, res) => {
  try {
    const { asin } = req.params;

    if (!asin) {
      return res.status(400).json({
        message: 'ASIN is required'
      });
    }

    const { supabase } = require('../services/supabase');
    
    const { error } = await supabase
      .from('user_favorites')
      .delete()
      .eq('user_id', req.user.userId)
      .eq('product_asin', asin);

    if (error) {
      console.error('Failed to remove favorite:', error);
      return res.status(500).json({
        message: 'Failed to remove favorite'
      });
    }

    res.json({
      message: 'Product removed from favorites'
    });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

module.exports = router;