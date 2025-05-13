import SwiftUI

struct ProcessingOverlay: View {
    let imageData: Data?
    @State private var isAnimated = false
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .opacity(isAnimated ? 0.7 : 0)
            
            // Receipt image with processing overlay
            Group {
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // Fallback if image can't be loaded
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                }
            }
            .frame(
                width: isAnimated ? 280 : UIScreen.main.bounds.width,
                height: isAnimated ? 380 : UIScreen.main.bounds.height
            )
            .clipShape(RoundedRectangle(cornerRadius: isAnimated ? 24 : 0))
            .shadow(color: .black.opacity(0.3), radius: isAnimated ? 15 : 0, x: 0, y: 5)
            .overlay {
                // Simplified mesh gradient overlay
                animatedMeshGradient
                    .opacity(0.5)
                    .clipShape(RoundedRectangle(cornerRadius: isAnimated ? 24 : 0))
                
                // Processing indicator
                VStack {
                    Spacer()
                    
                    // Simplified indicator layout
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .frame(height: 90)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.3)
                                .tint(.white)
                            
                            Text("Processing receipt...")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.bottom, 30)
                    .opacity(isAnimated ? 1 : 0)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 2, dampingFraction: 0.7)) {
                isAnimated = true
            }
        }
    }
    
    // Extracted mesh gradient as a computed property
    private var animatedMeshGradient: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSince1970
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    // Top row
                    [0, 0], [0.5, 0], [1, 0],
                    
                    // Middle row with animated center point
                    [0, 0.5],
                    [0.5 + 0.2 * Float(sin(time)), 0.5 + 0.2 * Float(cos(time))],
                    [1, 0.5],
                    
                    // Bottom row
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    // Simplified color palette
                    .blue.opacity(0.7), .purple.opacity(0.7), .indigo.opacity(0.7),
                    .cyan.opacity(0.7), .teal.opacity(0.7), .mint.opacity(0.7),
                    .blue.opacity(0.7), .purple.opacity(0.7), .indigo.opacity(0.7)
                ],
                background: .clear,
                smoothsColors: true
            )
        }
    }
}

extension View {
    func processingOverlay(isShowing: Bool, imageData: Data?) -> some View {
        ZStack {
            self
            
            if isShowing {
                ProcessingOverlay(imageData: imageData)
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    ZStack {
        VStack {
            Text("Background Content")
                .font(.largeTitle)
            
            Text("This is the main app view behind the overlay")
        }
        
        // For preview purposes, create a sample image
        ProcessingOverlay(imageData: UIImage(systemName: "doc.text.image")?.pngData())
    }
}
