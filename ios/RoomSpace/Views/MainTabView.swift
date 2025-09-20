import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            ScanView()
                .tabItem {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan")
                }
            
            DesignsView()
                .tabItem {
                    Image(systemName: "paintbrush")
                    Text("Designs")
                }
            
            ShopView()
                .tabItem {
                    Image(systemName: "bag")
                    Text("Shop")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationManager())
        .environmentObject(RoomScanningManager())
        .environmentObject(DesignManager())
}