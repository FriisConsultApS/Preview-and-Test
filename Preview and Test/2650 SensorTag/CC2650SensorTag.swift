//
//  CC2650SensorTag.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import Foundation
import CoreBluetooth
import OSLog
import SwiftUI

/// This is the implantation of the [TexasInstrument CC2650 SensorTag](https://dk.rs-online.com/web/p/mikrokontroller-udvikling/2355130), a great device to play with BLE.
@Observable class CC2650SensorTag: NSObject, SensorTagProtocol {

    /// Name of the device
    var name: String = ""

    /// current battery level, 0...1
    var battery: Double = .nan

    /// current button state
    var buttons: SensorTagButtonState = []

    /// An async stream that returns the current measured LUX from the sensor.
    ///
    /// When you start consuming the data, it will connect to the characteristic, and when you stop listen
    /// it will stop the characteristic and stop listen for update.
    var lux: AsyncStream<Double> {
        AsyncStream { continuation in
            self.luxContinuation = continuation
            continuation.onTermination = { _ in
                try? self.opticalStream(on: false)
            }
            do {
                try self.opticalStream(on: true)
            } catch {
                debugLog.error("\(error.localizedDescription, privacy: .public)")
                continuation.finish()
            }
        }
    }

    var gyroscope: AsyncStream<SIMD3<Double>> {
        AsyncStream { continuation in
            self.gyroscopeContinuation = continuation
            continuation.onTermination = { _ in
                try? self.movementStream(on: false)
            }
            do {
                try self.movementStream(on: true)
            } catch {
                debugLog.error("\(error.localizedDescription, privacy: .public)")
                continuation.finish()
            }
        }
    }

    private var peripheral: CBPeripheral
    private var initContinuation: CheckedContinuation<Void, Error>?

    /// This is a cool way to handle the async init, inserting all the states as we progress with the discovery of the Services and characteristics.
    private var state: CC2650State = []

    private var opticalData: CBCharacteristic?
    private var opticalConfiguration: CBCharacteristic?
    private var opticalPeriod: CBCharacteristic?
    private var luxContinuation: AsyncStream<Double>.Continuation?

    private var motionData: CBCharacteristic?
    private var motionConfiguration: CBCharacteristic?
    private var motionPeriod: CBCharacteristic?
    private var gyroscopeContinuation: AsyncStream<SIMD3<Double>>.Continuation?

    internal let debugLog: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "\(CC2650SensorTag.self)")

    
    /// An async Init that first returns when the device has been setup completely.
    ///
    /// - note: when working with BLE devices, this is a patten I often use, as it gives a complete object
    /// ready to use
    /// - Parameter peripheral: The peripheral to connect and discover
    /// - Throws: There is a lot of ``CC2650Error`` that can be thrown here. check it out if you want to make a detailed
    /// handling of the errors
    required init(_ peripheral: CBPeripheral?) async throws {
        guard let peripheral else { throw CC2650Error.invalidPeripheral }
        self.peripheral = peripheral
        super.init()
        self.peripheral.delegate = self

        let timeout = Task.detached { [weak self]  in
            try await Task.sleep(nanoseconds:5_000_000_000)
            print(self!.state.rawValue.description)
            self?.initContinuation?.resume(throwing: CC2650Error.timeOut)
            self?.initContinuation = nil
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.initContinuation = continuation
            self.peripheral.discoverServices([.simpleKeyService, .deviceInformationService, .batteryService,
                .opticalService, .movementService])
        }

        timeout.cancel()
    }

    private func opticalStream(on: Bool) throws {
        guard let opticalConfiguration,
              let opticalPeriod,
              let opticalData else {
            throw CC2650Error.noCharacteristics
        }
        peripheral.setNotifyValue(on, for: opticalData)
        peripheral.writeValue(on ? .on : .off, for: opticalConfiguration, type: .withResponse)
        peripheral.writeValue(.oneSecond, for: opticalPeriod, type: .withResponse)
    }

    private func movementStream(on: Bool) throws {
        guard let motionConfiguration,
              let motionPeriod,
              let motionData else {
            throw CC2650Error.noCharacteristics
        }
        peripheral.setNotifyValue(on, for: motionData)
        peripheral.writeValue(on ? .enableAllMotion : .off, for: motionConfiguration, type: .withResponse)
        peripheral.writeValue(.tenthSecond, for: motionPeriod, type: .withResponse)
        debugLog.info("should be set")
    }
}


