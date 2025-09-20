import Foundation

@MainActor
class DesignManager: ObservableObject {
    @Published var designs: [Design] = []
    @Published var favoriteDesigns: [Design] = []
    @Published var currentDesign: Design?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // AI Generation state
    @Published var isGenerating = false
    @Published var generationProgress: String = ""
    
    private let apiService = APIService.shared
    
    // MARK: - Design Operations
    func loadDesigns() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getDesigns()
            designs = response.designs
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load designs: \(error)")
        }
        
        isLoading = false
    }
    
    func loadFavoriteDesigns() async {
        do {
            let response = try await apiService.getFavoriteDesigns()
            favoriteDesigns = response.designs
        } catch {
            print("Failed to load favorite designs: \(error)")
        }
    }
    
    func generateDesign(
        roomId: String,
        style: DesignStyle,
        budget: Double,
        preferences: String?
    ) async {
        isGenerating = true
        errorMessage = nil
        generationProgress = "Analyzing room dimensions..."
        
        do {
            generationProgress = "Generating layout with AI..."
            
            let response = try await apiService.generateLayout(
                roomId: roomId,
                style: style,
                budget: budget,
                preferences: preferences
            )
            
            generationProgress = "Creating furniture arrangement..."
            
            // Simulate AI processing steps for better UX
            await simulateAIProcessing()
            
            generationProgress = "Finalizing design..."
            
            // Create a new design object from the response
            let newDesign = Design(
                id: response.designId ?? UUID().uuidString,
                userId: "", // Will be filled by API
                roomId: roomId,
                style: style,
                budget: budget,
                aiResponse: response.layout,
                customLayout: nil,
                preferences: preferences,
                notes: nil,
                isFavorite: false,
                createdAt: Date(),
                updatedAt: Date(),
                room: nil
            )
            
            currentDesign = newDesign
            designs.insert(newDesign, at: 0)
            
            generationProgress = "Design completed!"
            
        } catch {
            errorMessage = error.localizedDescription
            generationProgress = "Generation failed"
            print("Failed to generate design: \(error)")
        }
        
        isGenerating = false
        
        // Clear progress after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.generationProgress = ""
        }
    }
    
    private func simulateAIProcessing() async {
        // Simulate AI processing steps with realistic delays
        let steps = [
            "Analyzing room layout...",
            "Selecting furniture pieces...",
            "Optimizing placement...",
            "Calculating costs...",
            "Applying style preferences..."
        ]
        
        for step in steps {
            generationProgress = step
            try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        }
    }
    
    func loadDesign(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getDesign(id: id)
            currentDesign = response.design
            
            // Update the design in the list if it exists
            if let index = designs.firstIndex(where: { $0.id == id }) {
                designs[index] = response.design
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load design: \(error)")
        }
        
        isLoading = false
    }
    
    func updateDesign(
        id: String,
        customLayout: CustomLayout? = nil,
        notes: String? = nil,
        isFavorite: Bool? = nil
    ) async {
        do {
            let response = try await apiService.updateDesign(
                id: id,
                customLayout: customLayout,
                notes: notes,
                isFavorite: isFavorite
            )
            
            // Update current design
            if currentDesign?.id == id {
                currentDesign = response.design
            }
            
            // Update in designs list
            if let index = designs.firstIndex(where: { $0.id == id }) {
                designs[index] = response.design
            }
            
            // Update favorites list if needed
            if let isFavorite = isFavorite {
                if isFavorite {
                    if !favoriteDesigns.contains(where: { $0.id == id }) {
                        favoriteDesigns.append(response.design)
                    }
                } else {
                    favoriteDesigns.removeAll { $0.id == id }
                }
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to update design: \(error)")
        }
    }
    
    func toggleFavorite(designId: String) async {
        guard let design = designs.first(where: { $0.id == designId }) else { return }
        
        await updateDesign(id: designId, isFavorite: !design.isFavorite)
    }
    
    func saveCustomLayout(designId: String, layout: CustomLayout) async {
        await updateDesign(id: designId, customLayout: layout)
    }
    
    func addNotes(designId: String, notes: String) async {
        await updateDesign(id: designId, notes: notes)
    }
    
    // MARK: - Furniture Manipulation
    func addFurniturePiece(
        designId: String,
        piece: FurniturePiece
    ) async {
        guard let design = currentDesign,
              design.id == designId else { return }
        
        var customLayout = design.customLayout ?? CustomLayout(
            modifiedPieces: [],
            addedPieces: [],
            removedPieceIds: [],
            colorSchemeOverride: nil
        )
        
        customLayout.addedPieces.append(piece)
        
        await saveCustomLayout(designId: designId, layout: customLayout)
    }
    
    func removeFurniturePiece(
        designId: String,
        pieceId: String
    ) async {
        guard let design = currentDesign,
              design.id == designId else { return }
        
        var customLayout = design.customLayout ?? CustomLayout(
            modifiedPieces: [],
            addedPieces: [],
            removedPieceIds: [],
            colorSchemeOverride: nil
        )
        
        // Remove from added pieces if it exists there
        customLayout.addedPieces.removeAll { $0.id == pieceId }
        
        // Add to removed pieces if it's from the original AI response
        if design.aiResponse.layout.furniturePieces.contains(where: { $0.id == pieceId }) {
            customLayout.removedPieceIds.append(pieceId)
        }
        
        await saveCustomLayout(designId: designId, layout: customLayout)
    }
    
    func moveFurniturePiece(
        designId: String,
        pieceId: String,
        newPosition: Point3D,
        newRotation: Float? = nil
    ) async {
        guard let design = currentDesign,
              design.id == designId else { return }
        
        var customLayout = design.customLayout ?? CustomLayout(
            modifiedPieces: [],
            addedPieces: [],
            removedPieceIds: [],
            colorSchemeOverride: nil
        )
        
        // Find the piece to modify
        if let originalPiece = design.aiResponse.layout.furniturePieces.first(where: { $0.id == pieceId }) {
            var modifiedPiece = originalPiece
            modifiedPiece.position = newPosition
            if let rotation = newRotation {
                modifiedPiece.rotation = rotation
            }
            
            // Remove any existing modification of this piece
            customLayout.modifiedPieces.removeAll { $0.id == pieceId }
            customLayout.modifiedPieces.append(modifiedPiece)
        }
        
        // Check if it's in added pieces
        if let index = customLayout.addedPieces.firstIndex(where: { $0.id == pieceId }) {
            customLayout.addedPieces[index].position = newPosition
            if let rotation = newRotation {
                customLayout.addedPieces[index].rotation = rotation
            }
        }
        
        await saveCustomLayout(designId: designId, layout: customLayout)
    }
    
    // MARK: - Helper Methods
    func getAllFurniturePieces(for design: Design) -> [FurniturePiece] {
        var allPieces = design.aiResponse.layout.furniturePieces
        
        if let customLayout = design.customLayout {
            // Remove pieces marked for removal
            allPieces.removeAll { piece in
                customLayout.removedPieceIds.contains(piece.id)
            }
            
            // Apply modifications
            for modifiedPiece in customLayout.modifiedPieces {
                if let index = allPieces.firstIndex(where: { $0.id == modifiedPiece.id }) {
                    allPieces[index] = modifiedPiece
                }
            }
            
            // Add new pieces
            allPieces.append(contentsOf: customLayout.addedPieces)
        }
        
        return allPieces
    }
    
    func getEffectiveColorScheme(for design: Design) -> ColorScheme {
        return design.customLayout?.colorSchemeOverride ?? design.aiResponse.layout.colorScheme
    }
    
    func getTotalCost(for design: Design) -> Double {
        let allPieces = getAllFurniturePieces(for: design)
        return allPieces.reduce(0) { $0 + $1.estimatedCost }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearCurrentDesign() {
        currentDesign = nil
    }
}