//
//  TaskItemDTO.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import Foundation

struct TaskItemDTO: Codable {
    let name: String
    let details: String
    let due: Date
    let created: Date
    let rawPriority: Int
    let isCompleted: Bool
}