extension CC2650SensorTag: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error {
            debugLog.error("\(error.localizedDescription, privacy: .public)")
            self.initContinuation?.resume(throwing: error)
            self.initContinuation = nil
            return
        }

        guard let services = peripheral.services else {
            debugLog.critical("No services")
            self.initContinuation?.resume(throwing: CC2650Error.noServices)
            self.initContinuation = nil
            return
        }

        if let deviceInfoService = services.first(where: {$0.uuid == .deviceInformationService}) {
            peripheral.discoverCharacteristics([.systemId, .modelNumber, .firmwareRevision, .hardwareRevision,
                                                .softwareRevision, .manufactureName, .regulatoryCertification,
                                                .pnpId], for: deviceInfoService)
        }

        if let simpleKeyService = services.first(where: {$0.uuid == .simpleKeyService}) {
            peripheral.discoverCharacteristics([.simpleKeyState], for: simpleKeyService)
        }

        if let batteryService = services.first(where: {$0.uuid == .batteryService}) {
            peripheral.discoverCharacteristics([.batteryLevel], for: batteryService)
        }

        if let opticalService = services.first(where: {$0.uuid == .opticalService}) {
            peripheral.discoverCharacteristics([.opticalData, .opticalPeriod, .opticalConfiguration], for: opticalService)
        }

        if let motionService = services.first(where: {$0.uuid == .movementService}) {
            peripheral.discoverCharacteristics([.movementData, .movementConfig, .movementPeriod], for: motionService)
        }
    }


    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error {
            debugLog.error("\(error.localizedDescription, privacy: .public)")
            initContinuation?.resume(throwing: error)
            initContinuation = nil
            return
        }

        guard let characteristics = service.characteristics else {
            debugLog.critical("No characteristic")
            initContinuation?.resume(throwing: CC2650Error.noCharacteristics)
            initContinuation = nil
            return
        }
        if [CBUUID.deviceInformationService, CBUUID.batteryService].contains(service.uuid) {
            characteristics.forEach {
                peripheral.readValue(for: $0)
            }
            state.insert([.batteryService, .deviceInfoService])
        }

        if service.uuid == .simpleKeyService,
            let keyPressState = characteristics.first(where: {$0.uuid == .simpleKeyState}) {
            peripheral.setNotifyValue(true, for: keyPressState)
            state.insert(.simpleKeyService)
        }

        if service.uuid == .opticalService {
            opticalData = characteristics.first(where: {$0.uuid == .opticalData})
            opticalConfiguration = characteristics.first(where: {$0.uuid == .opticalConfiguration})
            opticalPeriod = characteristics.first(where: {$0.uuid == .opticalPeriod})
            if opticalData != nil, opticalConfiguration != nil, opticalPeriod != nil {
                state.insert(.opticalService)
            }
        }

        if service.uuid == .movementService {
            motionData = characteristics.first(where: {$0.uuid == .movementData})
            motionConfiguration = characteristics.first(where: {$0.uuid == .movementConfig})
            motionPeriod = characteristics.first(where: {$0.uuid == .movementPeriod})
            if motionData != nil, motionConfiguration != nil, motionPeriod != nil {
                state.insert(.motionService)
            }

        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error {
            debugLog.error("\(error.localizedDescription, privacy: .public)")
            initContinuation?.resume(throwing: error)
            initContinuation = nil
            return
        }

        guard let value = characteristic.value else {
            debugLog.critical("No value")
            // TODO: maybe call the initContinuation ....
            return
        }

        switch characteristic.uuid {
        case .modelNumber:
            self.name = value.string

        case .batteryLevel:
            self.battery = Double(value[0]) / 100

        case .simpleKeyState:
            buttons.rawValue = value[0]

        case .opticalData:
            let exponent = (value.uint16 >> 12) & 0x0F // extract the 4 most significant bits
            let result = Double(value.uint16 & 0x0FFF) // extract the remaining 12 bits
            let lux = Double( result * 0.01 * pow(2.0, Double(exponent)))
            luxContinuation?.yield(lux)

        case .movementData:
            guard value.count >= 18 else {
                debugLog.critical("Invalid movement data")
                break
            }
            let x = Int16(littleEndian: value[9..<11].withUnsafeBytes {$0.pointee })
            let y = Int16(littleEndian: value[11..<13].withUnsafeBytes {$0.pointee })
            let z = Int16(littleEndian: value[13..<15].withUnsafeBytes {$0.pointee })
            let gyroscope = SIMD3<Double>(x: Double(x), y: Double(y), z: Double(z))
            gyroscopeContinuation?.yield(gyroscope)
            debugLog.info("Got motion data")



        default:
            debugLog.critical("not handled char value:\(value.string)")
        }

        if state.contains(.ready), initContinuation != nil {
            initContinuation?.resume()
            initContinuation = nil
        }
    }
}


extension CC2650SensorTag {
    struct CC2650State: OptionSet {
        var rawValue: UInt64
        static let deviceInfoService =  CC2650State(rawValue: 1 << 0)
        static let batteryService =     CC2650State(rawValue: 1 << 1)
        static let simpleKeyService =   CC2650State(rawValue: 1 << 2)
        static let opticalService =     CC2650State(rawValue: 1 << 3)
        static let motionService =      CC2650State(rawValue: 1 << 4)

        static let ready: CC2650State = [
            .deviceInfoService, batteryService, .simpleKeyService,
            .opticalService, .motionService
        ]
    }
}

/// Errors for the cc 2650 SensorTag, but could have been for just about any device
enum CC2650Error: Error {
    /// the Peripheral are not acting as expected or is missing
    case invalidPeripheral

    /// The Peripheral didn't finish discovery and initial read before the time-out
    case timeOut

    /// No services was discovered
    case noServices

    /// no characteristic was discovered on a service
    case noCharacteristics
}

/// This is just convince constants to the sensor characteristics on the CC2650 SensorTag
fileprivate extension Data {
    static let on = Data([0x01])
    static let off = Data([0x01])
    static let oneSecond = Data([0x64])
    static let tenthSecond = Data([0x0A])

    static let enableAllMotion = Data([0x07])
}
