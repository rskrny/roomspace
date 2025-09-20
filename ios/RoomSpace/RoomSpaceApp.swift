import SwiftUI

@main
struct RoomSpaceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthenticationManager())
                .environmentObject(RoomScanningManager())
                .environmentObject(DesignManager())
        }
    }
}