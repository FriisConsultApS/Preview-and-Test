//
//  ApiAuthResponse.swift
//  Preview and Test
//
//  Created by Per Friis on 05/02/2024.
//

import Foundation

struct ApiAuthResponse: Decodable {
    let tokenType: String
    let authorizationToken: String
    let refreshToken: String
    let expiration: Date
}
