import Foundation

// MARK: - Design Models
struct Design: Codable, Identifiable {
    let id: String
    let userId: String
    let roomId: String
    let style: DesignStyle
    let budget: Double
    let aiResponse: AILayoutResponse
    let customLayout: CustomLayout?
    let preferences: String?
    let notes: String?
    let isFavorite: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Associated room data (from joined query)
    let room: Room?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case roomId = "room_id"
        case style, budget
        case aiResponse = "ai_response"
        case customLayout = "custom_layout"
        case preferences, notes
        case isFavorite = "is_favorite"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case room
    }
}

enum DesignStyle: String, CaseIterable, Codable {
    case modern = "modern"
    case traditional = "traditional"
    case scandinavian = "scandinavian"
    case industrial = "industrial"
    case bohemian = "bohemian"
    case minimalist = "minimalist"
    case rustic = "rustic"
    case contemporary = "contemporary"
    
    var displayName: String {
        switch self {
        case .modern: return "Modern"
        case .traditional: return "Traditional"
        case .scandinavian: return "Scandinavian"
        case .industrial: return "Industrial"
        case .bohemian: return "Bohemian"
        case .minimalist: return "Minimalist"
        case .rustic: return "Rustic"
        case .contemporary: return "Contemporary"
        }
    }
    
    var description: String {
        switch self {
        case .modern: return "Clean lines, neutral colors, minimalist furniture"
        case .traditional: return "Classic furniture, warm colors, formal layout"
        case .scandinavian: return "Light woods, whites, cozy textiles"
        case .industrial: return "Metal accents, exposed brick, dark colors"
        case .bohemian: return "Rich colors, patterns, eclectic mix"
        case .minimalist: return "Simple, uncluttered, neutral palette"
        case .rustic: return "Natural materials, warm tones, cozy atmosphere"
        case .contemporary: return "Latest trends, innovative design, bold features"
        }
    }
}

struct AILayoutResponse: Codable {
    let layout: FurnitureLayout
    let shoppingList: [ShoppingCategory]
    let designNotes: String
    
    enum CodingKeys: String, CodingKey {
        case layout
        case shoppingList = "shopping_list"
        case designNotes = "design_notes"
    }
}

struct FurnitureLayout: Codable {
    let furniturePieces: [FurniturePiece]
    let colorScheme: ColorScheme
    let totalEstimatedCost: Double
    
    enum CodingKeys: String, CodingKey {
        case furniturePieces = "furniture_pieces"
        case colorScheme = "color_scheme"
        case totalEstimatedCost = "total_estimated_cost"
    }
}

struct FurniturePiece: Codable, Identifiable {
    let id: String
    let item: String
    let category: FurnitureCategory
    let position: Point3D
    let rotation: Float
    let dimensions: RoomDimensions
    let estimatedCost: Double
    let description: String
    let productId: String?
    let isPlaced: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, item, category, position, rotation, dimensions, description
        case estimatedCost = "estimated_cost"
        case productId = "product_id"
        case isPlaced = "is_placed"
    }
}

enum FurnitureCategory: String, CaseIterable, Codable {
    case seating = "seating"
    case tables = "tables"
    case storage = "storage"
    case lighting = "lighting"
    case decor = "decor"
    case textiles = "textiles"
    case plants = "plants"
    case electronics = "electronics"
    case art = "art"
    
    var displayName: String {
        switch self {
        case .seating: return "Seating"
        case .tables: return "Tables"
        case .storage: return "Storage"
        case .lighting: return "Lighting"
        case .decor: return "Decor"
        case .textiles: return "Textiles"
        case .plants: return "Plants"
        case .electronics: return "Electronics"
        case .art: return "Art"
        }
    }
}

struct ColorScheme: Codable {
    let primary: String
    let secondary: String
    let accent: String
    
    var primaryColor: String { primary }
    var secondaryColor: String { secondary }
    var accentColor: String { accent }
}

struct ShoppingCategory: Codable {
    let category: String
    let items: [String]
    let priority: Priority
}

enum Priority: String, Codable {
    case high = "high"
    case medium = "medium"
    case low = "low"
    
    var displayName: String {
        switch self {
        case .high: return "High Priority"
        case .medium: return "Medium Priority"
        case .low: return "Low Priority"
        }
    }
}

struct CustomLayout: Codable {
    let modifiedPieces: [FurniturePiece]
    let addedPieces: [FurniturePiece]
    let removedPieceIds: [String]
    let colorSchemeOverride: ColorScheme?
    
    enum CodingKeys: String, CodingKey {
        case modifiedPieces = "modified_pieces"
        case addedPieces = "added_pieces"
        case removedPieceIds = "removed_piece_ids"
        case colorSchemeOverride = "color_scheme_override"
    }
}

// MARK: - API Response Models
struct DesignResponse: Codable {
    let message: String
    let designId: String?
    let layout: AILayoutResponse
    
    enum CodingKeys: String, CodingKey {
        case message
        case designId = "design_id"
        case layout
    }
}

struct StyleRecommendation: Codable {
    let name: String
    let description: String
}

struct StylesResponse: Codable {
    let styles: [StyleRecommendation]
}