import SwiftUI

struct RoomListView: View {
    @EnvironmentObject var roomService: RoomService
    
    var body: some View {
        List {
            ForEach(roomService.rooms) { room in
                NavigationLink(destination: RoomDetailView(room: room)) {
                    RoomRowView(room: room)
                }
            }
            .onDelete(perform: deleteRooms)
        }
        .navigationTitle("My Rooms")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: ARScannerView()) {
                    Image(systemName: "plus")
                }
            }
        }
        .refreshable {
            roomService.fetchRooms()
        }
        .overlay {
            if roomService.rooms.isEmpty && !roomService.isLoading {
                EmptyRoomsView()
            }
        }
    }
    
    private func deleteRooms(offsets: IndexSet) {
        for index in offsets {
            let room = roomService.rooms[index]
            roomService.deleteRoom(room.id)
        }
    }
}

struct RoomRowView: View {
    let room: RoomScan
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: roomTypeIcon(room.roomType))
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                
                Text(room.roomType.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("\(Int(room.dimensions.width))' × \(Int(room.dimensions.length))'")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(room.style.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func roomTypeIcon(_ roomType: RoomType) -> String {
        switch roomType {
        case .livingRoom: return "sofa"
        case .bedroom: return "bed.double"
        case .kitchen: return "refrigerator"
        case .diningRoom: return "table.furniture"
        case .office: return "desktopcomputer"
        case .other: return "house.rooms"
        }
    }
}

struct EmptyRoomsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cube.box")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Rooms Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start by scanning your first room with the AR camera")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            NavigationLink(destination: ARScannerView()) {
                HStack {
                    Image(systemName: "camera.viewfinder")
                    Text("Scan Your First Room")
                        .fontWeight(.semibold)
                }
                .frame(width: 200, height: 44)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

#Preview {
    NavigationView {
        RoomListView()
    }
    .environmentObject(RoomService())
}