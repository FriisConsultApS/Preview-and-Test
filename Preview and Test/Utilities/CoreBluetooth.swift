//
//  CoreBluetooth.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import Foundation
import CoreBluetooth

extension CBPeripheral: Identifiable {
    
}


extension CBManagerState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            "Unknown"
        case .resetting:
            "Resetting"
        case .unsupported:
            "Unsupported"
        case .unauthorized:
            "Unauthorized"
        case .poweredOff:
            "Powered off"
        case .poweredOn:
            "powered on"
        @unknown default:
            fatalError()
        }
    }
}
