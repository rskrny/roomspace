import Foundation

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let keychain = KeychainService()
    private let apiService = APIService.shared
    
    private let tokenKey = "auth_token"
    private let userKey = "current_user"
    
    private init() {}
    
    var authToken: String? {
        return keychain.load(key: tokenKey)
    }
    
    func checkAuthenticationStatus() {
        if let token = keychain.load(key: tokenKey),
           let userData = keychain.load(key: userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData.data(using: .utf8) ?? Data()) {
            
            self.isAuthenticated = true
            self.currentUser = user
            
            // Optionally refresh user profile from server
            Task {
                await refreshUserProfile()
            }
        } else {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            
            // Save token and user data
            keychain.save(key: tokenKey, data: response.token)
            
            if let userData = try? JSONEncoder().encode(response.user),
               let userString = String(data: userData, encoding: .utf8) {
                keychain.save(key: userKey, data: userString)
            }
            
            // Update UI state
            isAuthenticated = true
            currentUser = response.user
            
        } catch {
            errorMessage = error.localizedDescription
            print("Login error: \(error)")
        }
        
        isLoading = false
    }
    
    func register(email: String, password: String, fullName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.register(email: email, password: password, fullName: fullName)
            
            // Save token and user data
            keychain.save(key: tokenKey, data: response.token)
            
            if let userData = try? JSONEncoder().encode(response.user),
               let userString = String(data: userData, encoding: .utf8) {
                keychain.save(key: userKey, data: userString)
            }
            
            // Update UI state
            isAuthenticated = true
            currentUser = response.user
            
        } catch {
            errorMessage = error.localizedDescription
            print("Registration error: \(error)")
        }
        
        isLoading = false
    }
    
    func logout() {
        // Clear keychain
        keychain.delete(key: tokenKey)
        keychain.delete(key: userKey)
        
        // Update UI state
        isAuthenticated = false
        currentUser = nil
        errorMessage = nil
    }
    
    func refreshUserProfile() async {
        do {
            let response = try await apiService.getUserProfile()
            currentUser = response.user
            
            // Update stored user data
            if let userData = try? JSONEncoder().encode(response.user),
               let userString = String(data: userData, encoding: .utf8) {
                keychain.save(key: userKey, data: userString)
            }
        } catch {
            print("Failed to refresh user profile: \(error)")
            // Don't update error message as this is a background operation
        }
    }
    
    func updateProfile(fullName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.updateProfile(fullName: fullName)
            currentUser = response.user
            
            // Update stored user data
            if let userData = try? JSONEncoder().encode(response.user),
               let userString = String(data: userData, encoding: .utf8) {
                keychain.save(key: userKey, data: userString)
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("Profile update error: \(error)")
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Keychain Service
class KeychainService {
    
    func save(key: String, data: String) {
        let data = data.data(using: .utf8)!
        
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject? = nil
        
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            if let data = dataTypeRef as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
    }
}