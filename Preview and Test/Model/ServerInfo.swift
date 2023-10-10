//
//  ServerInfo.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation

struct ServerInfo: Codable {
    var name: String
    var environment: String
    var build: String
}

extension ServerInfo {
    static let preview = ServerInfo(name: "server1", environment: "preview", build: "0")
}
