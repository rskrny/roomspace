import Foundation
import Combine

class AuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    private let keychain = KeychainService()
    
    init() {
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        if let token = keychain.getAuthToken() {
            // Verify token is still valid
            apiService.setAuthToken(token)
            isAuthenticated = true
            // TODO: Fetch current user details
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        let loginData = ["email": email, "password": password]
        
        apiService.request(
            endpoint: "/auth/login",
            method: .POST,
            body: loginData,
            responseType: AuthResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let authResponse):
                    self?.keychain.saveAuthToken(authResponse.token)
                    self?.apiService.setAuthToken(authResponse.token)
                    self?.currentUser = authResponse.user
                    self?.isAuthenticated = true
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signUp(email: String, password: String, firstName: String, lastName: String) {
        isLoading = true
        errorMessage = nil
        
        let registerData = [
            "email": email,
            "password": password,
            "firstName": firstName,
            "lastName": lastName
        ]
        
        apiService.request(
            endpoint: "/auth/register",
            method: .POST,
            body: registerData,
            responseType: AuthResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let authResponse):
                    self?.keychain.saveAuthToken(authResponse.token)
                    self?.apiService.setAuthToken(authResponse.token)
                    self?.currentUser = authResponse.user
                    self?.isAuthenticated = true
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        keychain.deleteAuthToken()
        apiService.setAuthToken(nil)
        currentUser = nil
        isAuthenticated = false
    }
    
    // MARK: - Social Authentication
    func signInWithGoogle() {
        // TODO: Implement Google Sign In
        errorMessage = "Google Sign In not implemented yet"
    }
    
    func signInWithApple() {
        // TODO: Implement Apple Sign In
        errorMessage = "Apple Sign In not implemented yet"
    }
}

// MARK: - Keychain Service
class KeychainService {
    private let tokenKey = "com.roomspace.auth.token"
    
    func saveAuthToken(_ token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getAuthToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    func deleteAuthToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}