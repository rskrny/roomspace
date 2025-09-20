import SwiftUI
import ARKit
import RealityKit

struct ARScannerView: View {
    @State private var isScanning = false
    @State private var showingSetup = true
    @State private var scanProgress: Float = 0.0
    @State private var scanningInstructions = "Point your camera at the room and slowly move around"
    
    var body: some View {
        ZStack {
            if showingSetup {
                ScanSetupView(onStartScanning: {
                    showingSetup = false
                    isScanning = true
                })
            } else {
                ARScanningInterface(
                    isScanning: $isScanning,
                    scanProgress: $scanProgress,
                    instructions: $scanningInstructions,
                    onComplete: handleScanComplete,
                    onCancel: {
                        showingSetup = true
                        isScanning = false
                        scanProgress = 0.0
                    }
                )
            }
        }
    }
    
    private func handleScanComplete(scanData: String, dimensions: RoomDimensions) {
        // Navigate to room configuration view
        showingSetup = true
        isScanning = false
        scanProgress = 0.0
    }
}

struct ScanSetupView: View {
    let onStartScanning: () -> Void
    @State private var selectedRoomType = RoomType.livingRoom
    @State private var roomName = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "arkit")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Room Scanner")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Use your camera to scan and measure your room in 3D")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Room Information
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Room Information")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            TextField("Room Name", text: $roomName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Text("Room Type")
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Picker("Room Type", selection: $selectedRoomType) {
                                    ForEach(RoomType.allCases, id: \.self) { roomType in
                                        Text(roomType.displayName).tag(roomType)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Scanning Instructions")
                            .font(.headline)
                        
                        VStack(spacing: 12) {
                            InstructionRow(
                                icon: "lightbulb.fill",
                                text: "Ensure good lighting in the room"
                            )
                            
                            InstructionRow(
                                icon: "camera.rotate",
                                text: "Move slowly and point at walls, floor, and ceiling"
                            )
                            
                            InstructionRow(
                                icon: "ruler.fill",
                                text: "Walk around the entire room perimeter"
                            )
                            
                            InstructionRow(
                                icon: "checkmark.circle.fill",
                                text: "Wait for the green checkmarks to appear"
                            )
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Start Button
                    Button(action: onStartScanning) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("Start Scanning")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(roomName.isEmpty)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct ARScanningInterface: View {
    @Binding var isScanning: Bool
    @Binding var scanProgress: Float
    @Binding var instructions: String
    
    let onComplete: (String, RoomDimensions) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            // AR View (placeholder - in a real implementation this would be ARView)
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            // Overlay UI
            VStack {
                // Top Instructions
                VStack(spacing: 8) {
                    Text(instructions)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Progress Bar
                    ProgressView(value: scanProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .frame(width: 200)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Bottom Controls
                HStack(spacing: 40) {
                    Button(action: onCancel) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        // Simulate scan completion
                        let mockScanData = "mock_scan_data_base64"
                        let mockDimensions = RoomDimensions(width: 12.0, length: 15.0, height: 9.0)
                        onComplete(mockScanData, mockDimensions)
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .background(Color.green.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .disabled(scanProgress < 0.8) // Enable when scan is mostly complete
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Start simulating scan progress
            simulateScanProgress()
        }
    }
    
    private func simulateScanProgress() {
        // Simulate scanning progress for demo purposes
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if scanProgress < 1.0 {
                scanProgress += 0.02
                
                // Update instructions based on progress
                switch scanProgress {
                case 0.0...0.3:
                    instructions = "Point your camera at the walls and slowly move around"
                case 0.3...0.6:
                    instructions = "Good! Continue mapping the floor and ceiling"
                case 0.6...0.8:
                    instructions = "Almost done! Fill in any missing areas"
                default:
                    instructions = "Room scan complete! Tap the checkmark to finish"
                }
            } else {
                timer.invalidate()
            }
        }
    }
}

// Placeholder ARView - in a real implementation this would use RealityKit
struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        
        // Add a label to indicate this is a placeholder
        let label = UILabel()
        label.text = "AR Camera View\n(ARKit Implementation)"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update ARView if needed
    }
}

#Preview {
    ARScannerView()
}