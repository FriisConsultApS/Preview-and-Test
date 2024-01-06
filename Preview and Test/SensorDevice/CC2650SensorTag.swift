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
@Observable class CC2650SensorTag: NSObject, SensorDeviceProtocol {
   
    var name: String = ""
    var systemId: String = ""
    var modelNumber: String = ""
    var serialNumber: String = ""
    var firmwareRevision: String = ""
    var hardwareRevision: String = ""
    var softwareRevision: String = ""
    var manufactureName: String = ""
    var regulatoryCertification: String = ""
    var pnpId: String = ""


    var (battery, batteryContinuation) = AsyncStream.makeStream(of: BatteryStatus.self)

    var (buttons, buttonsContinuation) = AsyncStream.makeStream(of: DeviceButtons.self)

    var (humidity, humidityContinuation) = AsyncStream.makeStream(of: Double.self)
    var (barometic, barometicContinuation) = AsyncStream.makeStream(of: Double.self)
    var (tempreture, tempretureContinuation) = AsyncStream.makeStream(of: Double.self)
    var (irTemperature, irTemperatureContinuation) = AsyncStream.makeStream(of: Double.self)

    var (lux, luxContinuation) =  AsyncStream.makeStream(of: Double.self)
    var (color, colorContinuation) =  AsyncStream.makeStream(of: Color.self)
    var (image, imageContinuation) =  AsyncStream.makeStream(of: Image.self)
    
    
    var (gyroscope, gyroscopeContinuation) =  AsyncStream.makeStream(of: SIMD3<Double>.self)
    var (magnetrometer, magnetrometerContinuation) =  AsyncStream.makeStream(of: SIMD3<Double>.self)
    var (proximity, proximityContinuation) =  AsyncStream.makeStream(of: Double.self)
    var (gesture, gestureContinuation) =  AsyncStream.makeStream(of: GestureSensor.self)

    var availableSensors: SensorOptions = [.barometic, .humidity, .lux, .battery, .buttons]
    private var peripheral: CBPeripheral
    private var initContinuation: CheckedContinuation<Void, Error>?

    /// This is a cool way to handle the async init, inserting all the states as we progress with the discovery of the Services and characteristics.
    private var state: CC2650State = []

    private var opticalData: CBCharacteristic?
    private var opticalConfiguration: CBCharacteristic?
    private var opticalPeriod: CBCharacteristic?

    private var humidityData: CBCharacteristic?
    private var humidityConfiguration: CBCharacteristic?
    private var humidityPeriod: CBCharacteristic?
    
