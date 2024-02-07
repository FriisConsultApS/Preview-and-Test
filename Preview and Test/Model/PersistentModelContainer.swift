//
//  PersistentModelContainer.swift
//  Preview and Test
//
//  Created by Per Friis on 04/02/2024.
//

import Foundation
import SwiftData

/// this is just do make the App more lean to read.
struct PersistentModelContainer {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Assignment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
