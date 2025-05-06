import SwiftData
import Foundation

@MainActor
class DataController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: OrderItem.self, configurations: config)
            
            for order in OrderItem.sampleOrders {
                container.mainContext.insert(order)
            }
            
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
