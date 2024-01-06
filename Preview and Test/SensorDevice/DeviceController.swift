//
//  DeviceController.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import Foundation
import CoreBluetooth
import SwiftUI
import OSLog

/// The device controller is handling the connection to the BLE device
/// - note: As this project is used in a presentation of preview and test data, the complete story about
/// BLE devices and handling is not a part of this project.
///
/// How ever the BLE is implemented using __concurrency__ with async/await async streams....
@Observable final class DeviceController: NSObject {

    /// list of peripherals that might be the type of devices that we look for.
    private(set) var peripherals: [CBPeripheral] = []


    private  var bleQueue = DispatchQueue(label: "com.friismobility.mars.task",qos: .background)
    private  var central: CBCentralManager?

    private let debugLog: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "\(DeviceController.self)")

    private var connectionContinuation: CheckedContinuation<any SensorDeviceProtocol, Error>?

    /// As we don't want the user to be prompted for BLE usage before the user is in need of the BLE, we don't setup the central
    /// before we need it
    func startBLE() {
        central = CBCentralManager(delegate: self, queue: bleQueue , options: [CBCentralManagerOptionRestoreIdentifierKey: "com.friismobility.mars.task"])
    }

    /// Start scan for BLE devices
    func startScan() {
        guard let central else {
            startBLE()
            return
        }
        debugLog.info("Start scan for services")
        central.scanForPeripherals(withServices: [CBUUID(string: "AA80")])
    }

    /// Async way of connecting to a SensorTag.
    /// 
    /// The sensorTag is returned when it it complete with all discovery of services and characteristic, and ready to use.
    /// For further info about the sensorTag async init see the ``CC2650SensorTag/init(_:)``
    /// - Parameter peripheral: A peripheral compatible with the SensorTagProtocol
    /// - Returns: A fully connected, discovered and ready to use device
    /// - Throws: ``DeviceControllerError`` and ``CC2650Error``
    func connect(_ peripheral: CBPeripheral) async throws -> any SensorDeviceProtocol {
        guard let central else { throw DeviceControllerError.invalidCentral }

        guard peripherals.contains(where: {$0 == peripheral}) else {
            throw DeviceControllerError.invalidPeripheral
        }
        central.stopScan()

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<any SensorDeviceProtocol, Error>) in
            connectionContinuation = continuation
            central.connect(peripheral)
        }
    }

    /// Disconnect all connected peripherals and reset the peripheral list
    func disconnect() {
        guard let central else { return }
        let connectedPeripherals = peripherals.filter({ $0.state == .connected })
        connectedPeripherals.forEach { peripheral in
            central.cancelPeripheralConnection(peripheral)
            peripherals.removeAll(where: {$0.identifier == peripheral.identifier})
        }
    }

}

// MARK: - the CentralManager delegate

extension DeviceController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        debugLog.info("state updated to \(central.state.description)")
        switch central.state {
        case .poweredOn:
            startScan()
        default:
            debugLog.critical("\(central.state.description)")
        }
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        debugLog.info("Not implemented")
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let name = peripheral.name,
              name.contains(/CC2650/),
              !peripherals.contains(where: {$0 == peripheral}) else {
            return
        }
        debugLog.info("here is one: \(peripheral.name.orEmpty)")
        peripherals.append(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Task {
            do {
                let sensorTag = try await CC2650SensorTag(peripheral)
                connectionContinuation?.resume(returning: sensorTag)
            } catch {
                connectionContinuation?.resume(throwing: error)
                central.cancelPeripheralConnection(peripheral)
            }
        }
    }
}

enum DeviceControllerError: Error {
    case invalidCentral
    case invalidPeripheral
}
