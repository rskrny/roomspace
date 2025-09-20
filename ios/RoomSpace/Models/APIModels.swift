import Foundation

// MARK: - API Response Models

struct MessageResponse: Codable {
    let message: String
}

struct ProfileResponse: Codable {
    let user: User
}

struct RoomsResponse: Codable {
    let rooms: [Room]
}

struct RoomResponse: Codable {
    let message: String
    let room: Room
}

struct DesignsResponse: Codable {
    let designs: [Design]
}

struct DesignDetailResponse: Codable {
    let message: String
    let design: Design
}

struct ProductsResponse: Codable {
    let products: [Product]
    let totalCount: Int
    let filters: ProductFilters
    
    enum CodingKeys: String, CodingKey {
        case products
        case totalCount = "totalCount"
        case filters
    }
}

struct ProductDetailResponse: Codable {
    let product: ProductDetail
}

struct ProductRecommendationsResponse: Codable {
    let designId: String
    let recommendations: [ProductRecommendation]
    let totalProducts: Int
    
    enum CodingKeys: String, CodingKey {
        case designId
        case recommendations
        case totalProducts = "totalProducts"
    }
}

// MARK: - API Request Models

struct CreateRoomRequest: Codable {
    let name: String
    let roomType: RoomType
    let dimensions: RoomDimensions
    let scanData: RoomScanData
    
    enum CodingKeys: String, CodingKey {
        case name
        case roomType = "roomType"
        case dimensions
        case scanData = "scanData"
    }
}

struct UpdateRoomRequest: Codable {
    let name: String?
    let roomType: RoomType?
    let dimensions: RoomDimensions?
    let scanData: RoomScanData?
    
    enum CodingKeys: String, CodingKey {
        case name
        case roomType = "roomType"
        case dimensions
        case scanData = "scanData"
    }
}

struct GenerateLayoutRequest: Codable {
    let roomId: String
    let style: String
    let budget: Double
    let preferences: String?
    
    enum CodingKeys: String, CodingKey {
        case roomId
        case style
        case budget
        case preferences
    }
}

struct UpdateDesignRequest: Codable {
    let customLayout: CustomLayout?
    let notes: String?
    let isFavorite: Bool?
    
    enum CodingKeys: String, CodingKey {
        case customLayout = "customLayout"
        case notes
        case isFavorite = "isFavorite"
    }
}

struct TrackClickRequest: Codable {
    let productId: String
    let designId: String?
    let clickSource: String?
    
    enum CodingKeys: String, CodingKey {
        case productId
        case designId
        case clickSource = "clickSource"
    }
}

// MARK: - Product Models

struct Product: Codable, Identifiable {
    let id: String
    let title: String
    let price: Double
    let originalPrice: Double?
    let category: String
    let brand: String
    let rating: Double
    let reviewCount: Int
    let imageUrl: String
    let amazonUrl: String
    let description: String
    let features: [String]
    let dimensions: ProductDimensions?
    let colors: [String]
    let inStock: Bool
    let primeEligible: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, category, brand, rating, description, features, colors
        case originalPrice = "originalPrice"
        case reviewCount = "reviewCount"
        case imageUrl = "imageUrl"
        case amazonUrl = "amazonUrl"
        case dimensions
        case inStock = "inStock"
        case primeEligible = "primeEligible"
    }
}

struct ProductDetail: Codable, Identifiable {
    let id: String
    let title: String
    let price: Double
    let originalPrice: Double?
    let category: String
    let brand: String
    let rating: Double
    let reviewCount: Int
    let imageUrl: String
    let imageGallery: [String]
    let amazonUrl: String
    let description: String
    let longDescription: String
    let features: [String]
    let specifications: ProductSpecifications
    let colors: [ProductColor]
    let inStock: Bool
    let primeEligible: Bool
    let deliveryInfo: DeliveryInfo
    let warranty: String
    let returnPolicy: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, category, brand, rating, description, features, specifications, colors, warranty
        case originalPrice = "originalPrice"
        case reviewCount = "reviewCount"
        case imageUrl = "imageUrl"
        case imageGallery = "imageGallery"
        case amazonUrl = "amazonUrl"
        case longDescription = "longDescription"
        case inStock = "inStock"
        case primeEligible = "primeEligible"
        case deliveryInfo = "deliveryInfo"
        case returnPolicy = "returnPolicy"
    }
}

struct ProductDimensions: Codable {
    let width: Double
    let height: Double
    let depth: Double
}

struct ProductSpecifications: Codable {
    let dimensions: ProductDimensions
    let weight: Double
    let material: String
    let frameMaterial: String?
    let seatDepth: Double?
    let seatHeight: Double?
    
    enum CodingKeys: String, CodingKey {
        case dimensions, weight, material
        case frameMaterial = "frameMaterial"
        case seatDepth = "seatDepth"
        case seatHeight = "seatHeight"
    }
}

struct ProductColor: Codable {
    let name: String
    let hex: String
    let available: Bool
}

struct DeliveryInfo: Codable {
    let freeShipping: Bool
    let estimatedDelivery: String
    let whiteGloveDelivery: Bool
    let assemblyIncluded: Bool
    
    enum CodingKeys: String, CodingKey {
        case freeShipping = "freeShipping"
        case estimatedDelivery = "estimatedDelivery"
        case whiteGloveDelivery = "whiteGloveDelivery"
        case assemblyIncluded = "assemblyIncluded"
    }
}

struct ProductFilters: Codable {
    let category: String?
    let minPrice: Double?
    let maxPrice: Double?
    let style: String?
    let keywords: String?
    
    enum CodingKeys: String, CodingKey {
        case category
        case minPrice = "minPrice"
        case maxPrice = "maxPrice"
        case style
        case keywords
    }
}

struct ProductRecommendation: Codable {
    let furnitureItem: String
    let products: [RecommendedProduct]
    
    enum CodingKeys: String, CodingKey {
        case furnitureItem = "furnitureItem"
        case products
    }
}

struct RecommendedProduct: Codable, Identifiable {
    let id: String
    let title: String
    let price: Double
    let rating: Double
    let imageUrl: String
    let amazonUrl: String
    let matchScore: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, price, rating
        case imageUrl = "imageUrl"
        case amazonUrl = "amazonUrl"
        case matchScore = "matchScore"
    }
}