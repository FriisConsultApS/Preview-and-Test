//
//  Persistence.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import CoreData

/// This is directly from the CoreData Template, when starting a new iOS CoreData project, with my customizations
struct PersistenceController {
    static let `default` = PersistenceController()

    static let emptyPreview: PersistenceController = PersistenceController(inMemory: true)

    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // Here we are loading a json file that I have "created" using Chat.GPT.
        // So let's take a look of that
        do {
            let taskDTOs = try [TaskItemDTO].load(filename: "tasks")
            for taskDTO in taskDTOs {
                _ = TaskItem(taskDTO, insertInto: viewContext)
            }
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            fatalError(error.localizedDescription)
        }
        return result
    }()
    
    static var embedded: PersistenceController = {
        let fm = FileManager.default
        guard let destinationFolder = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("no folder") // The print is to show in the preview log
            fatalError("No folder")
        }
        let destinationUrl = destinationFolder.appendingPathComponent("CoreData.sqlite", conformingTo: .database)
        if !fm.fileExists(atPath: destinationUrl.path()),
           let sourceURL = Bundle.main.url(forResource: "CoreData", withExtension: "sqlite") {
            do {
                try fm.copyItem(at: sourceURL, to: destinationUrl)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
        
        return PersistenceController()
        
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CoreData")
        if inMemory {
            
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null/")
            
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print(error)
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}


extension NSManagedObjectContext {
    /// Just a little extra shortcut for the preview viewContext
    static var preview: NSManagedObjectContext {
        PersistenceController.preview.container.viewContext
    }

    static var emptyPreview: NSManagedObjectContext {
        print("Hello")
        return PersistenceController.emptyPreview.container.viewContext
    }
}
