import SwiftUI

// Placeholder views for the main app screens
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Welcome to RoomSpace")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("AR-powered interior design at your fingertips")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Home")
        }
    }
}

struct ScanView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "arkit")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Room Scanning")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Scan your room with ARKit to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Start Scanning") {
                    // TODO: Navigate to AR scanning view
                }
                .buttonStyle(PrimaryButtonStyle())
                
                Spacer()
            }
            .navigationTitle("Scan Room")
        }
    }
}

struct DesignsView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Designs")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("View and manage your AI-generated room designs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Designs")
        }
    }
}

struct ShopView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Shop Furniture")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Browse and purchase furniture from our curated collection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Shop")
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = authManager.currentUser {
                    VStack(spacing: 16) {
                        // Profile image placeholder
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(user.fullName.prefix(1).uppercased())
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(spacing: 4) {
                            Text(user.fullName)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Profile options
                        VStack(spacing: 12) {
                            ProfileOptionRow(icon: "gear", title: "Settings", action: {})
                            ProfileOptionRow(icon: "heart", title: "Favorites", action: {})
                            ProfileOptionRow(icon: "questionmark.circle", title: "Help & Support", action: {})
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        Button("Sign Out") {
                            authManager.logout()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }
                } else {
                    Text("Loading profile...")
                }
            }
            .padding()
            .navigationTitle("Profile")
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
    }
}

// Button styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color.secondary.opacity(0.1))
            .foregroundColor(.secondary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview("Home") {
    HomeView()
}

#Preview("Profile") {
    ProfileView()
        .environmentObject(AuthenticationManager())
}