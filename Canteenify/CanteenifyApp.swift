//
//  CanteenifyApp.swift
//  Canteenify
//
//  Created by Imo Madjid on 5/2/25.
//

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
