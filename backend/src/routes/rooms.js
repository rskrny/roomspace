const express = require('express');
const Joi = require('joi');
const { supabase } = require('../services/supabase');
const { authenticateToken } = require('../middleware/auth');

const router = express.Router();

// Validation schema for room scan data
const roomScanSchema = Joi.object({
  name: Joi.string().required(),
  dimensions: Joi.object({
    width: Joi.number().positive().required(),
    length: Joi.number().positive().required(),
    height: Joi.number().positive().required()
  }).required(),
  scanData: Joi.string().required(), // Base64 encoded ARKit scan data
  roomType: Joi.string().valid('living_room', 'bedroom', 'kitchen', 'dining_room', 'office', 'other').required(),
  budget: Joi.object({
    min: Joi.number().min(0).required(),
    max: Joi.number().min(0).required()
  }).required(),
  style: Joi.string().valid('modern', 'minimalist', 'scandinavian', 'industrial', 'bohemian').required()
});

// Create a new room scan
router.post('/', authenticateToken, async (req, res) => {
  try {
    const { error, value } = roomScanSchema.validate(req.body);
    if (error) {
      return res.status(400).json({
        message: 'Validation error',
        details: error.details[0].message
      });
    }

    const { name, dimensions, scanData, roomType, budget, style } = value;

    // Save room scan to database
    const { data: room, error: dbError } = await supabase
      .from('room_scans')
      .insert([
        {
          user_id: req.user.userId,
          name,
          dimensions,
          scan_data: scanData,
          room_type: roomType,
          budget_min: budget.min,
          budget_max: budget.max,
          style,
          created_at: new Date().toISOString()
        }
      ])
      .select()
      .single();

    if (dbError) {
      console.error('Database error:', dbError);
      return res.status(500).json({
        message: 'Failed to save room scan'
      });
    }

    res.status(201).json({
      message: 'Room scan saved successfully',
      room
    });
  } catch (error) {
    console.error('Room scan error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Get all room scans for authenticated user
router.get('/', authenticateToken, async (req, res) => {
  try {
    const { data: rooms, error } = await supabase
      .from('room_scans')
      .select('*')
      .eq('user_id', req.user.userId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Database error:', error);
      return res.status(500).json({
        message: 'Failed to fetch rooms'
      });
    }

    res.json({
      rooms
    });
  } catch (error) {
    console.error('Get rooms error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Get specific room scan
router.get('/:roomId', authenticateToken, async (req, res) => {
  try {
    const { roomId } = req.params;

    const { data: room, error } = await supabase
      .from('room_scans')
      .select('*')
      .eq('id', roomId)
      .eq('user_id', req.user.userId)
      .single();

    if (error || !room) {
      return res.status(404).json({
        message: 'Room not found'
      });
    }

    res.json({
      room
    });
  } catch (error) {
    console.error('Get room error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Update room scan
router.put('/:roomId', authenticateToken, async (req, res) => {
  try {
    const { roomId } = req.params;
    const { error, value } = roomScanSchema.validate(req.body);
    
    if (error) {
      return res.status(400).json({
        message: 'Validation error',
        details: error.details[0].message
      });
    }

    const { name, dimensions, scanData, roomType, budget, style } = value;

    const { data: room, error: dbError } = await supabase
      .from('room_scans')
      .update({
        name,
        dimensions,
        scan_data: scanData,
        room_type: roomType,
        budget_min: budget.min,
        budget_max: budget.max,
        style,
        updated_at: new Date().toISOString()
      })
      .eq('id', roomId)
      .eq('user_id', req.user.userId)
      .select()
      .single();

    if (dbError || !room) {
      return res.status(404).json({
        message: 'Room not found or update failed'
      });
    }

    res.json({
      message: 'Room updated successfully',
      room
    });
  } catch (error) {
    console.error('Update room error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

// Delete room scan
router.delete('/:roomId', authenticateToken, async (req, res) => {
  try {
    const { roomId } = req.params;

    const { error } = await supabase
      .from('room_scans')
      .delete()
      .eq('id', roomId)
      .eq('user_id', req.user.userId);

    if (error) {
      console.error('Database error:', error);
      return res.status(500).json({
        message: 'Failed to delete room'
      });
    }

    res.json({
      message: 'Room deleted successfully'
    });
  } catch (error) {
    console.error('Delete room error:', error);
    res.status(500).json({
      message: 'Internal server error'
    });
  }
});

module.exports = router;