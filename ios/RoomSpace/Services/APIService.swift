import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case networkError(String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let message):
            return message
        }
    }
}

class APIService {
    static let shared = APIService()
    
    private let baseURL = "http://localhost:3000/api" // Change this to your backend URL
    private var authToken: String?
    
    private init() {}
    
    func setAuthToken(_ token: String?) {
        self.authToken = token
    }
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: [String: Any]? = nil,
        responseType: T.Type,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header if token exists
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body if provided
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                completion(.failure(.networkError("Failed to serialize request body")))
                return
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            // Handle HTTP error codes
            if httpResponse.statusCode >= 400 {
                if let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = errorResponse["message"] as? String {
                    completion(.failure(.networkError(message)))
                } else {
                    completion(.failure(.networkError("HTTP Error \(httpResponse.statusCode)")))
                }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    // MARK: - Specialized request methods
    
    func uploadRoomScan(
        name: String,
        dimensions: RoomDimensions,
        scanData: String,
        roomType: RoomType,
        budget: Budget,
        style: DesignStyle,
        completion: @escaping (Result<RoomScan, APIError>) -> Void
    ) {
        let body: [String: Any] = [
            "name": name,
            "dimensions": [
                "width": dimensions.width,
                "length": dimensions.length,
                "height": dimensions.height
            ],
            "scanData": scanData,
            "roomType": roomType.rawValue,
            "budget": [
                "min": budget.min,
                "max": budget.max
            ],
            "style": style.rawValue
        ]
        
        request(
            endpoint: "/rooms",
            method: .POST,
            body: body,
            responseType: RoomScan.self,
            completion: completion
        )
    }
    
    func generateDesign(
        roomId: String,
        style: DesignStyle,
        budget: Budget,
        preferences: [String: Any]? = nil,
        completion: @escaping (Result<SavedDesign, APIError>) -> Void
    ) {
        var body: [String: Any] = [
            "roomId": roomId,
            "style": style.rawValue,
            "budget": [
                "min": budget.min,
                "max": budget.max
            ]
        ]
        
        if let preferences = preferences {
            body["preferences"] = preferences
        }
        
        request(
            endpoint: "/designs/generate",
            method: .POST,
            body: body,
            responseType: SavedDesign.self,
            completion: completion
        )
    }
    
    func searchProducts(
        keywords: String,
        category: String? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        sortBy: String = "relevance",
        completion: @escaping (Result<ProductSearchResponse, APIError>) -> Void
    ) {
        var queryItems = [URLQueryItem(name: "keywords", value: keywords)]
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        if let minPrice = minPrice {
            queryItems.append(URLQueryItem(name: "minPrice", value: String(minPrice)))
        }
        if let maxPrice = maxPrice {
            queryItems.append(URLQueryItem(name: "maxPrice", value: String(maxPrice)))
        }
        queryItems.append(URLQueryItem(name: "sortBy", value: sortBy))
        
        var urlComponents = URLComponents(string: baseURL + "/products/search")!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = authToken {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(ProductSearchResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}