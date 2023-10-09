//
//  SensorTagPreview.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import Foundation
import SwiftUI
import CoreBluetooth

@Observable class SensorTagPreview: SensorTagProtocol {
    var name: String
    
    var battery: Double
    
    var buttons: SensorTagButtonState
    
    required init(_ peripheral: CBPeripheral?) async throws {
        self.name = "Preview"
        self.battery = 0.4
        self.buttons = []
    }

    init() {
        self.name = "Preview"
        self.battery = 0.4
        self.buttons = []


        Task.detached {
            while true {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.buttons = .both

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.buttons = .one

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.buttons = .two

                try? await Task.sleep(nanoseconds: 1_000_000_000)
                self.buttons.remove(.both)
            }
        }
    }


}
