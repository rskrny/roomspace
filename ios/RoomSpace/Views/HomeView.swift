import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var roomService: RoomService
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 8) {
                    if let user = authService.currentUser {
                        Text("Welcome back, \(user.firstName)!")
                            .font(.title2)
                            .fontWeight(.bold)
                    } else {
                        Text("Welcome to RoomSpace")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    Text("Transform your space with AR-powered interior design")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        QuickActionCard(
                            icon: "camera.viewfinder",
                            title: "Scan Room",
                            subtitle: "Start with AR scanning",
                            color: .blue
                        )
                        
                        QuickActionCard(
                            icon: "paintbrush.pointed",
                            title: "Browse Styles",
                            subtitle: "Explore design options",
                            color: .purple
                        )
                        
                        QuickActionCard(
                            icon: "cube.box",
                            title: "My Rooms",
                            subtitle: "View saved rooms",
                            color: .orange
                        )
                        
                        QuickActionCard(
                            icon: "cart",
                            title: "Shop Furniture",
                            subtitle: "Find perfect pieces",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Recent Rooms
                if !roomService.rooms.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Recent Rooms")
                                .font(.headline)
                            
                            Spacer()
                            
                            NavigationLink("See All") {
                                RoomListView()
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(Array(roomService.rooms.prefix(5))) { room in
                                    NavigationLink(destination: RoomDetailView(room: room)) {
                                        RoomCard(room: room)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Tips Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pro Tips")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        TipCard(
                            icon: "lightbulb",
                            title: "Best Lighting",
                            description: "Scan your room in good natural light for best results"
                        )
                        
                        TipCard(
                            icon: "ruler",
                            title: "Room Measurements",
                            description: "Walk slowly around the room to capture accurate dimensions"
                        )
                        
                        TipCard(
                            icon: "dollarsign.circle",
                            title: "Budget Planning",
                            description: "Set realistic budgets to get better furniture recommendations"
                        )
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            roomService.fetchRooms()
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct RoomCard: View {
    let room: RoomScan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Room Type Icon
            Image(systemName: roomTypeIcon(room.roomType))
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(room.roomType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(Int(room.dimensions.width))' × \(Int(room.dimensions.length))'")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 140, height: 100)
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

struct TipCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// Placeholder views for navigation
struct RoomDetailView: View {
    let room: RoomScan
    
    var body: some View {
        Text("Room Detail: \(room.name)")
            .navigationTitle(room.name)
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
    .environmentObject(AuthenticationService())
    .environmentObject(RoomService())
}