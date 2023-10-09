//
//  Data extensions.swift
//  Preview and Test
//
//  Created by Per Friis on 09/10/2023.
//

import Foundation

extension Data {
    var apnsToken: String {
        map {data in String(format: "%02.2hhx",data)}.joined()
    }

    var string: String {
        String(data: self, encoding: .utf8) ?? hex
    }

    var hex: String { map { String(format: "%02X", $0)}.joined(separator: ":")}

    var int16: Int16 {
        let uint = uint16
        return uint <= UInt16(Int16.max) ? Int16(uint) : Int16(uint - UInt16(Int16.max) - 1) + Int16.min
    }

    var uint16: UInt16 { withUnsafeBytes { $0.load(as: UInt16.self) } }

    var int32: Int32 {
        let uint = uint32
        return uint <= UInt32(Int32.max) ? Int32(uint) : Int32(uint - UInt32(Int32.max) - 1) + Int32.min
    }

    var uint32: UInt32 { withUnsafeBytes { $0.load(as: UInt32.self) }  }

    var float: Float {
        Float(bitPattern: UInt32(bigEndian: self.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }
}

extension UInt8 {
    var hex: String { String(format: "%02X", self)}

    var int8 : Int8 {
        return (self <= UInt8(Int8.max)) ? Int8(self) : Int8(self - UInt8(Int8.max) - 1) + Int8.min
    }

}

extension UInt16 {
    init(_ data: Data) {
        self = UInt16(data[0]) << 8 + UInt16(data[1])
    }
}

extension UInt32 {
    init(_ data: Data) {
        self = UInt32(data[0]) << 24 + UInt32(data[1]) << 16 + UInt32(data[2]) << 8 + UInt32(data[3])
    }

    var hex: String { String(format: "%04X", self)}

}

extension String {
    func pad(with character: String, toLength length: Int) -> String {
        let padCount = length - self.count
        guard padCount > 0 else { return self }

        return String(repeating: character, count: padCount) + self
    }
}
