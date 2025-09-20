const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const auth = require('../middleware/auth');

const router = express.Router();

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL || 'your-supabase-url',
  process.env.SUPABASE_ANON_KEY || 'your-supabase-anon-key'
);

// Get all user's rooms
router.get('/', auth, async (req, res) => {
  try {
    const { data: rooms, error } = await supabase
      .from('rooms')
      .select('*')
      .eq('user_id', req.user.userId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Fetch rooms error:', error);
      return res.status(500).json({ error: 'Failed to fetch rooms' });
    }

    res.json({ rooms });

  } catch (error) {
    console.error('Get rooms error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create a new room from AR scan
router.post('/', auth, async (req, res) => {
  try {
    const { name, dimensions, scanData, roomType } = req.body;

    if (!name || !dimensions || !scanData) {
      return res.status(400).json({ 
        error: 'Room name, dimensions, and scan data are required' 
      });
    }

    const { data: room, error } = await supabase
      .from('rooms')
      .insert([{
        user_id: req.user.userId,
        name,
        dimensions: JSON.stringify(dimensions),
        scan_data: JSON.stringify(scanData),
        room_type: roomType || 'living_room',
        created_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (error) {
      console.error('Create room error:', error);
      return res.status(500).json({ error: 'Failed to create room' });
    }

    res.status(201).json({
      message: 'Room created successfully',
      room: {
        ...room,
        dimensions: JSON.parse(room.dimensions),
        scan_data: JSON.parse(room.scan_data)
      }
    });

  } catch (error) {
    console.error('Create room error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get specific room details
router.get('/:roomId', auth, async (req, res) => {
  try {
    const { roomId } = req.params;

    const { data: room, error } = await supabase
      .from('rooms')
      .select('*')
      .eq('id', roomId)
      .eq('user_id', req.user.userId)
      .single();

    if (error || !room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    res.json({
      room: {
        ...room,
        dimensions: JSON.parse(room.dimensions),
        scan_data: JSON.parse(room.scan_data)
      }
    });

  } catch (error) {
    console.error('Get room error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update room details
router.put('/:roomId', auth, async (req, res) => {
  try {
    const { roomId } = req.params;
    const { name, dimensions, scanData, roomType } = req.body;

    // Check if room belongs to user
    const { data: existingRoom } = await supabase
      .from('rooms')
      .select('id')
      .eq('id', roomId)
      .eq('user_id', req.user.userId)
      .single();

    if (!existingRoom) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const updateData = {
      updated_at: new Date().toISOString()
    };

    if (name) updateData.name = name;
    if (dimensions) updateData.dimensions = JSON.stringify(dimensions);
    if (scanData) updateData.scan_data = JSON.stringify(scanData);
    if (roomType) updateData.room_type = roomType;

    const { data: room, error } = await supabase
      .from('rooms')
      .update(updateData)
      .eq('id', roomId)
      .select()
      .single();

    if (error) {
      console.error('Update room error:', error);
      return res.status(500).json({ error: 'Failed to update room' });
    }

    res.json({
      message: 'Room updated successfully',
      room: {
        ...room,
        dimensions: JSON.parse(room.dimensions),
        scan_data: JSON.parse(room.scan_data)
      }
    });

  } catch (error) {
    console.error('Update room error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete room
router.delete('/:roomId', auth, async (req, res) => {
  try {
    const { roomId } = req.params;

    // Check if room belongs to user and delete
    const { error } = await supabase
      .from('rooms')
      .delete()
      .eq('id', roomId)
      .eq('user_id', req.user.userId);

    if (error) {
      console.error('Delete room error:', error);
      return res.status(500).json({ error: 'Failed to delete room' });
    }

    res.json({ message: 'Room deleted successfully' });

  } catch (error) {
    console.error('Delete room error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;