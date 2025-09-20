import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    
    var body: some View {
        NavigationStack {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .onAppear {
            authManager.checkAuthenticationStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
        .environmentObject(RoomScanningManager())
        .environmentObject(DesignManager())
}