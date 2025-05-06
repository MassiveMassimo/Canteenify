import SwiftUI
import PhotosUI

struct BottomActions: View {
    @Bindable var viewModel: HomePage.HomeViewModel
    
    // State for UI
    @State private var isShowingCamera = false
    @State private var galleryPickerItem: PhotosPickerItem?
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Text("Scan receipt from")
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                HStack(spacing: 0) {
                    Button(action: {
                        isShowingCamera = true
                    }) {
                        Label("Photo", systemImage: "camera")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                    }
                    
                    Divider()
                        .frame(width:1)
                        .background(Color.white.opacity(0.3))
                        .padding(.vertical, 8)
                        .cornerRadius(.infinity)
                    
                    // Using PhotosPicker for Gallery
                    PhotosPicker(
                        selection: $galleryPickerItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Gallery", systemImage: "photo.on.rectangle")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 48)
                .background(Color.accentColor)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            .background(
                VariableBlurView(maxBlurRadius: 20, direction: .blurredBottomClearTop)
                    .allowsHitTesting(false)
                    .padding(.top, -64)
                    .padding(.bottom, -52)
            )
        }
        .padding(.bottom)
        .onChange(of: galleryPickerItem) { _, newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    // Pass to the view model
                    await MainActor.run {
                        viewModel.handleReceiptImageSelected(data)
                    }
                }
                // Reset the picker item
                galleryPickerItem = nil
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            // Create your camera view UI here
            // When an image is captured:
            // viewModel.handleReceiptImageSelected(imageData)
        }
    }
}

#Preview {
    BottomActions(viewModel: HomePage.HomeViewModel())
}
