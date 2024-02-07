//
//  Assignment Utilities.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import Foundation
import SwiftData
import SwiftUI

/// this is the extensions to the model, handling a lot of other stuff
extension Assignment {
    /// ReadOnly image, based on the binary image that might have been stored in ``Assignment/imageData``
    var image: Image {
        if let data = imageData, let img = UIImage(data: data) {
            return Image(uiImage: img)
        }
        return Image(systemName: "globe")
    }
    
    
    /// Update self with new values
    /// - Parameter updatedAssignment: update assignment
    func update(_ updatedAssignment: Assignment) {
        guard id == updatedAssignment.id else { return }
        self.name = updatedAssignment.name
        self.details = updatedAssignment.details
        self.due = updatedAssignment.due
        self.created = updatedAssignment.created
        self.priority = updatedAssignment.priority
        self.isCompleted = updatedAssignment.isCompleted
        self.imageData = updatedAssignment.imageData
    }
    
    /// convenience sort descriptor and predicate
    static let defaultSort = SortDescriptor<Assignment>(\.due, order: .forward)
    static let openPredicate = #Predicate<Assignment>{ $0.isCompleted == false }
    static let completedPredicate = #Predicate<Assignment>{ $0.isCompleted }
    
    // MARK: - Preview data
    static let checkWaterSupply: Assignment = .init( name: "Check Water Supply",
                                                     details:  "Conduct regular checks on water storage systems and filter replacements.",
                                                     due: Date(timeIntervalSince1970: 2219731200),
                                                     imageName: "water")
    
    static let repairSolarPanels: Assignment  = .init(name: "Repair Solar Panels",
                                                      details: "Inspect and repair solar panels to ensure optimal energy production.",
                                                      due: Date(timeIntervalSince1970: 2218992000),
                                                      priority: .high,
                                                      imageName: "solar")
    
    static let conductSoilAnalysis: Assignment = .init(name: "Conduct Soil Analysis",
                                                       details: "Collect soil samples and analyze for nutrient levels and suitability for cultivation.",
                                                       due: Date(timeIntervalSince1970: 2220403200),
                                                       imageName: "soil")
    
    static let marsRoverMaintenance: Assignment = .init(name: "Mars Rover Maintenance",
                                                        details: "Perform regular maintenance tasks on the Mars rover to ensure its functionality.",
                                                        due: Date(timeIntervalSince1970: 2221075200), imageName: "mrv")
    
    static let monitorAtmosphericConditions: Assignment = .init(name: "Monitor Atmospheric Conditions",
                                                                details: "Continuously monitor and record atmospheric conditions using sensors and instruments.",
                                                                due:Date(timeIntervalSince1970: 2221747200), imageName: "air")
    
    static let emergencyEvacuationDrill: Assignment = .init(name: "Emergency Evacuation Drill",
                                                            details: "Coordinate and conduct an emergency evacuation drill for all personnel on the base.",
                                                            due:Date(timeIntervalSince1970: 2222419200),
                                                            priority: .low, imageName: "evac")
}
