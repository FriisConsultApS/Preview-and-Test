//
//  TaskItem.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import Foundation
import CoreData


extension TaskItem {
    static let defaultSort = [
        NSSortDescriptor(keyPath: \TaskItem.due, ascending: true),
        NSSortDescriptor(keyPath: \TaskItem.rawPriority, ascending: true)
    ]



    func update(_ dto: TaskItemDTO) {
        name = dto.name
        details = dto.details
        due = Calendar.current.date(byAdding: .year, value: -30, to: dto.due)
        created = Calendar.current.date(byAdding: .year, value: -30, to: dto.created)
        rawPriority = Int16(dto.rawPriority)
        isCompleted = dto.isCompleted
    }


    // MARK: - Preview data

    static func checkWaterSupply(in context: NSManagedObjectContext) -> TaskItem {
        let item = TaskItem(context: context)

        item.name =  "Check Water Supply"
        item.details =  "Conduct regular checks on water storage systems and filter replacements."
        item.due = Date(timeIntervalSince1970: 2219731200)
        item.created =  Date(timeIntervalSince1970: 2209116800)
        item.rawPriority =  2
        item.isCompleted =  false

        return item
    }

    static func repairSolarPanels(in context: NSManagedObjectContext) -> TaskItem {
        let item = TaskItem(context: context)

        item.name = "Repair Solar Panels"
        item.details = "Inspect and repair solar panels to ensure optimal energy production."
        item.due = Date(timeIntervalSince1970: 2218992000)
        item.created = Date(timeIntervalSince1970: 2209030400)
        item.rawPriority = 1
        item.isCompleted = false

        return item
    }

    static func conductSoilAnalysis(in context: NSManagedObjectContext) -> TaskItem {
        let item = TaskItem(context: context)

        item.name = "Conduct Soil Analysis"
        item.details = "Collect soil samples and analyze for nutrient levels and suitability for cultivation."
        item.due = Date(timeIntervalSince1970: 2220403200)
        item.created = Date(timeIntervalSince1970: 2209203200)
        item.rawPriority = 3
        item.isCompleted = true

        return item
    }

    static func marsRoverMaintenance(in context: NSManagedObjectContext) -> TaskItem {
        let item = TaskItem(context: context)

        item.name = "Mars Rover Maintenance"
        item.details = "Perform regular maintenance tasks on the Mars rover to ensure its functionality."
        item.due = Date(timeIntervalSince1970: 2221075200)
        item.created = Date(timeIntervalSince1970: 2209289600)
        item.rawPriority = 1
        item.isCompleted = false

        return item
    }

    static func monitorAtmosphericConditions(in context: NSManagedObjectContext) -> TaskItem {
        let item = TaskItem(context: context)

        item.name = "Monitor Atmospheric Conditions"
        item.details = "Continuously monitor and record atmospheric conditions using sensors and instruments."
        item.due = Date(timeIntervalSince1970: 2221747200)
        item.created = Date(timeIntervalSince1970: 2209376000)
        item.rawPriority = 2
        item.isCompleted = false

        return item
    }

    static func emergencyEvacuationDrill(in context: NSManagedObjectContext) -> TaskItem {
        let item = TaskItem(context: context)

        item.name = "Emergency Evacuation Drill"
        item.details = "Coordinate and conduct an emergency evacuation drill for all personnel on the base."
        item.due = Date(timeIntervalSince1970: 2222419200)
        item.created = Date(timeIntervalSince1970: 2209462400)
        item.rawPriority = 3
        item.isCompleted = true

        return item
    }
}



