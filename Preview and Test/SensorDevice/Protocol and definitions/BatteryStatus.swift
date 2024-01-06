//
//  BatteryStatus.swift
//  Preview and Test
//
//  Created by Per Friis on 06/01/2024.
//

import Foundation
import SwiftUI

enum BatteryStatus {
    case na
    case charging
    case notCharging(BatteryLevel)
}

extension BatteryStatus {
    /// Image that matches the current charge status
    var image: Image {
        switch self {
        case .na:
            Image("battery.0percent.slash")
        case .charging:
            Image(systemName: "battery.100percent.bolt")
        case .notCharging(let level):
            level.image
        }
    }
    
    /// The current charged level
    var value: Double {
        if case let .notCharging(value) = self {
            return value
        }
        return .nan
    }
}

typealias BatteryLevel = Double
extension BatteryLevel {
    var image: Image {
        switch self {
        case ...0.1:
            Image(systemName: "battery.0percent")
        case 0.1...0.35:
            Image(systemName: "battery.25percent")
        case 0.35...0.60:
            Image(systemName: "battery.50percent")
        case 0.60...0.85:
            Image(systemName: "battery.75percent")
        case 0.85...:
            Image(systemName: "battery.100percent")
        default:
            Image(systemName: "battery.100percent.circle")
        }
    }
}
