import SwiftUI

struct OrderDetailsPage: View {
    let order: OrderItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Hero header that matches the main content of Receipt
                VStack(spacing: 12) {
                    HStack(alignment: .center) {
                        HStack(alignment: .center, spacing: 8) {
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("№")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 4)
                                    .fixedSize()
                                Text("\(order.orderNumberTail)")
                                    .font(.system(size: 32, design: .monospaced))
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
                    
                    // Order status info
                    HStack(spacing: 12) {
                        Image(systemName: order.verificationStatus.iconName)
                            .foregroundColor(order.verificationStatus.color)
                            .font(.system(size: 24))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(order.verificationStatus.rawValue)
                                .font(.headline)
                            
                            Text(statusDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 12)
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
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 2)
                .padding()
                
                // Order Details
                VStack(alignment: .leading, spacing: 16) {
                    detailSection(title: "Order Information") {
                        detailRow(label: "Order Number", value: order.orderNumber)
                        detailRow(label: "Date & Time", value: order.dateTime.formatted(date: .long, time: .shortened))
                        detailRow(label: "Restaurant", value: order.restaurantName.isEmpty ? "Not specified" : order.restaurantName)
                        detailRow(label: "Payment Method", value: order.paymentMethod.isEmpty ? "Not specified" : order.paymentMethod)
                    }
                    
                    detailSection(title: "Items") {
                        ForEach(order.dishes, id: \.self) { dish in
                            Text("• \(dish)")
                                .padding(.vertical, 4)
                        }
                        
                        if order.dishes.isEmpty {
                            Text("No items specified")
                                .italic()
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let receiptImage = order.receiptImage, let uiImage = UIImage(data: receiptImage) {
                        detailSection(title: "Receipt Image") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                        }
                    }
                    
                    if let proofImage = order.proofImage, let uiImage = UIImage(data: proofImage) {
                        detailSection(title: "Proof Image") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .toolbar(.hidden)
    }
    
    // Helper view builders
    private func detailSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content()
                .padding(.horizontal, 8)
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var statusDescription: String {
        switch order.verificationStatus {
        case .verified:
            return "This order has been verified and processed successfully."
        case .pending:
            return "This order is awaiting verification."
        case .mismatch:
            return "There's a discrepancy in the verification. Action required."
        }
    }
    
    private var statusGradient: LinearGradient {
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
    
    private var statusTextColor: Color {
        switch order.verificationStatus {
        case .verified:
            return Constants.green700
        case .pending:
            return Constants.amber700
        case .mismatch:
            return Constants.red700
        }
    }
    
    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        
        if let formattedString = formatter.string(from: NSNumber(value: order.price)) {
            return formattedString
        }
        
        return "\(order.price)"
    }
}

// Preview provider with a namespace for testing
struct OrderDetailsPage_Previews: PreviewProvider {
    static var previews: some View {
        let sampleOrder = OrderItem(
            orderNumber: "ORD-001",
            dateTime: Date(),
            price: 25000,
            receiptImage: nil,
            proofImage: nil,
            dishes: ["Nasi Goreng", "Es Teh"],
            verificationStatus: .verified,
            restaurantName: "Warung Makan Sederhana",
            paymentMethod: "Cash"
        )
        
        OrderDetailsPage(order: sampleOrder)
    }
}
