//
//  TaskItemDTO.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import Foundation

/// as NSManagedObject is not directly Codable, I often use a Data Transfer Object like this.
///  This is also used by the Web API for upload and download of data
struct TaskItemDTO: Codable {
    let name: String
    let details: String
    let due: Date
    let created: Date
    let rawPriority: Int
    let isCompleted: Bool
}
