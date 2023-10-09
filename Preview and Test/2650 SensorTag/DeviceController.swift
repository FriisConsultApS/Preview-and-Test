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

@Observable final class DeviceController: NSObject {
    private(set) var peripherals: [CBPeripheral] = []

    private  var bleQueue = DispatchQueue(label: "com.friismobility.mars.task",qos: .background)
    private  var central: CBCentralManager?

    private let debugLog: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "\(DeviceController.self)")

    private var connectionContinuation: CheckedContinuation<any SensorTagProtocol, Error>?

    /// As we don't want the user to be prompted for
    func startBLE() {
        central = CBCentralManager(delegate: self, queue: bleQueue , options: [CBCentralManagerOptionRestoreIdentifierKey: "com.friismobility.mars.task"])
    }

    func startScan() {
        guard let central else {
            startBLE()
            return
        }
        debugLog.info("Start scan for services")
        central.scanForPeripherals(withServices: nil)
    }

    func connect(_ peripheral: CBPeripheral) async throws -> any SensorTagProtocol {
        guard let central else { throw DeviceControllerError.invalidCentral }

        guard peripherals.contains(where: {$0 == peripheral}) else {
            throw DeviceControllerError.invalidPeripheral
        }

        central.stopScan()

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<any SensorTagProtocol, Error>) in
            connectionContinuation = continuation
            central.connect(peripheral)
        }
    }

    func disconnect() {
        guard let central else { return }
        let connectedPeripherals = peripherals.filter({ $0.state == .connected })
        connectedPeripherals.forEach { peripheral in
            central.cancelPeripheralConnection(peripheral)
            peripherals.removeAll(where: {$0.identifier == peripheral.identifier})
        }
    }

}


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
            }
        }
    }
}

enum DeviceControllerError: Error {
    case invalidCentral
    case invalidPeripheral
}
