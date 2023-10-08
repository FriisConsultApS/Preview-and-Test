//
//  Preview_and_TestApp.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import SwiftUI

@main
struct Preview_and_TestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
