import SwiftUI

struct Receipt: View {
    let order: OrderItem
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 0) {
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
                            .font(.system(size: 32))
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
                        .font(.system(size: 20))
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
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch order.verificationStatus {
        case .verified:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(.green)
                .frame(width: 48, height: 48)
                .background(LinearGradient(
                    stops: [
                        Gradient.Stop(color: Constants.gray200, location: 0.00),
                        Gradient.Stop(color: .white, location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                ))
                .clipShape(Circle())
        case .pending:
            Button(action: {
            }) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Constants.amber400)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        case .mismatch:
            Button(action: {
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(Constants.red400)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

private extension Receipt {
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

#Preview{
    VStack(spacing: 16) {
        Receipt(order: OrderItem(
            orderNumber: "ORD-123",
            dateTime: Date(),
            price: 24000,
            dishes: ["Sample Dish"],
            verificationStatus: .pending
        ))
        
        Receipt(order: OrderItem(
            orderNumber: "ORD-2",
            dateTime: Date(),
            price: 23000,
            dishes: ["Sample Dish"],
            verificationStatus: .verified
        ))
        
        Receipt(order: OrderItem(
            orderNumber: "ORD-6",
            dateTime: Date(),
            price: 28000,
            dishes: ["Sample Dish"],
            verificationStatus: .mismatch
        ))
    }
    .padding()
    
}
