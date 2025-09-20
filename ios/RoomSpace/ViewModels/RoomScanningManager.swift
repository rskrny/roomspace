import Foundation
import ARKit
import RealityKit

@MainActor
class RoomScanningManager: NSObject, ObservableObject {
    @Published var isScanning = false
    @Published var scanProgress: Float = 0.0
    @Published var scanQuality: ScanQuality = .poor
    @Published var errorMessage: String?
    
    // Current scan data
    @Published var currentScanData: RoomScanData?
    @Published var roomDimensions: RoomDimensions?
    
    // ARKit properties
    private var arView: ARView?
    private var arSession: ARSession?
    private var meshAnchors: [ARMeshAnchor] = []
    private var planeAnchors: [ARPlaneAnchor] = []
    
    // Scan state
    private var scanStartTime: Date?
    private var lastQualityCheck: Date = Date()
    private let qualityCheckInterval: TimeInterval = 2.0
    
    override init() {
        super.init()
        setupARSession()
    }
    
    // MARK: - AR Session Setup
    private func setupARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            errorMessage = "ARKit is not supported on this device"
            return
        }
        
        arSession = ARSession()
        arSession?.delegate = self
    }
    
    func startScanning(with arView: ARView) {
        guard ARWorldTrackingConfiguration.isSupported else {
            errorMessage = "ARKit is not supported on this device"
            return
        }
        
        self.arView = arView
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        // Enable scene reconstruction if available (iOS 13.4+)
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            configuration.sceneReconstruction = .mesh
        }
        
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        isScanning = true
        scanProgress = 0.0
        scanStartTime = Date()
        meshAnchors.removeAll()
        planeAnchors.removeAll()
        errorMessage = nil
        
        // Start quality monitoring
        scheduleQualityCheck()
    }
    
    func stopScanning() {
        isScanning = false
        scanProgress = 1.0
        
        // Process the collected data
        processScanData()
    }
    
    func resetScan() {
        isScanning = false
        scanProgress = 0.0
        currentScanData = nil
        roomDimensions = nil
        meshAnchors.removeAll()
        planeAnchors.removeAll()
        errorMessage = nil
        
        // Reset AR session
        arView?.session.pause()
    }
    
    // MARK: - Scan Data Processing
    private func processScanData() {
        guard !meshAnchors.isEmpty || !planeAnchors.isEmpty else {
            errorMessage = "No scan data collected. Please try scanning again."
            return
        }
        
        // Extract walls from vertical planes
        let walls = extractWalls(from: planeAnchors)
        
        // Extract floors from horizontal planes
        let floors = extractFloors(from: planeAnchors)
        
        // Calculate room dimensions
        let dimensions = calculateRoomDimensions(from: walls, floors: floors)
        
        // Extract doors and windows (simplified detection)
        let doors = detectDoors(from: walls)
        let windows = detectWindows(from: walls)
        
        // Extract obstacles
        let obstacles = detectObstacles(from: meshAnchors)
        
        // Convert mesh data
        let meshData = convertMeshData(from: meshAnchors)
        
        // Determine scan quality
        let quality = assessScanQuality()
        
        let scanData = RoomScanData(
            walls: walls,
            floors: floors,
            doors: doors,
            windows: windows,
            obstacles: obstacles,
            meshData: meshData,
            scanQuality: quality,
            scanDate: Date()
        )
        
        currentScanData = scanData
        roomDimensions = dimensions
        scanQuality = quality
    }
    
    private func extractWalls(from planes: [ARPlaneAnchor]) -> [WallData] {
        let verticalPlanes = planes.filter { plane in
            let normal = plane.transform.columns.1
            return abs(normal.y) < 0.3 // Nearly vertical
        }
        
        return verticalPlanes.enumerated().map { index, plane in
            let center = plane.center
            let extent = plane.extent
            
            return WallData(
                id: plane.identifier.uuidString,
                startPoint: Point3D(
                    x: center.x - extent.x/2,
                    y: center.y,
                    z: center.z - extent.z/2
                ),
                endPoint: Point3D(
                    x: center.x + extent.x/2,
                    y: center.y,
                    z: center.z + extent.z/2
                ),
                height: 2.5, // Default room height
                thickness: 0.15, // Default wall thickness
                hasWindows: false, // Will be updated by window detection
                hasDoors: false    // Will be updated by door detection
            )
        }
    }
    
    private func extractFloors(from planes: [ARPlaneAnchor]) -> [FloorData] {
        let horizontalPlanes = planes.filter { plane in
            let normal = plane.transform.columns.1
            return abs(normal.y) > 0.7 // Nearly horizontal
        }
        
        return horizontalPlanes.map { plane in
            let center = plane.center
            let extent = plane.extent
            
            // Create floor vertices (simplified rectangle)
            let vertices = [
                Point3D(x: center.x - extent.x/2, y: center.y, z: center.z - extent.z/2),
                Point3D(x: center.x + extent.x/2, y: center.y, z: center.z - extent.z/2),
                Point3D(x: center.x + extent.x/2, y: center.y, z: center.z + extent.z/2),
                Point3D(x: center.x - extent.x/2, y: center.y, z: center.z + extent.z/2)
            ]
            
            return FloorData(
                vertices: vertices,
                material: "unknown",
                area: extent.x * extent.z
            )
        }
    }
    
    private func calculateRoomDimensions(from walls: [WallData], floors: [FloorData]) -> RoomDimensions {
        guard let floor = floors.first else {
            return RoomDimensions(width: 3.0, height: 2.5, depth: 3.0)
        }
        
        let minX = floor.vertices.map(\.x).min() ?? 0
        let maxX = floor.vertices.map(\.x).max() ?? 3
        let minZ = floor.vertices.map(\.z).min() ?? 0
        let maxZ = floor.vertices.map(\.z).max() ?? 3
        
        return RoomDimensions(
            width: maxX - minX,
            height: 2.5, // Default ceiling height
            depth: maxZ - minZ
        )
    }
    
    private func detectDoors(from walls: [WallData]) -> [DoorData] {
        // Simplified door detection - in a real app this would be more sophisticated
        return []
    }
    
    private func detectWindows(from walls: [WallData]) -> [WindowData] {
        // Simplified window detection - in a real app this would be more sophisticated
        return []
    }
    
    private func detectObstacles(from meshAnchors: [ARMeshAnchor]) -> [ObstacleData] {
        // Simplified obstacle detection
        return []
    }
    
    private func convertMeshData(from meshAnchors: [ARMeshAnchor]) -> MeshData? {
        guard let firstMesh = meshAnchors.first else { return nil }
        
        let geometry = firstMesh.geometry
        let vertices = (0..<geometry.vertices.count).map { index in
            let vertex = geometry.vertices[index]
            return Point3D(x: vertex.x, y: vertex.y, z: vertex.z)
        }
        
        // Convert faces (simplified)
        let faces = Array(0..<geometry.faces.count).map { faceIndex in
            [Int(faceIndex * 3), Int(faceIndex * 3 + 1), Int(faceIndex * 3 + 2)]
        }
        
        return MeshData(
            vertices: vertices,
            faces: faces,
            normals: nil,
            textureCoordinates: nil
        )
    }
    
    private func assessScanQuality() -> ScanQuality {
        guard let scanStartTime = scanStartTime else { return .poor }
        
        let scanDuration = Date().timeIntervalSince(scanStartTime)
        let planeCoverage = planeAnchors.count
        let meshCoverage = meshAnchors.count
        
        if scanDuration > 30 && planeCoverage >= 4 && meshCoverage > 10 {
            return .excellent
        } else if scanDuration > 20 && planeCoverage >= 3 && meshCoverage > 5 {
            return .good
        } else if scanDuration > 15 && planeCoverage >= 2 {
            return .fair
        } else {
            return .poor
        }
    }
    
    private func scheduleQualityCheck() {
        DispatchQueue.main.asyncAfter(deadline: .now() + qualityCheckInterval) { [weak self] in
            guard let self = self, self.isScanning else { return }
            
            self.updateScanProgress()
            self.scanQuality = self.assessScanQuality()
            
            self.scheduleQualityCheck()
        }
    }
    
    private func updateScanProgress() {
        guard let scanStartTime = scanStartTime else { return }
        
        let scanDuration = Date().timeIntervalSince(scanStartTime)
        let targetDuration: TimeInterval = 30 // Target scan time
        
        scanProgress = min(Float(scanDuration / targetDuration), 1.0)
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - ARSessionDelegate
extension RoomScanningManager: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                meshAnchors.append(meshAnchor)
            } else if let planeAnchor = anchor as? ARPlaneAnchor {
                planeAnchors.append(planeAnchor)
            }
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                if let index = meshAnchors.firstIndex(where: { $0.identifier == meshAnchor.identifier }) {
                    meshAnchors[index] = meshAnchor
                }
            } else if let planeAnchor = anchor as? ARPlaneAnchor {
                if let index = planeAnchors.firstIndex(where: { $0.identifier == planeAnchor.identifier }) {
                    planeAnchors[index] = planeAnchor
                }
            }
        }
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            if let meshAnchor = anchor as? ARMeshAnchor {
                meshAnchors.removeAll { $0.identifier == meshAnchor.identifier }
            } else if let planeAnchor = anchor as? ARPlaneAnchor {
                planeAnchors.removeAll { $0.identifier == planeAnchor.identifier }
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        errorMessage = "AR Session failed: \(error.localizedDescription)"
        isScanning = false
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Handle session interruption
        isScanning = false
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Handle session interruption end
        // Optionally restart scanning
    }
}