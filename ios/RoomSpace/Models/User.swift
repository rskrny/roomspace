import Foundation

// MARK: - User Models
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    let avatarUrl: String?
    let preferences: UserPreferences?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case preferences
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct UserPreferences: Codable {
    let preferredStyles: [String]
    let budgetRange: BudgetRange
    let roomTypes: [String]
    let notifications: NotificationSettings
}

struct BudgetRange: Codable {
    let min: Double
    let max: Double
}

struct NotificationSettings: Codable {
    let pushNotifications: Bool
    let emailNotifications: Bool
    let designUpdates: Bool
    let newFeatures: Bool
}

// MARK: - Authentication Models
struct AuthResponse: Codable {
    let message: String
    let token: String
    let user: User
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case email, password
        case fullName = "fullName"
    }
}