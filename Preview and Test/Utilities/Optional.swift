//
//  Optional.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import Foundation

extension Optional where Wrapped == String {
    var orEmpty: String {
        get { self ?? "" }
        set { self = newValue }
    }
}

extension Optional where Wrapped == Date {
    var orDistanceParse: Date {
        self ?? .distantPast
    }

    var orNow: Date {
        self ?? .now
    }

    var orDistanceFuture: Date {
        self ?? .distantFuture
    }
}
