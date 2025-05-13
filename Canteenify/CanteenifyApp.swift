import SwiftUI

@main
struct CanteenifyApp: App {
    var body: some Scene {
        WindowGroup {
            HomePage()
                .modelContainer(for: OrderItem.self)
        }
    }
}
