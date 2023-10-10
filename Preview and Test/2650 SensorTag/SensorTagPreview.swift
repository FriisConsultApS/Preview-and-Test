//
//  SensorTagPreview.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import Foundation
import SwiftUI
import CoreBluetooth

/// This is what we are here for
/// This is a implementation that can be use for Preview and Test
@Observable class SensorTagPreview: SensorTagProtocol {
    var name: String
    var battery: Double
    var buttons: SensorTagButtonState
    var lux: AsyncStream<Double> {
        AsyncStream { continuation in
            self.luxContinuation = continuation
        }
    }
    
    var gyroscope: AsyncStream<SIMD3<Double>> {
        AsyncStream { continuation in
            self.gyroscopeContinuation = continuation
        }
    }



    /// as we like to have a "live" update of the preview, we need to implement some sort of stream
    private var luxContinuation: AsyncStream<Double>.Continuation?
    private var gyroscopeContinuation: AsyncStream<SIMD3<Double>>.Continuation?

    /// This is required from the protocol but it is not practical to call a async initializer from preview, thats why I also have the sync initializer ``SensorTagPreview/init()``
    required init(_ peripheral: CBPeripheral?) async throws {
        self.name = "Preview"
        self.battery = 0.4
        self.buttons = []
    }

    /// This init is just an ordinary sync init. Perfect for the preview.
    init() {
        self.name = "Preview"
        self.battery = 0.4
        self.buttons = []
        // TODO: call start the fun
        startTheFun()
    }

    /// Just so you can see how cool we can make the preview.
    private func startTheFun() {
        Task.detached {
            while true {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if Bool.random() {
                    self.buttons.rawValue = UInt8.random(in: 0...3)
                }

                self.luxContinuation?.yield(.random(in: 0...100_000))
                self.gyroscopeContinuation?.yield(SIMD3<Double>(x: .random(in: 0...255), y: .random(in: 0...255), z: .random(in: 0...255)))
            }
        }
    }
}
