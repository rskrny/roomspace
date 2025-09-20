import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "arkit")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("RoomSpace")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("AR-Powered Interior Design")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Form
            VStack(spacing: 16) {
                // Toggle between login and register
                Picker("Mode", selection: $isLoginMode) {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Form fields
                VStack(spacing: 12) {
                    if !isLoginMode {
                        TextField("Full Name", text: $fullName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !isLoginMode {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(.horizontal)
                
                // Error message
                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Submit button
                Button(action: handleSubmit) {
                    HStack {
                        if authManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isLoginMode ? "Login" : "Create Account")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(authManager.isLoading || !isFormValid)
                .padding(.horizontal)
                
                // Social login placeholder
                HStack {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("or")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Rectangle()
                        .fill(Color.secondary.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.horizontal)
                
                // Social buttons (placeholder)
                VStack(spacing: 8) {
                    Button("Continue with Apple") {
                        // TODO: Implement Apple Sign In
                    }
                    .buttonStyle(SocialButtonStyle(backgroundColor: .black))
                    
                    Button("Continue with Google") {
                        // TODO: Implement Google Sign In
                    }
                    .buttonStyle(SocialButtonStyle(backgroundColor: .blue))
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: isLoginMode) { _ in
            authManager.clearError()
        }
    }
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !fullName.isEmpty && 
                   password == confirmPassword &&
                   password.count >= 6
        }
    }
    
    private func handleSubmit() {
        hideKeyboard()
        authManager.clearError()
        
        Task {
            if isLoginMode {
                await authManager.login(email: email, password: password)
            } else {
                await authManager.register(email: email, password: password, fullName: fullName)
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SocialButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager())
}