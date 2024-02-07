//
//  PreviewAndTest.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI
import SwiftData

@main
struct PreviewAndTest: App {
    
    private var deviceController = DeviceController()
    private var cloudCoordinator = CloudCoordinator()
    private var sharedModelContainer = PersistentModelContainer.sharedModelContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(deviceController)
        .environment(cloudCoordinator)
    }
    
    init() {
        cloudCoordinator.modelContainer = sharedModelContainer
    }
}
