import Foundation
import simd

// MARK: - Room Models
struct Room: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let roomType: RoomType
    let dimensions: RoomDimensions
    let scanData: RoomScanData
    let imageUrl: String?
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case roomType = "room_type"
        case dimensions
        case scanData = "scan_data"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum RoomType: String, CaseIterable, Codable {
    case livingRoom = "living_room"
    case bedroom = "bedroom"
    case kitchen = "kitchen"
    case bathroom = "bathroom"
    case diningRoom = "dining_room"
    case office = "office"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .livingRoom: return "Living Room"
        case .bedroom: return "Bedroom"
        case .kitchen: return "Kitchen"
        case .bathroom: return "Bathroom"
        case .diningRoom: return "Dining Room"
        case .office: return "Office"
        case .other: return "Other"
        }
    }
}

struct RoomDimensions: Codable {
    let width: Float
    let height: Float
    let depth: Float
    
    var area: Float {
        return width * depth
    }
    
    var volume: Float {
        return width * height * depth
    }
}

struct RoomScanData: Codable {
    let walls: [WallData]
    let floors: [FloorData]
    let doors: [DoorData]
    let windows: [WindowData]
    let obstacles: [ObstacleData]
    let meshData: MeshData?
    let scanQuality: ScanQuality
    let scanDate: Date
    
    enum CodingKeys: String, CodingKey {
        case walls, floors, doors, windows, obstacles
        case meshData = "mesh_data"
        case scanQuality = "scan_quality"
        case scanDate = "scan_date"
    }
}

struct WallData: Codable, Identifiable {
    let id: String
    let startPoint: Point3D
    let endPoint: Point3D
    let height: Float
    let thickness: Float
    let hasWindows: Bool
    let hasDoors: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case startPoint = "start_point"
        case endPoint = "end_point"
        case height, thickness
        case hasWindows = "has_windows"
        case hasDoors = "has_doors"
    }
}

struct FloorData: Codable {
    let vertices: [Point3D]
    let material: String?
    let area: Float
}

struct DoorData: Codable, Identifiable {
    let id: String
    let position: Point3D
    let width: Float
    let height: Float
    let direction: Float // rotation in radians
    let type: DoorType
}

enum DoorType: String, Codable {
    case hinged = "hinged"
    case sliding = "sliding"
    case french = "french"
    case pocket = "pocket"
}

struct WindowData: Codable, Identifiable {
    let id: String
    let position: Point3D
    let width: Float
    let height: Float
    let wallId: String
    let type: WindowType
    
    enum CodingKeys: String, CodingKey {
        case id, position, width, height
        case wallId = "wall_id"
        case type
    }
}

enum WindowType: String, Codable {
    case standard = "standard"
    case bay = "bay"
    case casement = "casement"
    case sliding = "sliding"
    case french = "french"
}

struct ObstacleData: Codable, Identifiable {
    let id: String
    let position: Point3D
    let dimensions: RoomDimensions
    let type: ObstacleType
    let isRemovable: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, position, dimensions, type
        case isRemovable = "is_removable"
    }
}

enum ObstacleType: String, Codable {
    case pillar = "pillar"
    case fireplace = "fireplace"
    case builtInStorage = "built_in_storage"
    case hvac = "hvac"
    case other = "other"
}

struct MeshData: Codable {
    let vertices: [Point3D]
    let faces: [[Int]]
    let normals: [Point3D]?
    let textureCoordinates: [Point2D]?
    
    enum CodingKeys: String, CodingKey {
        case vertices, faces, normals
        case textureCoordinates = "texture_coordinates"
    }
}

struct Point3D: Codable {
    let x: Float
    let y: Float
    let z: Float
    
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(from simdFloat3: simd_float3) {
        self.x = simdFloat3.x
        self.y = simdFloat3.y
        self.z = simdFloat3.z
    }
    
    var simdFloat3: simd_float3 {
        return simd_float3(x, y, z)
    }
}

struct Point2D: Codable {
    let x: Float
    let y: Float
}

enum ScanQuality: String, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    var description: String {
        switch self {
        case .excellent: return "Excellent - High detail scan with complete room coverage"
        case .good: return "Good - Detailed scan with minor gaps"
        case .fair: return "Fair - Basic scan with some missing details"
        case .poor: return "Poor - Incomplete scan, rescan recommended"
        }
    }
    
    var color: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .fair: return "orange"
        case .poor: return "red"
        }
    }
}