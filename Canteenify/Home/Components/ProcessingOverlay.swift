import SwiftUI

struct ProcessingOverlay: View {
    let imageData: Data?
    @State private var isAnimated = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .edgesIgnoringSafeArea(.all)
                .opacity(isAnimated ? 1 : 0)
            
            Group {
                if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                }
            }
            .frame(
                width: isAnimated ? 280 : UIScreen.main.bounds.width,
                height: isAnimated ? 380 : UIScreen.main.bounds.height
            )
            .overlay {
                animatedMeshGradient
                    .opacity(0.5)
                VStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.3)
                            .tint(.white)
                        
                        Text("Processing receipt...")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                }
                .padding(8)
            }
            .cornerRadius(isAnimated ? 24 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 2, dampingFraction: 0.7)) {
                isAnimated = true
            }
        }
    }
    
    private var animatedMeshGradient: some View {
        TimelineView(.animation(minimumInterval: 0.05, paused: false)) { timeline in
            let time = timeline.date.timeIntervalSince1970
            
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    SIMD2<Float>(0, 0),
                    SIMD2<Float>(0.5 + 0.1 * Float(sin(time * 0.7)), 0),
                    SIMD2<Float>(1, 0),
                    
                    SIMD2<Float>(0, 0.5 + 0.1 * Float(sin(time * 0.8))),
                    SIMD2<Float>(0.5 + 0.3 * Float(sin(time)), 0.5 + 0.3 * Float(cos(time))),
                    SIMD2<Float>(1, 0.5 + 0.1 * Float(sin(time + 1))),
                    
                    SIMD2<Float>(0, 1),
                    SIMD2<Float>(0.5 + 0.1 * Float(cos(time * 0.9)), 1),
                    SIMD2<Float>(1, 1)
                ],
                colors: [
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
        ProcessingOverlay(imageData: UIImage(systemName: "doc.text.image")?.pngData())
    }
}
