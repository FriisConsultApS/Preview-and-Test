//
//  Assignment.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit

/// The main model for tha app
@Model
class Assignment: Codable {
    var id: UUID
    var name: String
    var details: String
    var due: Date
    var created: Date
    var priority: Priority
    var isCompleted:  Bool
    
    @Attribute(.externalStorage)
    var imageData: Data?
    
    init(id: UUID = UUID(), name: String, details: String, due: Date? = nil, priority: Assignment.Priority = .medium, imageName: String? = nil) {
        self.id = id
        self.name = name
        self.details = details
        if let due {
            self.due = due
        } else {
            self.due = Calendar.current.date(byAdding: .day, value: 4, to: .now) ?? .now
        }
        self.created = .now
        self.priority = priority
        self.isCompleted = false
        if let imageName, let image = UIImage(named: imageName), let png = image.pngData() {
            self.imageData = png
        }
    }
    
    // MARK: - Custom Codable implementation
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(UUID.self, forKey:.id) ?? .init()
        self.name = try values.decode(String.self, forKey:.name)
        self.details = try values.decode(String.self, forKey:.details)
        self.due = try values.decode(Date.self, forKey:.due)
        self.created = try values.decode(Date.self, forKey:.created)
        self.priority = try values.decode(Assignment.Priority.self, forKey:.priority)
        self.isCompleted = try values.decode(Bool.self, forKey:.isCompleted)
        if let imageName = try values.decodeIfPresent(String.self, forKey: .imageName),
           let image = UIImage(named: imageName) {
            imageData = image.pngData()
        }
        
       
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(details, forKey: .details)
        try container.encode(due, forKey: .due)
        try container.encode(created, forKey: .created)
        try container.encode(priority, forKey: .priority)
        try container.encode(isCompleted, forKey: .isCompleted)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case details
        case due
        case created
        case priority
        case isCompleted
        case imageName
    }
    
    // MARK: -
    /// Please note that usign enums in Models is not as straight forward as you might think
    enum Priority: String, Codable {
        case low
        case medium
        case high
    }
}

