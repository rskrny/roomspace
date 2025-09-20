import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthenticationService
    @State private var showingSignOutAlert = false
    
    var body: some View {
        List {
            // User Info Section
            Section {
                HStack(spacing: 16) {
                    // Profile Image Placeholder
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Text(userInitials)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let user = authService.currentUser {
                            Text("\(user.firstName) \(user.lastName)")
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 8)
            }
            
            // Stats Section
            Section("Stats") {
                HStack {
                    Image(systemName: "cube.box")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Scanned Rooms")
                    Spacer()
                    Text("0") // TODO: Connect to actual data
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "paintbrush.pointed")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    Text("Saved Designs")
                    Spacer()
                    Text("0") // TODO: Connect to actual data
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    Text("Favorite Products")
                    Spacer()
                    Text("0") // TODO: Connect to actual data
                        .foregroundColor(.secondary)
                }
            }
            
            // Settings Section
            Section("Settings") {
                NavigationLink(destination: NotificationsSettingsView()) {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Text("Notifications")
                    }
                }
                
                NavigationLink(destination: PrivacySettingsView()) {
                    HStack {
                        Image(systemName: "hand.raised")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Privacy")
                    }
                }
                
                NavigationLink(destination: AboutView()) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("About")
                    }
                }
            }
            
            // Support Section
            Section("Support") {
                Link(destination: URL(string: "mailto:support@roomspace.app")!) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        Text("Contact Support")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Link(destination: URL(string: "https://roomspace.app/help")!) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Help Center")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Account Section
            Section("Account") {
                Button(action: {
                    showingSignOutAlert = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                authService.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
    
    private var userInitials: String {
        guard let user = authService.currentUser else { return "?" }
        let firstInitial = user.firstName.prefix(1).uppercased()
        let lastInitial = user.lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
}

// MARK: - Settings Views

struct NotificationsSettingsView: View {
    @State private var pushNotifications = true
    @State private var emailNotifications = false
    @State private var marketingEmails = false
    
    var body: some View {
        List {
            Section(footer: Text("Receive notifications about your room scans and design updates")) {
                Toggle("Push Notifications", isOn: $pushNotifications)
                Toggle("Email Notifications", isOn: $emailNotifications)
            }
            
            Section(footer: Text("Receive emails about new features and special offers")) {
                Toggle("Marketing Emails", isOn: $marketingEmails)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section(footer: Text("Learn how we protect your privacy and handle your data")) {
                Link(destination: URL(string: "https://roomspace.app/privacy")!) {
                    Text("Privacy Policy")
                }
                
                Link(destination: URL(string: "https://roomspace.app/terms")!) {
                    Text("Terms of Service")
                }
            }
            
            Section("Data Management") {
                NavigationLink("Download My Data") {
                    Text("Download Data") // Placeholder view
                }
                
                Button("Delete Account") {
                    // TODO: Implement account deletion
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "arkit")
                        .font(.largeTitle)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("RoomSpace")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            
            Section("About") {
                Text("RoomSpace is an AR-powered interior design app that helps you visualize and shop for furniture in your space.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Section("Developers") {
                Text("Built with ❤️ using SwiftUI and ARKit")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
    .environmentObject(AuthenticationService())
}