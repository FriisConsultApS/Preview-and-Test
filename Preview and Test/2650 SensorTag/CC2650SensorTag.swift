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

@Observable class CC2650SensorTag: NSObject, SensorTagProtocol {
    var name: String = ""
    var battery: Double = .nan
    var buttons: SensorTagButtonState = []

    private var peripheral: CBPeripheral
    private var initContinuation: CheckedContinuation<Void, Error>?
    private var state: CC2650State = []

    internal let debugLog: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "\(CC2650SensorTag.self)")

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
            self.peripheral.discoverServices([.simpleKeyService, .deviceInformationService, .batteryService])
        }
        timeout.cancel()
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
            state.insert(.deviceInfoService)
            peripheral.discoverCharacteristics([.systemId, .modelNumber, .firmwareRevision, .hardwareRevision,
                                                .softwareRevision, .manufactureName, .regulatoryCertification,
                                                .pnpId], for: deviceInfoService)
        }

        if let simpleKeyService = services.first(where: {$0.uuid == .simpleKeyService}) {
            state.insert(.simpleKeyService)
            peripheral.discoverCharacteristics([.simpleKeyState], for: simpleKeyService)
        }

        if let batteryService = services.first(where: {$0.uuid == .batteryService}) {
            state.insert(.batteryService)
            peripheral.discoverCharacteristics([.batteryLevel], for: batteryService)
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
        }

        if service.uuid == .simpleKeyService,
            let keyPressState = characteristics.first(where: {$0.uuid == .simpleKeyState}) {
            peripheral.setNotifyValue(true, for: keyPressState)
            state.insert(.keyPressState)
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
        case .systemId:
            state.insert(.systemId)
            debugLog.info("\(value.string)")

        case .modelNumber:
            state.insert(.modelNumber)
            self.name = value.string

        case .serialNumber:
            state.insert(.serialNumber)
            debugLog.info("\(value.string)")

        case .firmwareRevision:
            state.insert(.firmwareRevision)
            debugLog.info("\(value.string)")

        case .hardwareRevision:
            state.insert(.hardwareRevision)
            debugLog.info("\(value.string)")

        case .softwareRevision:
            //state.insert(.soft)
            debugLog.info("\(value.string)")

        case .manufactureName:
            state.insert(.manufactureName)
            debugLog.info("\(value.string)")

        case .regulatoryCertification:
            state.insert(.regulatoryCertification)
            debugLog.info("\(value.string)")

        case .pnpId:
            state.insert(.pnpId)
            debugLog.info("\(value.string)")

        case .batteryLevel:
            state.insert(.batteryLevel)
            self.battery = Double(value[0]) / 100

        case .simpleKeyState:
            debugLog.info("\(value.hex)")
            buttons.rawValue = value[0]

        default:
            debugLog.critical("hmmmm. \(value.string)")
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
        static let systemId =           CC2650State(rawValue: 1 << 1)
        static let modelNumber =        CC2650State(rawValue: 1 << 2)
        static let serialNumber =       CC2650State(rawValue: 1 << 3)
        static let firmwareRevision =   CC2650State(rawValue: 1 << 4)
        static let hardwareRevision =   CC2650State(rawValue: 1 << 5)
        static let manufactureName =    CC2650State(rawValue: 1 << 6)
        static let regulatoryCertification = CC2650State(rawValue: 1 << 7)
        static let pnpId =              CC2650State(rawValue: 1 << 8)

        static let batteryService =     CC2650State(rawValue: 1 << 9)
        static let batteryLevel =       CC2650State(rawValue: 1 << 10)

        static let simpleKeyService =   CC2650State(rawValue: 1 << 11)
        static let keyPressState =      CC2650State(rawValue: 1 << 12)


        static let ready: CC2650State = [
            .simpleKeyService, .keyPressState
        ]

    }
}

enum CC2650Error: Error {
    case invalidPeripheral
    case timeOut
    case noServices
    case noCharacteristics
}
