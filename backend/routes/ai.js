const express = require('express');
const { Configuration, OpenAIApi } = require('openai');
const { createClient } = require('@supabase/supabase-js');
const auth = require('../middleware/auth');

const router = express.Router();

// Initialize OpenAI
const configuration = new Configuration({
  apiKey: process.env.OPENAI_API_KEY || 'your-openai-api-key',
});
const openai = new OpenAIApi(configuration);

// Initialize Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL || 'your-supabase-url',
  process.env.SUPABASE_ANON_KEY || 'your-supabase-anon-key'
);

// Generate AI layout recommendations
router.post('/generate-layout', auth, async (req, res) => {
  try {
    const { roomId, style, budget, preferences } = req.body;

    if (!roomId || !style || !budget) {
      return res.status(400).json({ 
        error: 'Room ID, style, and budget are required' 
      });
    }

    // Get room details
    const { data: room, error: roomError } = await supabase
      .from('rooms')
      .select('*')
      .eq('id', roomId)
      .eq('user_id', req.user.userId)
      .single();

    if (roomError || !room) {
      return res.status(404).json({ error: 'Room not found' });
    }

    const roomData = {
      ...room,
      dimensions: JSON.parse(room.dimensions),
      scan_data: JSON.parse(room.scan_data)
    };

    // Prepare prompt for OpenAI
    const prompt = `
As an interior design AI assistant, generate furniture layout recommendations for a ${room.room_type} with the following specifications:

Room Details:
- Dimensions: ${JSON.stringify(roomData.dimensions)}
- Room Type: ${room.room_type}
- Scan Data: ${JSON.stringify(roomData.scan_data, null, 2)}

Design Requirements:
- Style: ${style}
- Budget: $${budget}
- Additional Preferences: ${preferences || 'None specified'}

Please provide:
1. A detailed furniture layout plan with specific furniture pieces
2. Placement coordinates relative to room dimensions
3. Estimated costs for each item
4. Color scheme and material recommendations
5. Shopping list with product categories

Format the response as JSON with the following structure:
{
  "layout": {
    "furniture_pieces": [
      {
        "item": "item_name",
        "category": "category",
        "position": {"x": 0, "y": 0, "z": 0},
        "rotation": 0,
        "dimensions": {"width": 0, "height": 0, "depth": 0},
        "estimated_cost": 0,
        "description": "detailed description"
      }
    ],
    "color_scheme": {
      "primary": "#color",
      "secondary": "#color",
      "accent": "#color"
    },
    "total_estimated_cost": 0
  },
  "shopping_list": [
    {
      "category": "category_name",
      "items": ["item1", "item2"],
      "priority": "high|medium|low"
    }
  ],
  "design_notes": "Additional design recommendations and tips"
}
`;

    // Call OpenAI API
    const response = await openai.createCompletion({
      model: "text-davinci-003",
      prompt: prompt,
      max_tokens: 2000,
      temperature: 0.7,
    });

    let aiResponse;
    try {
      aiResponse = JSON.parse(response.data.choices[0].text.trim());
    } catch (parseError) {
      console.error('Failed to parse AI response:', parseError);
      // Fallback response structure
      aiResponse = {
        layout: {
          furniture_pieces: [
            {
              item: "Sofa",
              category: "seating",
              position: { x: 2, y: 0, z: 1 },
              rotation: 0,
              dimensions: { width: 2.0, height: 0.8, depth: 0.9 },
              estimated_cost: Math.floor(budget * 0.3),
              description: `A comfortable ${style} style sofa perfect for your living room`
            },
            {
              item: "Coffee Table",
              category: "table",
              position: { x: 2, y: 0, z: 2.5 },
              rotation: 0,
              dimensions: { width: 1.2, height: 0.4, depth: 0.6 },
              estimated_cost: Math.floor(budget * 0.15),
              description: `A stylish ${style} coffee table to complement your seating area`
            }
          ],
          color_scheme: {
            primary: style === 'modern' ? '#2C3E50' : style === 'minimalist' ? '#FFFFFF' : '#8B4513',
            secondary: style === 'modern' ? '#ECF0F1' : style === 'minimalist' ? '#F5F5F5' : '#D2B48C',
            accent: style === 'modern' ? '#3498DB' : style === 'minimalist' ? '#34495E' : '#CD853F'
          },
          total_estimated_cost: budget
        },
        shopping_list: [
          {
            category: "Seating",
            items: ["Sofa", "Accent Chair"],
            priority: "high"
          },
          {
            category: "Tables",
            items: ["Coffee Table", "Side Table"],
            priority: "medium"
          }
        ],
        design_notes: `This ${style} design focuses on functionality while maintaining aesthetic appeal within your $${budget} budget.`
      };
    }

    // Save the generated layout
    const { data: design, error: designError } = await supabase
      .from('designs')
      .insert([{
        user_id: req.user.userId,
        room_id: roomId,
        style: style,
        budget: budget,
        ai_response: JSON.stringify(aiResponse),
        preferences: preferences || null,
        created_at: new Date().toISOString()
      }])
      .select()
      .single();

    if (designError) {
      console.error('Failed to save design:', designError);
    }

    res.json({
      message: 'AI layout generated successfully',
      design_id: design?.id,
      layout: aiResponse
    });

  } catch (error) {
    console.error('AI generation error:', error);
    res.status(500).json({ 
      error: 'Failed to generate layout',
      details: error.message 
    });
  }
});

// Get style suggestions based on room type
router.get('/styles/:roomType', async (req, res) => {
  try {
    const { roomType } = req.params;
    
    const styleRecommendations = {
      living_room: [
        { name: 'Modern', description: 'Clean lines, neutral colors, minimalist furniture' },
        { name: 'Scandinavian', description: 'Light woods, whites, cozy textiles' },
        { name: 'Industrial', description: 'Metal accents, exposed brick, dark colors' },
        { name: 'Bohemian', description: 'Rich colors, patterns, eclectic mix' },
        { name: 'Traditional', description: 'Classic furniture, warm colors, formal layout' }
      ],
      bedroom: [
        { name: 'Minimalist', description: 'Simple, uncluttered, neutral palette' },
        { name: 'Romantic', description: 'Soft colors, flowing fabrics, vintage touches' },
        { name: 'Modern', description: 'Sleek furniture, bold accents, functional design' },
        { name: 'Rustic', description: 'Natural materials, warm tones, cozy atmosphere' }
      ],
      kitchen: [
        { name: 'Modern', description: 'Sleek appliances, clean surfaces, functional layout' },
        { name: 'Farmhouse', description: 'Natural materials, vintage elements, warm colors' },
        { name: 'Contemporary', description: 'Latest trends, innovative storage, bold features' },
        { name: 'Traditional', description: 'Classic cabinetry, timeless colors, formal design' }
      ]
    };

    const styles = styleRecommendations[roomType] || styleRecommendations.living_room;

    res.json({ styles });

  } catch (error) {
    console.error('Get styles error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = router;