    private var barometricData: CBCharacteristic?
    private var barometricConfiguration: CBCharacteristic?


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
                                              .opticalService, .barometricPressureService, .humidityService])
        }
        try? opticalStream(on: true)
        try? humidityStream(on: true)
        try? barometricStream(on: true)
        timeout.cancel()
    }

    /// start or stops the optical sensor
    private func opticalStream(on: Bool) throws {
        guard let opticalConfiguration,
              let opticalPeriod,
              let opticalData else {
            throw CC2650Error.noCharacteristics
        }
        peripheral.setNotifyValue(on, for: opticalData)
        peripheral.writeValue(on ? .on : .off, for: opticalConfiguration, type: .withResponse)
        peripheral.writeValue(.twoSeconds, for: opticalPeriod, type: .withResponse)
    }


    /// start or stops the humidity sensor
    private func humidityStream(on: Bool) throws {
        guard let humidityConfiguration,
              let humidityPeriod,
              let humidityData else {
            throw CC2650Error.noCharacteristics
        }
        peripheral.setNotifyValue(on, for: humidityData)
        peripheral.writeValue(on ? .on : .off, for: humidityConfiguration, type: .withResponse)
        peripheral.writeValue(.twoSeconds, for: humidityPeriod, type: .withResponse)
    }

    // start and stops the barometric sensor
    private func barometricStream(on: Bool) throws {
        guard let barometricConfiguration,
              let barometricData else {
            throw CC2650Error.noCharacteristics
        }
        peripheral.setNotifyValue(on, for: barometricData)
        peripheral.writeValue(on ? .on : .off, for: barometricConfiguration, type: .withResponse)
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

        if let humidityService = services.first(where: {$0.uuid == .humidityService}) {
            peripheral.discoverCharacteristics([.humidityData, .humidityPeriod, .humidityConfiguration], for: humidityService)
        }
        
        if let barometricService = services.first(where: {$0.uuid == .barometricPressureService}) {
            peripheral.discoverCharacteristics([.barometricData, .barometricPeriod, .barometricConfiguration], for: barometricService)
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
            } else {
                debugLog.critical("optical")
            }
        }

        if service.uuid == .humidityService {
            humidityData = characteristics.first(where: {$0.uuid == .humidityData})
            humidityConfiguration = characteristics.first(where: {$0.uuid == .humidityConfiguration})
            humidityPeriod = characteristics.first(where: {$0.uuid == .humidityPeriod})
            if humidityData != nil, humidityConfiguration != nil, humidityPeriod != nil {
                state.insert(.humidityService)
            } else {
                debugLog.critical("humidity")
            }
        }

        if service.uuid == .barometricPressureService {
            barometricData = characteristics.first(where: {$0.uuid == .barometricData})
            barometricConfiguration = characteristics.first(where: {$0.uuid == .barometricConfiguration})
            if humidityData != nil, humidityConfiguration != nil {
                state.insert(.barometricService)
            } else {
                debugLog.critical("barometric")
            }
        }
        
        if state == .ready {
            initContinuation?.resume()
            initContinuation = nil
        }
        debugLog.info("is ready\(self.state == .ready)")
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
            
        case .systemId:
            self.systemId = value.string
            
        case .serialNumber: 
            self.serialNumber = value.string
            
        case .firmwareRevision:
            self.firmwareRevision = value.string
            
        case .hardwareRevision:
            self.hardwareRevision = value.string
            
        case .softwareRevision:
            self.softwareRevision = value.string
            
        case .manufactureName:
            self.manufactureName = value.string
            
        case .regulatoryCertification:
            self.regulatoryCertification = value.string
            
        case .pnpId:
            self.pnpId = value.string

        case .batteryLevel:
            let level = Double(value[0]) / 100
            batteryContinuation.yield(.notCharging(level))

        case .simpleKeyState:
            let button = DeviceButtons(rawValue: value[0])
            buttonsContinuation.yield(button)

        case .opticalData:
            do {
                let exponent = (try value.uint16 >> 12) & 0x0F // extract the 4 most significant bits
                let result = Double(try value.uint16 & 0x0FFF) // extract the remaining 12 bits
                let lux = result * 0.01 * pow(2.0, Double(exponent))
                luxContinuation.yield(lux)
            } catch {
                debugLog.error("\((error as NSError).localizedDescription)")
                luxContinuation.yield(.nan)
            }

        case .humidityData:
            do {
                let humidityBytes = try value[0...1].uint16
                let exponent = (humidityBytes >> 12) & 0x0F
                let result = Double(humidityBytes & 0x0FFF)
                
                let humidity =  result * 0.01 * pow(2.0, Double(exponent))
                debugLog.info("humidity: \(humidity.formatted(.percent))")
                humidityContinuation.yield(humidity)
            } catch {
                debugLog.error("\((error as NSError).localizedDescription)")
                humidityContinuation.yield(.nan)
            }
            
        case .barometricData:
            if value.count >= 6 {
                let byte3 = UInt32(value[3])
                let byte4 = UInt32(value[4])
                let byte5 = UInt32(value[5])
                
                let result = (byte3 | (byte4 << 8) | (byte5 << 16)) / 100
                debugLog.info("result \(result)")
                barometicContinuation.yield(Double(result))
            } else {
                debugLog.critical("baro\(value.hex)")
                barometicContinuation.yield(.nan)
            }
            

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
        var rawValue: UInt16
        static let deviceInfoService    = CC2650State(rawValue: 1 << 0)
        static let batteryService       = CC2650State(rawValue: 1 << 1)
        static let simpleKeyService     = CC2650State(rawValue: 1 << 2)
        static let barometricService    = CC2650State(rawValue: 1 << 3)
        static let humidityService      = CC2650State(rawValue: 1 << 4)
        static let opticalService       = CC2650State(rawValue: 1 << 5)
        
        static let ready: CC2650State = [
            .deviceInfoService, batteryService, .simpleKeyService,
            .opticalService, .humidityService, .barometricService
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
    static let twoSeconds = Data([0xC8])
    static let oneSecond = Data([0x64])
    static let tenthSecond = Data([0x0A])

    static let enableAllMotion = Data([0x07])
}

// MARK: - definition of the CC2650 SensorTag services and Characteristics.
extension CBUUID {
    
    static let scanServices: [CBUUID] = [.advertisedservice]
    static let advertisedservice    = CBUUID(string: "AA80")
    
    /// Humidity Service and characistics
    static let humidityService              = CBUUID(string:"F000AA20-0451-4000-B000-000000000000")
    static let humidityData                 = CBUUID(string:"F000AA21-0451-4000-B000-000000000000")
    static let humidityConfiguration        = CBUUID(string:"F000AA22-0451-4000-B000-000000000000")
    static let humidityPeriod               = CBUUID(string:"F000AA23-0451-4000-B000-000000000000")

    /// Barometric Pressure Service and characistics
    static let barometricPressureService    = CBUUID(string:"F000AA40-0451-4000-B000-000000000000")
    static let barometricData               = CBUUID(string:"F000AA41-0451-4000-B000-000000000000")
    static let barometricConfiguration      = CBUUID(string:"F000AA42-0451-4000-B000-000000000000")
    static let barometricPeriod             = CBUUID(string:"F000AA43-0451-4000-B000-000000000000")

    /// Optical Service (Light) and characistics
    static let opticalService               = CBUUID(string:"F000AA70-0451-4000-B000-000000000000")
    static let opticalData                  = CBUUID(string:"F000AA71-0451-4000-B000-000000000000")
    static let opticalConfiguration         = CBUUID(string:"F000AA72-0451-4000-B000-000000000000")
    static let opticalPeriod                = CBUUID(string:"F000AA73-0451-4000-B000-000000000000")


    /// Simple Key Service and characistics
    static let simpleKeyService             = CBUUID(string: "FFE0")
    static let simpleKeyState               = CBUUID(string: "FFE1")

    /// Battery service and characistics
    static let batteryService = CBUUID(string: "180F")
    static let batteryLevel = CBUUID(string: "2A19")

    /// Device Information Service and characistics
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
