import SwiftUI
import PhotosUI

struct Receipt: View {
    
    let order: OrderItem
    @Bindable var viewModel: HomePage.ViewModel
    var namespace: Namespace.ID
    
    @State private var isShowingCamera: Bool = false
    @State private var galleryPickerItem: PhotosPickerItem?
    @State private var showCDPending: Bool = false
    @State private var showCDMismatch: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("№")
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                            .fixedSize()
                        Text("\(order.orderNumberTail)")
                            .font(.system(size: 24, design: .monospaced))
                            .fontWeight(.semibold)
                            .fixedSize()
                    }
                    Label {
                        Text(order.verificationStatus.rawValue.lowercased())
                            .font(.system(size: 10))
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .fixedSize()
                    } icon: {
                        EmptyView()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusGradient)
                    .cornerRadius(9999)
                    .foregroundColor(statusTextColor)
                }
                Spacer()
                HStack(alignment: .bottom, spacing: 4) {
                    Text("Rp")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 2)
                    Text(formattedPrice)
                        .font(.system(size: 20, design: .monospaced))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Constants.gray100, location: 0.00),
                        Gradient.Stop(color: .white, location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
            .clipShape(PerforatedEdges(), style: FillStyle(eoFill: true))
            .matchedTransitionSource(id: order.id, in: namespace)
            .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 2)
            .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 0)
            
            actionButton
                .padding(.horizontal, 16)
                .frame(maxHeight: .infinity)
                .background(actionBackgroundColor)
                .clipShape(PerforatedEdges(), style: FillStyle(eoFill: true))
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 2)
        }
        .padding(0)
        .frame(maxWidth: .infinity, maxHeight: 72, alignment: .topLeading)
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
        .overlay {
            if isShowingCamera {
                FullScreenCameraView(
                    onImageCaptured: { imageData in
                        if let imageData = imageData {
                            viewModel.handleReceiptImageSelected(imageData)
                        }
                    },
                    isPresented: $isShowingCamera
                )
                .ignoresSafeArea()
            }
        }
    }
}

private extension Receipt {
    @ViewBuilder
    var actionButton: some View {
        switch order.verificationStatus {
        case .verified:
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Constants.gray200, location: 0.00),
                                Gradient.Stop(color: .white, location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.green)
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 2)
                    .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 0)
            }
        case .pending:
            Button(action: {
                showCDPending = true
            }) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Constants.amber400)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 2)
                    .shadow(color: .black.opacity(0.02), radius: 3, x: 0, y: 0)
            }
            .confirmationDialog(
                "Scan Payment Proof",
                isPresented: $showCDPending,
                titleVisibility: .visible
            ) {
                Button("Take Photo") {
                    isShowingCamera = true
                }
                
                PhotosPicker(
                    selection: $galleryPickerItem,
                    matching: .images
                ) {
                    Text("Choose from Gallery")
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select how you would like to scan your payment proof")
            }
        case .mismatch:
            Button(action: {
                showCDMismatch = true
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Constants.red400)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 0)
            }
            .confirmationDialog(
                "Rescan Document",
                isPresented: $showCDMismatch,
                titleVisibility: .visible
            ) {
                Button("Receipt") {
                    
                }
                
                Button("Payment Proof") {
                    
                }
                
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Select which document you would like to rescan")
            }
        }
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        if let formattedString = formatter.string(from: NSNumber(value: order.price)) {
            return formattedString
        }
        
        return "\(order.price)"
    }
    
    var actionBackgroundColor: some ShapeStyle {
        switch order.verificationStatus {
        case .verified:
            return AnyShapeStyle(LinearGradient(
                stops: [
                    Gradient.Stop(color: Constants.gray100, location: 0.00),
                    Gradient.Stop(color: .white, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            ))
        case .pending:
            return AnyShapeStyle(Constants.amber200)
        case .mismatch:
            return AnyShapeStyle(Constants.red200)
        }
    }
    
    var statusGradient: LinearGradient {
        switch order.verificationStatus {
        case .verified:
            return LinearGradient(
                stops: [
                    Gradient.Stop(color: Constants.green200, location: 0.00),
                    Gradient.Stop(color: Constants.green50, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
        case .pending:
            return LinearGradient(
                stops: [
                    Gradient.Stop(color: Constants.amber200, location: 0.00),
                    Gradient.Stop(color: Constants.amber50, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
        case .mismatch:
            return LinearGradient(
                stops: [
                    Gradient.Stop(color: Constants.red200, location: 0.00),
                    Gradient.Stop(color: Constants.red50, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            )
        }
    }
    var statusTextColor: Color {
        switch order.verificationStatus {
        case .verified:
            return Constants.green700
        case .pending:
            return Constants.amber700
        case .mismatch:
            return Constants.red700
        }
    }
}

struct PerforatedEdges: Shape {
    let holeRadius: CGFloat = 8
    let spacing: CGFloat = 10
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addRect(rect)
        
        let holeCount = Int((rect.height / (holeRadius * 2 + spacing))+2)
        let totalHoleHeight = CGFloat(holeCount) * (holeRadius * 2) + CGFloat(holeCount - 1) * spacing
        let startY = (rect.height - totalHoleHeight) / 2
        
        for i in 0..<holeCount {
            let y = startY + CGFloat(i) * (holeRadius * 2 + spacing)
            let centerY = y + holeRadius
            path.addEllipse(in: CGRect(
                x: -holeRadius,
                y: centerY - holeRadius,
                width: holeRadius * 2,
                height: holeRadius * 2
            ))
            path.addEllipse(in: CGRect(
                x: rect.width - holeRadius,
                y: centerY - holeRadius,
                width: holeRadius * 2,
                height: holeRadius * 2
            ))
        }
        
        return path
    }
}

#Preview {
    @Previewable @State var viewModel = HomePage.ViewModel()
    @Previewable @Namespace var previewNamespace
    
    let sampleOrders = OrderItem.sampleOrders
    let previewOrders: [OrderItem] = [
        sampleOrders.first(where: { $0.verificationStatus == .pending }),
        sampleOrders.first(where: { $0.verificationStatus == .verified }),
        sampleOrders.first(where: { $0.verificationStatus == .mismatch })
    ].compactMap { $0 }
    
    VStack(spacing: 16) {
        ForEach(previewOrders, id: \.id) { order in
            Receipt(order: order, viewModel: viewModel, namespace: previewNamespace)
        }
    }
    .padding()
}
