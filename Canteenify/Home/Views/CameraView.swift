import SwiftUI
import AVFoundation
import UIKit

struct FullScreenCameraView: View {
    var onImageCaptured: (Data?) -> Void
    @Binding var isPresented: Bool
    @State private var animateUp = false
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.ignoresSafeArea()
            
            // Camera implementation
            CameraContentView(onImageCaptured: { imageData in
                onImageCaptured(imageData)
                withAnimation(.spring()) {
                    animateUp = false
                }
                // Delay dismissal until animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                }
            })
        }
        .offset(y: animateUp ? 0 : UIScreen.main.bounds.height)
        .onAppear {
            withAnimation(.spring()) {
                animateUp = true
            }
        }
    }
}

// This is the actual camera implementation using UIViewControllerRepresentable
struct CameraContentView: UIViewControllerRepresentable {
    var onImageCaptured: (Data?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        
        // Optional: Configure to make it feel more custom
        picker.allowsEditing = false
        picker.showsCameraControls = true
        picker.modalPresentationStyle = .fullScreen
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraContentView
        
        init(_ parent: CameraContentView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image.jpegData(compressionQuality: 0.8))
            } else {
                parent.onImageCaptured(nil)
            }
            // Note: We don't dismiss here - the parent view handles animation
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCaptured(nil)
            // Note: We don't dismiss here - the parent view handles animation
        }
    }
}
