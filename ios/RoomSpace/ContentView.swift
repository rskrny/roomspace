import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var roomService = RoomService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
                    .environmentObject(roomService)
            } else {
                AuthenticationView()
                    .environmentObject(authService)
            }
        }
        .onAppear {
            authService.checkAuthenticationStatus()
        }
    }
}

#Preview {
    ContentView()
}