//
//  SensorOptions.swift
//  Preview and Test
//
//  Created by Per Friis on 06/01/2024.
//

import Foundation

/// options set of all the available sensors.
struct SensorOptions: OptionSet {
    var rawValue: UInt64
    static let battery = SensorOptions(rawValue: 1 << 0)
    static let buttons = SensorOptions(rawValue: 1 << 1)
    static let humidity = SensorOptions(rawValue: 1 << 2)
    static let barometic = SensorOptions(rawValue: 1 << 3)
    static let tempreture = SensorOptions(rawValue: 1 << 4)
    static let irTemperature = SensorOptions(rawValue: 1 << 5)
    static let lux = SensorOptions(rawValue: 1 << 6)
    static let color = SensorOptions(rawValue: 1 << 7)
    static let image = SensorOptions(rawValue: 1 << 8)
    static let gyroscope = SensorOptions(rawValue: 1 << 9)
    static let magnetrometer = SensorOptions(rawValue: 1 << 10)
    static let proximity = SensorOptions(rawValue: 1 << 11)
    static let gesture = SensorOptions(rawValue: 1 << 12)
    
    static let all: SensorOptions = [ .battery,
        .buttons,
        .humidity, .barometic, .tempreture, .irTemperature, 
        .lux, .color, .image,
        .gyroscope, .magnetrometer, .proximity, .gesture]
}
