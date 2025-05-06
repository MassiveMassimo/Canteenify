import SwiftUI
import SwiftData

@Model
final class OrderItem {
    var orderNumber: String
    var orderNumberTail: Int
    var dateTime: Date
    var price: Double
    @Attribute(.externalStorage) var receiptImage: Data?
    @Attribute(.externalStorage) var proofImage: Data?
    var dishes: [String]
    var verificationStatus: VerificationStatus
    var createdAt: Date
    var restaurantName: String
    var paymentMethod: String
    
    init(
        orderNumber: String,
        dateTime: Date,
        price: Double,
        receiptImage: Data? = nil,
        proofImage: Data? = nil,
        dishes: [String],
        verificationStatus: VerificationStatus,
        restaurantName: String = "",
        paymentMethod: String = ""
    ) {
        self.orderNumber = orderNumber
        let components = orderNumber.split(separator: "-")
        self.orderNumberTail = Int(components.last ?? "") ?? 0
        self.dateTime = dateTime
        self.price = price
        self.receiptImage = receiptImage
        self.proofImage = proofImage
        self.dishes = dishes
        self.verificationStatus = verificationStatus
        self.createdAt = Date()
        self.restaurantName = restaurantName
        self.paymentMethod = paymentMethod
    }
    
    enum VerificationStatus: String, Codable {
        case verified = "Verified"
        case pending = "Pending"
        case mismatch = "Mismatch"
        
        var color: Color {
            switch self {
            case .verified:
                return .green
            case .pending:
                return .orange
            case .mismatch:
                return .red
            }
        }
        
        var iconName: String {
            switch self {
            case .verified:
                return "checkmark.circle.fill"
            case .pending:
                return "clock.fill"
            case .mismatch:
                return "xmark.circle.fill"
            }
        }
    }
}

// Sample data for previews
extension OrderItem {
    static var sampleOrders: [OrderItem] {
        [
            OrderItem(orderNumber: "POS-080425-1", dateTime: Date().addingTimeInterval(-3600), price: 45000, dishes: ["Daging Lada Hitam", "Nasi Putih 1 Porsi", "Es Teh Manis"], verificationStatus: .verified, restaurantName: "Warung Nusantara"),
            OrderItem(orderNumber: "POS-080425-2", dateTime: Date().addingTimeInterval(-4200), price: 38000, dishes: ["Ayam Geprek", "Nasi Putih"], verificationStatus: .pending, restaurantName: "Ayam Geprek Maknyus"),
            OrderItem(orderNumber: "POS-080425-3", dateTime: Date().addingTimeInterval(-4800), price: 52000, dishes: ["Sate Ayam", "Lontong", "Teh Tawar"], verificationStatus: .mismatch, restaurantName: "Sate Pak Gino"),
            OrderItem(orderNumber: "POS-080425-4", dateTime: Date().addingTimeInterval(-5400), price: 60000, dishes: ["Bakso Urat", "Es Campur"], verificationStatus: .verified, restaurantName: "Bakso Malang Jaya"),
            OrderItem(orderNumber: "POS-080425-5", dateTime: Date().addingTimeInterval(-6000), price: 29000, dishes: ["Nasi Goreng", "Kerupuk"], verificationStatus: .pending, restaurantName: "Nasi Goreng Bang Jo"),
            OrderItem(orderNumber: "POS-080425-6", dateTime: Date().addingTimeInterval(-6600), price: 47000, dishes: ["Mie Ayam", "Es Jeruk"], verificationStatus: .mismatch, restaurantName: "Mie Ayam Tumini"),
            OrderItem(orderNumber: "POS-080425-7", dateTime: Date().addingTimeInterval(-7200), price: 88000, dishes: ["Ikan Bakar", "Nasi Uduk", "Lalapan", "Sambal"], verificationStatus: .verified, restaurantName: "Pondok Ikan Bakar"),
            OrderItem(orderNumber: "POS-080425-8", dateTime: Date().addingTimeInterval(-7800), price: 32000, dishes: ["Lontong Sayur", "Teh Manis"], verificationStatus: .pending, restaurantName: "Lontong Sayur Hj. Siti"),
            OrderItem(orderNumber: "POS-080425-9", dateTime: Date().addingTimeInterval(-8400), price: 56000, dishes: ["Ayam Bakar", "Sayur Asem", "Nasi Putih"], verificationStatus: .mismatch, restaurantName: "Warung Betawi Asli"),
            OrderItem(orderNumber: "POS-080425-10", dateTime: Date().addingTimeInterval(-9000), price: 73000, dishes: ["Sop Buntut", "Nasi", "Es Teh"], verificationStatus: .verified, restaurantName: "Restoran Nusantara")
        ]
    }
}
