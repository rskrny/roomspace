import SwiftUI

struct DesignListView: View {
    @State private var designs: [SavedDesign] = []
    @State private var isLoading = false
    
    var body: some View {
        List {
            ForEach(designs) { design in
                NavigationLink(destination: DesignDetailView(design: design)) {
                    DesignRowView(design: design)
                }
            }
        }
        .navigationTitle("My Designs")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            loadDesigns()
        }
        .overlay {
            if designs.isEmpty && !isLoading {
                EmptyDesignsView()
            }
        }
        .onAppear {
            loadDesigns()
        }
    }
    
    private func loadDesigns() {
        isLoading = true
        // TODO: Load designs from API
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
    }
}

struct DesignRowView: View {
    let design: SavedDesign
    
    var body: some View {
        HStack(spacing: 12) {
            // Design thumbnail placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay {
                    Image(systemName: "paintbrush.pointed")
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Room Design")
                    .font(.headline)
                
                Text(design.style.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(Int(design.totalCost))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text(design.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if design.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyDesignsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "paintbrush.pointed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Designs Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first design by scanning a room and selecting a style")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct DesignDetailView: View {
    let design: SavedDesign
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Design preview placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay {
                        VStack {
                            Image(systemName: "arkit")
                                .font(.system(size: 40))
                            Text("3D Design Preview")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                    }
                
                // Design info
                VStack(alignment: .leading, spacing: 12) {
                    Text("Design Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Style")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(design.style.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Total Cost")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(Int(design.totalCost))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Furniture list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Furniture Items")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(design.furnitureItems) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(Int(item.estimatedPrice))")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Design")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        DesignListView()
    }
}