//
//  SensorTagProtocol.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import Foundation
import CoreBluetooth
import SwiftUI

/// I use the protocol to hold the device, making it available for implementation in any way.
protocol SensorTagProtocol {
    var name: String { get }
    var battery: Double { get }
    var buttons: SensorTagButtonState { get }
    var lux: AsyncStream<Double> { get }
    var irTemperature: AsyncStream<Double> { get }
    var humidity: AsyncStream<Double> { get }
    var pressur: AsyncStream<Double> { get }
    var gyroscope: AsyncStream<SIMD3<Double>> { get }


    init(_ peripheral: CBPeripheral?) async throws
}

/// and "option set" that shows what buttons that are pressed
struct SensorTagButtonState: OptionSet {
    var rawValue: UInt8

    static let one = SensorTagButtonState(rawValue: 1 << 0)
    static let two = SensorTagButtonState(rawValue: 1 << 1)

    static let both: SensorTagButtonState = [.one, .two]

    var image: Image {
        switch self {
        case .both:
            Image(systemName: "button.horizontal.top.press")
        case .one:
            Image(systemName:"button.vertical.right.press")

        case .two:
            Image(systemName: "button.vertical.left.press")

        default:
            Image(systemName: "button.horizontal")
        }
    }
}


// MARK: - definition of the CC2650 SensorTag services and Characteristics.
extension CBUUID {
    /// IR Temperature Service
    static let irTemperatureService = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")

    /// Humidity Service
    static let humidityService = CBUUID(string: "F000AA20-0451-4000-B000-000000000000")

    /// Barometric Pressure Service
    static let barometricPressureService = CBUUID(string: "F000AA40-0451-4000-B000-000000000000")

    /// Optical Service (Light)
    static let opticalService = CBUUID(string: "F000AA70-0451-4000-B000-000000000000")
    static let opticalData = CBUUID(string:"F000AA71-0451-4000-B000-000000000000")
    static let opticalConfiguration = CBUUID(string:"F000AA72-0451-4000-B000-000000000000")
    static let opticalPeriod = CBUUID(string:"F000AA73-0451-4000-B000-000000000000")

    /// Movement Service (Accelerometer, Gyroscope, Magnetometer)
    static let movementService = CBUUID(string: "F000AA80-0451-4000-B000-000000000000")

    static let movementData = CBUUID(string: "F000AA81-0451-4000-B000-000000000000")
    static let movementConfig = CBUUID(string: "F000AA82-0451-4000-B000-000000000000")
    static let movementPeriod = CBUUID(string: "F000AA83-0451-4000-B000-000000000000")

    /// Simple Key Service
    static let simpleKeyService = CBUUID(string: "FFE0")

    /// Simple Key Service Characteristics
    static let simpleKeyState = CBUUID(string: "FFE1")


    /// Magnetometer Service
    static let magnetometerService = CBUUID(string: "F000AA30-0451-4000-B000-000000000000")

    /// Barometer Service
    static let barometerService = CBUUID(string: "F000AA40-0451-4000-B000-000000000000")


    /// Gyroscope Service
  //  static let motionService = CBUUID(string: "F000AA50-0451-4000-B000-000000000000")



    /// Test Service
    static let testService = CBUUID(string: "F000AA60-0451-4000-B000-000000000000")

    /// Connection Control Service
    static let connectionControlService = CBUUID(string: "F000CCC0-0451-4000-B000-000000000000")

    /// OAD Service (Over the Air Download)
    static let oadService = CBUUID(string: "F000FFC0-0451-4000-B000-000000000000")

    static let batteryService = CBUUID(string: "180F")
    static let batteryLevel = CBUUID(string: "2A19")

    /// Device Information Service
    static let deviceInformationService = CBUUID(string: "180A")
    
    static let systemId = CBUUID(string: "2A23")
    static let modelNumber = CBUUID(string: "2A24")
    static let serialNumber = CBUUID(string: "2A25")
    static let firmwareRevision = CBUUID(string: "2A26")
    static let hardwareRevision = CBUUID(string: "2A27")
    static let softwareRevision = CBUUID(string: "2A28")
    static let manufactureName = CBUUID(string: "2A29")
    static let regulatoryCertification = CBUUID(string: "2A2A")
    static let pnpId = CBUUID(string: "2A50")
}
