//
//  PreviewAndTest.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI

@main
struct PreviewAndTest: App {
    private let persistenceController = PersistenceController.shared
    private var deviceController = DeviceController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(deviceController)
        }
    }
}
