import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("RoomSpace")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("AR-Powered Interior Design")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Button("Start Room Scan") {
                    // TODO: Implement ARKit room scanning
                    print("Starting room scan...")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("View My Designs") {
                    // TODO: Navigate to saved designs
                    print("Viewing designs...")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
            .navigationTitle("RoomSpace")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}