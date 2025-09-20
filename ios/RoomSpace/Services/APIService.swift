import Foundation

class APIService: ObservableObject {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000/api"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Generic API Request Method
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if token exists
        if let token = AuthenticationManager.shared.authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                if let errorData = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw APIError.serverError(errorData.error)
                }
                throw APIError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(responseType, from: data)
            
        } catch {
            if error is APIError {
                throw error
            }
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Authentication Endpoints
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/auth/login",
            method: .POST,
            body: data,
            responseType: AuthResponse.self
        )
    }
    
    func register(email: String, password: String, fullName: String) async throws -> AuthResponse {
        let request = RegisterRequest(email: email, password: password, fullName: fullName)
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/auth/register",
            method: .POST,
            body: data,
            responseType: AuthResponse.self
        )
    }
    
    func getUserProfile() async throws -> ProfileResponse {
        return try await makeRequest(
            endpoint: "/auth/profile",
            responseType: ProfileResponse.self
        )
    }
    
    func updateProfile(fullName: String) async throws -> AuthResponse {
        let request = ["fullName": fullName]
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/auth/profile",
            method: .PUT,
            body: data,
            responseType: AuthResponse.self
        )
    }
    
    // MARK: - Room Endpoints
    func getRooms() async throws -> RoomsResponse {
        return try await makeRequest(
            endpoint: "/rooms",
            responseType: RoomsResponse.self
        )
    }
    
    func createRoom(name: String, roomType: RoomType, dimensions: RoomDimensions, scanData: RoomScanData) async throws -> RoomResponse {
        let request = CreateRoomRequest(
            name: name,
            roomType: roomType,
            dimensions: dimensions,
            scanData: scanData
        )
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/rooms",
            method: .POST,
            body: data,
            responseType: RoomResponse.self
        )
    }
    
    func getRoom(id: String) async throws -> RoomResponse {
        return try await makeRequest(
            endpoint: "/rooms/\(id)",
            responseType: RoomResponse.self
        )
    }
    
    func updateRoom(id: String, name: String?, roomType: RoomType?, dimensions: RoomDimensions?, scanData: RoomScanData?) async throws -> RoomResponse {
        let request = UpdateRoomRequest(
            name: name,
            roomType: roomType,
            dimensions: dimensions,
            scanData: scanData
        )
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/rooms/\(id)",
            method: .PUT,
            body: data,
            responseType: RoomResponse.self
        )
    }
    
    func deleteRoom(id: String) async throws -> MessageResponse {
        return try await makeRequest(
            endpoint: "/rooms/\(id)",
            method: .DELETE,
            responseType: MessageResponse.self
        )
    }
    
    // MARK: - Design Endpoints
    func generateLayout(roomId: String, style: DesignStyle, budget: Double, preferences: String?) async throws -> DesignResponse {
        let request = GenerateLayoutRequest(
            roomId: roomId,
            style: style.rawValue,
            budget: budget,
            preferences: preferences
        )
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/ai/generate-layout",
            method: .POST,
            body: data,
            responseType: DesignResponse.self
        )
    }
    
    func getDesigns() async throws -> DesignsResponse {
        return try await makeRequest(
            endpoint: "/designs",
            responseType: DesignsResponse.self
        )
    }
    
    func getDesign(id: String) async throws -> DesignDetailResponse {
        return try await makeRequest(
            endpoint: "/designs/\(id)",
            responseType: DesignDetailResponse.self
        )
    }
    
    func updateDesign(id: String, customLayout: CustomLayout?, notes: String?, isFavorite: Bool?) async throws -> DesignDetailResponse {
        let request = UpdateDesignRequest(
            customLayout: customLayout,
            notes: notes,
            isFavorite: isFavorite
        )
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/designs/\(id)",
            method: .PUT,
            body: data,
            responseType: DesignDetailResponse.self
        )
    }
    
    func getFavoriteDesigns() async throws -> DesignsResponse {
        return try await makeRequest(
            endpoint: "/designs/favorites/list",
            responseType: DesignsResponse.self
        )
    }
    
    // MARK: - Product Endpoints
    func searchProducts(category: String?, minPrice: Double?, maxPrice: Double?, keywords: String?) async throws -> ProductsResponse {
        var queryItems: [URLQueryItem] = []
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        if let minPrice = minPrice {
            queryItems.append(URLQueryItem(name: "minPrice", value: String(minPrice)))
        }
        if let maxPrice = maxPrice {
            queryItems.append(URLQueryItem(name: "maxPrice", value: String(maxPrice)))
        }
        if let keywords = keywords {
            queryItems.append(URLQueryItem(name: "keywords", value: keywords))
        }
        
        var components = URLComponents(string: "\(baseURL)/products/search")!
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        if let token = AuthenticationManager.shared.authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await session.data(for: request)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(ProductsResponse.self, from: data)
    }
    
    func getProductRecommendations(designId: String) async throws -> ProductRecommendationsResponse {
        return try await makeRequest(
            endpoint: "/products/recommendations/\(designId)",
            responseType: ProductRecommendationsResponse.self
        )
    }
    
    func trackAffiliateClick(productId: String, designId: String?, clickSource: String?) async throws -> MessageResponse {
        let request = TrackClickRequest(
            productId: productId,
            designId: designId,
            clickSource: clickSource
        )
        let data = try JSONEncoder().encode(request)
        
        return try await makeRequest(
            endpoint: "/products/track-click",
            method: .POST,
            body: data,
            responseType: MessageResponse.self
        )
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

// MARK: - API Error Types
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case httpError(Int)
    case serverError(String)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .serverError(let message):
            return message
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        }
    }
}

struct APIErrorResponse: Codable {
    let error: String
}