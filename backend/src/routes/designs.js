const express = require('express');
const Joi = require('joi');
const { supabase } = require('../services/supabase');
const { authenticateToken } = require('../middleware/auth');
const { generateDesign } = require('../services/openai');

const router = express.Router();

const designRequestSchema = Joi.object({
  roomId: Joi.string().required(),
  style: Joi.string().valid('modern', 'minimalist', 'scandinavian', 'industrial', 'bohemian').required(),
  budget: Joi.object({
    min: Joi.number().min(0).required(),
    max: Joi.number().min(0).required()
  }).required(),
  preferences: Joi.object({
    colors: Joi.array().items(Joi.string()).optional(),
    furniture: Joi.array().items(Joi.string()).optional(),
    avoid: Joi.array().items(Joi.string()).optional()
  }).optional()
});

// Generate new design for a room
router.post('/generate', authenticateToken, async (req, res) => {
  try {
    const { error, value } = designRequestSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        message: 'Validation error',
        details: error.details[0].message
      });
    }

    const { roomId, style, budget, preferences } = value;

    // Get room data
    const { data: room, error: roomError } = await supabase
      .from('room_scans')
      .select('*')
      .eq('id', roomId)
      .eq('user_id', req.user.userId)
      .single();

    if (roomError || !room) {
      return res.status(404).json({
        message: 'Room not found'
      });
    }

    // Generate design using OpenAI
    const designData = await generateDesign({
      room,
      style,
      budget,
      preferences
    });

    // Save design to database
    const { data: savedDesign, error: saveError } = await supabase
      .from('saved_designs')
      .insert([
        {
          user_id: req.user.userId,
          room_id: roomId,
          style,
          budget_min: budget.min,
          budget_max: budget.max,
          design_data: designData,
          furniture_items: designData.furnitureItems || [],
          total_cost: designData.totalCost || 0,
          created_at: new Date().toISOString()
        }
      ])
      .select()
      .single();

    if (saveError) {
      console.error('Failed to save design:', saveError);
      return res.status(500).json({
        message: 'Failed to save design'
      });
    }

    res.json({
      message: 'Design generated successfully',
      design: savedDesign
    });
  } catch (error) {
    console.error('Design generation error:', error);
    res.status(500).json({
      message: 'Failed to generate design'
    });
  }
});

// Get all saved designs for user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { data: designs, error } = await supabase
      .from('saved_designs')
      .select(`
        *,
        room_scans (
          name,
          room_type,
          dimensions
        )
      `)
      .eq('user_id', req.user.userId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Database error:', error);
      return res.status(500).json({
        message: 'Failed to fetch designs'
      });
    }

    res.json({
      designs
    });
  } catch (error) {
    console.error('Get designs error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Get specific design
router.get('/:designId', authenticateToken, async (req, res) => {
  try {
    const { designId } = req.params;

    const { data: design, error } = await supabase
      .from('saved_designs')
      .select(`
        *,
        room_scans (
          name,
          room_type,
          dimensions,
          scan_data
        )
      `)
      .eq('id', designId)
      .eq('user_id', req.user.userId)
      .single();

    if (error || !design) {
      return res.status(404).json({
        message: 'Design not found'
      });
    }

    res.json({
      design
    });
  } catch (error) {
    console.error('Get design error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Update design (save modifications)
router.put('/:designId', authenticateToken, async (req, res) => {
  try {
    const { designId } = req.params;
    const { furniture_items, design_data } = req.body;

    const { data: design, error } = await supabase
      .from('saved_designs')
      .update({
        furniture_items: furniture_items || [],
        design_data: design_data || {},
        updated_at: new Date().toISOString()
      })
      .eq('id', designId)
      .eq('user_id', req.user.userId)
      .select()
      .single();

    if (error || !design) {
      return res.status(404).json({
        message: 'Design not found or update failed'
      });
    }

    res.json({
      message: 'Design updated successfully',
      design
    });
  } catch (error) {
    console.error('Update design error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Delete design
router.delete('/:designId', authenticateToken, async (req, res) => {
  try {
    const { designId } = req.params;

    const { error } = await supabase
      .from('saved_designs')
      .delete()
      .eq('id', designId)
      .eq('user_id', req.user.userId);

    if (error) {
      console.error('Database error:', error);
      return res.status(500).json({
        message: 'Failed to delete design'
      });
    }

    res.json({
      message: 'Design deleted successfully'
    });
  } catch (error) {
    console.error('Delete design error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

module.exports = router;