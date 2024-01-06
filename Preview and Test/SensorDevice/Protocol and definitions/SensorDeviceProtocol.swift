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
protocol SensorDeviceProtocol {
    // MARK: - Static properties
    /// The name of the device, not the device type
    var name: String { get }
    
    /// A system id
    var systemId: String { get }
    
    /// the model number
    var modelNumber: String { get }
    
    /// Any kind of serial number
    var serialNumber: String { get }
    
    /// curent firmware version
    var firmwareRevision: String { get }
    
    /// hardware version
    var hardwareRevision: String { get }
    
    /// software version
    var softwareRevision: String { get }
    
    /// Name of the manufacturing company
    var manufactureName: String { get }
    
    /// if any regulatory certification is present
    var regulatoryCertification: String { get }
    
    /// Plug and Play ID
    var pnpId: String { get }
    
    // MARK: - Streams
    /// a stream of the current battery level and charge status
    var battery: AsyncStream<BatteryStatus> { get }
    
    /// update the current button state
    var buttons: AsyncStream<DeviceButtons> { get }
    
    // MARK: Environmental sensors
    ///Current humidity in ...
    var humidity: AsyncStream<Double> { get }
    
    /// Barometric pressure in mB
    var barometic: AsyncStream<Double> { get }
    
    /// Tempreture messured with a standard termometer in Censitus
    var tempreture: AsyncStream<Double> { get }
    
    /// Tempreture messured with a Infared termometer in Censitus
    var irTemperature: AsyncStream<Double> { get }
    
    // MARK: optical sensors
    /// Current light intenticy
    var lux: AsyncStream<Double> { get }
    /// the color seen by the color sensor
    var color: AsyncStream<Color> { get }
    /// image, if the re is any
    var image: AsyncStream<Image> { get }
    
    
    // MARK: motion sensors
    /// Current level in the gyroscope usulally relative to the start position
    var gyroscope: AsyncStream<SIMD3<Double>> { get }
    /// What kind of magnetisme there is in the 3D space of the sensor
    var magnetrometer: AsyncStream<SIMD3<Double>> { get }
    /// distance to an detected object on cm
    var proximity: AsyncStream<Double> { get }
    /// gesture of an detected object, moving against .. right, left, up, down
    var gesture: AsyncStream<GestureSensor> { get }
    
    /// An option set with the available sensors on the actual implentation
    var availableSensors: SensorOptions { get }

    init(_ peripheral: CBPeripheral?) async throws
}
