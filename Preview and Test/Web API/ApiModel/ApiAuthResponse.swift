//
//  ApiAuthResponse.swift
//  Preview and Test
//
//  Created by Per Friis on 05/02/2024.
//

import Foundation
import JWTDecode


/// The response coming from the server when authorising
struct ApiAuthResponse: Decodable {
    let tokenType: String
    let authorizationToken: JsonWebToken
    let refreshToken: String
    let expiration: Date
}

typealias JsonWebToken = String

extension JsonWebToken {
    var expired: Bool {
        do {
            return try decode(jwt: self).expired
        } catch {
            return true
        }
    }
    
    var bearer: String {
        "bearer \(self)"
    }
}
