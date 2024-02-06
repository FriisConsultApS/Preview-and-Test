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
@Observable class SensorTagPreview: SensorDeviceProtocol {
    var name: String = "preview device"
    var systemId: String = "System Id"
    var modelNumber: String = "Model number"
    var serialNumber: String = "serial number"
    var firmwareRevision: String = "firmware version"
    var hardwareRevision: String = "hardware version"
    var softwareRevision: String = "software version"
    var manufactureName: String = "manufactur name"
    var regulatoryCertification: String = "regulatory certification"
    var pnpId: String = "pnp ID"
    
    var (battery, batteryContinuation) =  AsyncStream.makeStream(of: BatteryStatus.self)
    var (buttons, buttonsContinuation) =  AsyncStream.makeStream(of: DeviceButtons.self)
    var (barometic, barometicContinuation) =  AsyncStream.makeStream(of: Double.self)
    var (tempreture, tempretureContinuati) =  AsyncStream.makeStream(of: Double.self)
    var (color, colorContinuation) =  AsyncStream.makeStream(of: Color.self)
    var (image, imageContinuation) =  AsyncStream.makeStream(of: Image.self)
    var (proximity, proximityContinuation) =  AsyncStream.makeStream(of: Double.self)
    var (gesture, gestureContinuation) =  AsyncStream.makeStream(of: GestureSensor.self)
    var (magnetrometer, magnetrometerContinuation) =  AsyncStream.makeStream(of: SIMD3<Double>.self)
    
    var (lux, luxContinuation) = AsyncStream.makeStream(of: Double.self)
    var (gyroscope, gyroscopeContinuation) = AsyncStream.makeStream(of: SIMD3<Double>.self)
    var (irTemperature, irTemperatureContinuation) = AsyncStream.makeStream(of: Double.self)
    var (humidity, humidityContinuation) = AsyncStream.makeStream(of: Double.self)
    var (pressur, pressurContinuation) = AsyncStream.makeStream(of: Double.self)
    
    var availableSensors: SensorOptions = .all
    
    private var batteryLevel: Double = 1
    private var charging: Bool = false

    /// This is required from the protocol but it is not practical to call a async initializer from preview, thats why I also have the sync initializer ``SensorTagPreview/init()``
    required init(_ peripheral: CBPeripheral?) async throws {
        self.batteryContinuation.yield(.notCharging(batteryLevel))
        self.buttonsContinuation.yield([])
    }

    /// This init is just an ordinary sync init. Perfect for the preview.
    init() {
        self.batteryContinuation.yield(.notCharging(batteryLevel))
        self.buttonsContinuation.yield([])
      //  startTheFun()
    }

    /// Just so you can see how cool we can make the preview.
    private func startTheFun() {
        Task.detached {
            while true {
                // charge the battery
                if self.batteryLevel < 0.1 && !self.charging {
                    self.batteryLevel += 0.001
                    self.charging = true
                    self.batteryContinuation.yield(.charging)
                }
                
                // use the battery
                if self.batteryLevel >= 1 && self.charging {
                    self.batteryLevel -= 0.001
                    self.charging = false
                    self.batteryContinuation.yield(.notCharging(self.batteryLevel))
                }
                
                
                if Bool.random() {
                    self.buttonsContinuation.yield(.init(rawValue: UInt8.random(in: 0...31)))
                }

                if Bool.random() {
                    self.humidityContinuation.yield(.random(in: 0...1))
                }

                if Bool.random() {
                    self.barometicContinuation.yield(.random(in: 800...1200))
                }
                
                if Bool.random() {
                    self.tempretureContinuati.yield(.random(in: -20...250))
                }
                
                if Bool.random() {
                    self.irTemperatureContinuation.yield(.random(in: -20...250))
                }

                
                if Bool.random() {
                    self.luxContinuation.yield(.random(in: 0...100_000))
                }
                
                if Bool.random() {
                    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .brown, .cyan]
                    self.colorContinuation.yield(colors.randomElement() ?? .purple)
                }
                
                if Bool.random() {
                    let imageName = ["externaldrive.badge.checkmark", "person.crop.rectangle.badge.plus", "apple.logo", "applepencil.tip"].randomElement() ?? "apple.logo"
                    self.imageContinuation.yield(.init(systemName: imageName))
                }
                
                
                
                if Bool.random() {
                    self.gyroscopeContinuation.yield(SIMD3<Double>(x: .random(in: 0...255), y: .random(in: 0...255), z: .random(in: 0...255)))
                }
                if Bool.random() {
                    self.magnetrometerContinuation.yield(SIMD3<Double>(x: .random(in: 0...255), y: .random(in: 0...255), z: .random(in: 0...255)))
                }
                
                if Bool.random() {
                    self.proximityContinuation.yield(.random(in: 0...255))
                }
                
                if Bool.random() {
                    let gesture = [GestureSensor.down, GestureSensor.left, GestureSensor.up, GestureSensor.right, GestureSensor.rest].randomElement() ?? GestureSensor.rest
                    self.gestureContinuation.yield(gesture)
                }
                
                try? await Task.sleep(nanoseconds: 500_000_000)
              
            }
        }
    }
}
