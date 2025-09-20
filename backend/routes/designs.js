const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const auth = require('../middleware/auth');

const router = express.Router();

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL || 'your-supabase-url',
  process.env.SUPABASE_ANON_KEY || 'your-supabase-anon-key'
);

// Get all user's designs
router.get('/', auth, async (req, res) => {
  try {
    const { data: designs, error } = await supabase
      .from('designs')
      .select(`
        *,
        rooms (
          id,
          name,
          room_type
        )
      `)
      .eq('user_id', req.user.userId)
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Fetch designs error:', error);
      return res.status(500).json({ error: 'Failed to fetch designs' });
    }

    const formattedDesigns = designs.map(design => ({
      ...design,
      ai_response: JSON.parse(design.ai_response)
    }));

    res.json({ designs: formattedDesigns });

  } catch (error) {
    console.error('Get designs error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get specific design
router.get('/:designId', auth, async (req, res) => {
  try {
    const { designId } = req.params;

    const { data: design, error } = await supabase
      .from('designs')
      .select(`
        *,
        rooms (
          id,
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
      return res.status(404).json({ error: 'Design not found' });
    }

    const formattedDesign = {
      ...design,
      ai_response: JSON.parse(design.ai_response),
      rooms: {
        ...design.rooms,
        dimensions: JSON.parse(design.rooms.dimensions),
        scan_data: JSON.parse(design.rooms.scan_data)
      }
    };

    res.json({ design: formattedDesign });

  } catch (error) {
    console.error('Get design error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update design (save custom modifications)
router.put('/:designId', auth, async (req, res) => {
  try {
    const { designId } = req.params;
    const { customLayout, notes, isFavorite } = req.body;

    // Check if design belongs to user
    const { data: existingDesign } = await supabase
      .from('designs')
      .select('id')
      .eq('id', designId)
      .eq('user_id', req.user.userId)
      .single();

    if (!existingDesign) {
      return res.status(404).json({ error: 'Design not found' });
    }

    const updateData = {
      updated_at: new Date().toISOString()
    };

    if (customLayout !== undefined) {
      updateData.custom_layout = JSON.stringify(customLayout);
    }
    if (notes !== undefined) updateData.notes = notes;
    if (isFavorite !== undefined) updateData.is_favorite = isFavorite;

    const { data: design, error } = await supabase
      .from('designs')
      .update(updateData)
      .eq('id', designId)
      .select()
      .single();

    if (error) {
      console.error('Update design error:', error);
      return res.status(500).json({ error: 'Failed to update design' });
    }

    const formattedDesign = {
      ...design,
      ai_response: JSON.parse(design.ai_response),
      custom_layout: design.custom_layout ? JSON.parse(design.custom_layout) : null
    };

    res.json({
      message: 'Design updated successfully',
      design: formattedDesign
    });

  } catch (error) {
    console.error('Update design error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete design
router.delete('/:designId', auth, async (req, res) => {
  try {
    const { designId } = req.params;

    const { error } = await supabase
      .from('designs')
      .delete()
      .eq('id', designId)
      .eq('user_id', req.user.userId);

    if (error) {
      console.error('Delete design error:', error);
      return res.status(500).json({ error: 'Failed to delete design' });
    }

    res.json({ message: 'Design deleted successfully' });

  } catch (error) {
    console.error('Delete design error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get user's favorite designs
router.get('/favorites/list', auth, async (req, res) => {
  try {
    const { data: designs, error } = await supabase
      .from('designs')
      .select(`
        *,
        rooms (
          id,
          name,
          room_type
        )
      `)
      .eq('user_id', req.user.userId)
      .eq('is_favorite', true)
      .order('updated_at', { ascending: false });

    if (error) {
      console.error('Fetch favorite designs error:', error);
      return res.status(500).json({ error: 'Failed to fetch favorite designs' });
    }

    const formattedDesigns = designs.map(design => ({
      ...design,
      ai_response: JSON.parse(design.ai_response)
    }));

    res.json({ designs: formattedDesigns });

  } catch (error) {
    console.error('Get favorite designs error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create a copy/variant of existing design
router.post('/:designId/copy', auth, async (req, res) => {
  try {
    const { designId } = req.params;
    const { newStyle, newBudget } = req.body;

    // Get original design
    const { data: originalDesign, error: fetchError } = await supabase
      .from('designs')
      .select('*')
      .eq('id', designId)
      .eq('user_id', req.user.userId)
      .single();

    if (fetchError || !originalDesign) {
      return res.status(404).json({ error: 'Original design not found' });
    }

    // Create copy with modifications
    const { data: newDesign, error: createError } = await supabase
      .from('designs')
      .insert([{
        user_id: req.user.userId,
        room_id: originalDesign.room_id,
        style: newStyle || originalDesign.style,
        budget: newBudget || originalDesign.budget,
        ai_response: originalDesign.ai_response,
        preferences: originalDesign.preferences,
        notes: `Copy of design #${designId}`,
        created_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (createError) {
      console.error('Create design copy error:', createError);
      return res.status(500).json({ error: 'Failed to create design copy' });
    }

    const formattedDesign = {
      ...newDesign,
      ai_response: JSON.parse(newDesign.ai_response)
    };

    res.status(201).json({
      message: 'Design copied successfully',
      design: formattedDesign
    });

  } catch (error) {
    console.error('Copy design error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;