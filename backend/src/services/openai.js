const OpenAI = require('openai');

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

const generateDesign = async ({ room, style, budget, preferences = {} }) => {
  try {
    const prompt = `
      Create an interior design layout for a ${room.room_type} with the following specifications:
      
      Room Dimensions: ${room.dimensions.width}ft x ${room.dimensions.length}ft x ${room.dimensions.height}ft
      Style: ${style}
      Budget: $${budget.min} - $${budget.max}
      
      ${preferences.colors ? `Preferred Colors: ${preferences.colors.join(', ')}` : ''}
      ${preferences.furniture ? `Preferred Furniture: ${preferences.furniture.join(', ')}` : ''}
      ${preferences.avoid ? `Avoid: ${preferences.avoid.join(', ')}` : ''}
      
      Please provide:
      1. A furniture layout with specific item placements
      2. A list of recommended furniture items with estimated prices
      3. Color scheme recommendations
      4. Lighting suggestions
      5. Accessory recommendations
      
      Format the response as JSON with the following structure:
      {
        "layout": {
          "description": "Overall layout description",
          "zones": [
            {
              "name": "Zone name",
              "furniture": ["furniture items"],
              "position": {"x": number, "y": number, "rotation": number}
            }
          ]
        },
        "furnitureItems": [
          {
            "name": "Item name",
            "category": "Category",
            "estimatedPrice": number,
            "position": {"x": number, "y": number, "z": number},
            "dimensions": {"width": number, "depth": number, "height": number},
            "searchTerms": ["search", "terms", "for", "amazon"]
          }
        ],
        "colorScheme": {
          "primary": "#color",
          "secondary": "#color",
          "accent": "#color"
        },
        "lighting": ["lighting suggestions"],
        "accessories": ["accessory suggestions"],
        "totalCost": estimated_total_cost
      }
    `;

    const completion = await openai.chat.completions.create({
      model: "gpt-4",
      messages: [
        {
          role: "system",
          content: "You are an expert interior designer with knowledge of furniture placement, color theory, and budget-conscious design. Provide practical, implementable design suggestions."
        },
        {
          role: "user",
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 2000
    });

    const response = completion.choices[0].message.content;
    
    // Try to parse the JSON response
    try {
      const designData = JSON.parse(response);
      return designData;
    } catch (parseError) {
      console.error('Failed to parse OpenAI response as JSON:', parseError);
      
      // Fallback response if JSON parsing fails
      return {
        layout: {
          description: "AI-generated layout based on your preferences",
          zones: []
        },
        furnitureItems: [],
        colorScheme: {
          primary: getStyleColors(style).primary,
          secondary: getStyleColors(style).secondary,
          accent: getStyleColors(style).accent
        },
        lighting: ["Natural light optimization", "Ambient lighting"],
        accessories: ["Style-appropriate accessories"],
        totalCost: Math.floor((budget.min + budget.max) / 2),
        aiResponse: response
      };
    }
  } catch (error) {
    console.error('OpenAI API error:', error);
    
    // Fallback design data
    return {
      layout: {
        description: `${style} design for your ${room.room_type}`,
        zones: [
          {
            name: "Main seating area",
            furniture: ["Sofa", "Coffee table"],
            position: { x: 0, y: 0, rotation: 0 }
          }
        ]
      },
      furnitureItems: [
        {
          name: `${style} Sofa`,
          category: "Seating",
          estimatedPrice: Math.floor(budget.max * 0.4),
          position: { x: 0, y: 0, z: 0 },
          dimensions: { width: 72, depth: 36, height: 32 },
          searchTerms: [style.toLowerCase(), "sofa", room.room_type]
        }
      ],
      colorScheme: getStyleColors(style),
      lighting: ["Natural light", "Floor lamps"],
      accessories: ["Throw pillows", "Wall art"],
      totalCost: Math.floor((budget.min + budget.max) / 2),
      error: 'Used fallback design due to AI service error'
    };
  }
};

const getStyleColors = (style) => {
  const colorSchemes = {
    modern: { primary: "#2C3E50", secondary: "#ECF0F1", accent: "#E74C3C" },
    minimalist: { primary: "#FFFFFF", secondary: "#F8F9FA", accent: "#6C757D" },
    scandinavian: { primary: "#FFFFFF", secondary: "#F5F5DC", accent: "#4A90E2" },
    industrial: { primary: "#34495E", secondary: "#95A5A6", accent: "#E67E22" },
    bohemian: { primary: "#8B4513", secondary: "#DEB887", accent: "#CD853F" }
  };
  
  return colorSchemes[style] || colorSchemes.modern;
};

module.exports = {
  generateDesign
};