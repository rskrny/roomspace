import Foundation

// MARK: - User Models
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let profileImageUrl: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImageUrl = "profile_image_url"
        case createdAt = "created_at"
    }
}

struct AuthResponse: Codable {
    let message: String
    let token: String
    let user: User
}

// MARK: - Room Models
struct RoomDimensions: Codable {
    let width: Double
    let length: Double
    let height: Double
}

struct Budget: Codable {
    let min: Double
    let max: Double
}

enum RoomType: String, CaseIterable, Codable {
    case livingRoom = "living_room"
    case bedroom = "bedroom"
    case kitchen = "kitchen"
    case diningRoom = "dining_room"
    case office = "office"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .livingRoom: return "Living Room"
        case .bedroom: return "Bedroom"
        case .kitchen: return "Kitchen"
        case .diningRoom: return "Dining Room"
        case .office: return "Office"
        case .other: return "Other"
        }
    }
}

enum DesignStyle: String, CaseIterable, Codable {
    case modern = "modern"
    case minimalist = "minimalist"
    case scandinavian = "scandinavian"
    case industrial = "industrial"
    case bohemian = "bohemian"
    
    var displayName: String {
        switch self {
        case .modern: return "Modern"
        case .minimalist: return "Minimalist"
        case .scandinavian: return "Scandinavian"
        case .industrial: return "Industrial"
        case .bohemian: return "Bohemian"
        }
    }
}

struct RoomScan: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let roomType: RoomType
    let dimensions: RoomDimensions
    let scanData: String // Base64 encoded ARKit data
    let budgetMin: Double
    let budgetMax: Double
    let style: DesignStyle
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case roomType = "room_type"
        case dimensions
        case scanData = "scan_data"
        case budgetMin = "budget_min"
        case budgetMax = "budget_max"
        case style
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var budget: Budget {
        Budget(min: budgetMin, max: budgetMax)
    }
}

// MARK: - Design Models
struct FurniturePosition: Codable {
    let x: Double
    let y: Double
    let z: Double
}

struct FurnitureDimensions: Codable {
    let width: Double
    let depth: Double
    let height: Double
}

struct FurnitureItem: Codable, Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let estimatedPrice: Double
    let position: FurniturePosition
    let dimensions: FurnitureDimensions
    let searchTerms: [String]
    
    enum CodingKeys: String, CodingKey {
        case name, category
        case estimatedPrice = "estimated_price"
        case position, dimensions
        case searchTerms = "search_terms"
    }
}

struct ColorScheme: Codable {
    let primary: String
    let secondary: String
    let accent: String
}

struct DesignLayout: Codable {
    let description: String
    let zones: [DesignZone]
}

struct DesignZone: Codable {
    let name: String
    let furniture: [String]
    let position: FurniturePosition
    let rotation: Double?
}

struct DesignData: Codable {
    let layout: DesignLayout
    let furnitureItems: [FurnitureItem]
    let colorScheme: ColorScheme
    let lighting: [String]
    let accessories: [String]
    let totalCost: Double
}

struct SavedDesign: Codable, Identifiable {
    let id: String
    let userId: String
    let roomId: String
    let style: DesignStyle
    let budgetMin: Double
    let budgetMax: Double
    let designData: DesignData
    let furnitureItems: [FurnitureItem]
    let totalCost: Double
    let isFavorite: Bool
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case roomId = "room_id"
        case style
        case budgetMin = "budget_min"
        case budgetMax = "budget_max"
        case designData = "design_data"
        case furnitureItems = "furniture_items"
        case totalCost = "total_cost"
        case isFavorite = "is_favorite"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Product Models
struct ProductPrice: Codable {
    let amount: Double
    let currency: String
}

struct ProductImages: Codable {
    let primary: String
    let thumbnails: [String]
}

struct Product: Codable, Identifiable {
    let id = UUID()
    let asin: String
    let title: String
    let price: ProductPrice
    let images: ProductImages
    let rating: String
    let reviewCount: Int
    let features: [String]
    let affiliateUrl: String
    let availability: String
    
    enum CodingKeys: String, CodingKey {
        case asin, title, price, images, rating, features, availability
        case reviewCount = "review_count"
        case affiliateUrl = "affiliate_url"
    }
}

// MARK: - API Response Models
struct APIResponse<T: Codable>: Codable {
    let message: String?
    let data: T?
    let error: String?
}

struct RoomListResponse: Codable {
    let rooms: [RoomScan]
}

struct DesignListResponse: Codable {
    let designs: [SavedDesign]
}

struct ProductSearchResponse: Codable {
    let products: [Product]
    let total: Int
}