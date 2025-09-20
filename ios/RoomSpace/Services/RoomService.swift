import Foundation
import Combine

class RoomService: ObservableObject {
    @Published var rooms: [RoomScan] = []
    @Published var currentRoom: RoomScan?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func fetchRooms() {
        isLoading = true
        errorMessage = nil
        
        apiService.request(
            endpoint: "/rooms",
            method: .GET,
            responseType: RoomListResponse.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let response):
                    self?.rooms = response.rooms
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func createRoom(
        name: String,
        dimensions: RoomDimensions,
        scanData: String,
        roomType: RoomType,
        budget: Budget,
        style: DesignStyle
    ) {
        isLoading = true
        errorMessage = nil
        
        apiService.uploadRoomScan(
            name: name,
            dimensions: dimensions,
            scanData: scanData,
            roomType: roomType,
            budget: budget,
            style: style
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let room):
                    self?.rooms.insert(room, at: 0)
                    self?.currentRoom = room
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteRoom(_ roomId: String) {
        apiService.request(
            endpoint: "/rooms/\(roomId)",
            method: .DELETE,
            responseType: APIResponse<String>.self
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.rooms.removeAll { $0.id == roomId }
                    if self?.currentRoom?.id == roomId {
                        self?.currentRoom = nil
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}