import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var roomService: RoomService
    
    var body: some View {
        TabView {
            // Home Tab - Room Scanning
            NavigationView {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }
            
            // Rooms Tab
            NavigationView {
                RoomListView()
            }
            .tabItem {
                Image(systemName: "cube.box")
                Text("Rooms")
            }
            
            // AR Scanner Tab
            ARScannerView()
            .tabItem {
                Image(systemName: "camera.viewfinder")
                Text("Scan")
            }
            
            // Designs Tab
            NavigationView {
                DesignListView()
            }
            .tabItem {
                Image(systemName: "paintbrush")
                Text("Designs")
            }
            
            // Profile Tab
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.circle")
                Text("Profile")
            }
        }
        .accentColor(.blue)
        .onAppear {
            roomService.fetchRooms()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationService())
        .environmentObject(RoomService())
}