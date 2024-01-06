//
//  DeviceButtons.swift
//  Preview and Test
//
//  Created by Per Friis on 06/01/2024.
//

import Foundation
import SwiftUI

/// and "option set" that shows what buttons that are pressed
struct DeviceButtons: OptionSet {
    var rawValue: UInt8

    static let one = DeviceButtons(rawValue: 1 << 0)
    static let two = DeviceButtons(rawValue: 1 << 1)
    static let tree = DeviceButtons(rawValue: 1 << 2)
    static let foure = DeviceButtons(rawValue: 1 << 3)
    static let five = DeviceButtons(rawValue: 1 << 4)

    static let all: DeviceButtons = [.one, .two, .tree, .foure, .five]

    var image: Image {
        switch self {
        case .all:
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
