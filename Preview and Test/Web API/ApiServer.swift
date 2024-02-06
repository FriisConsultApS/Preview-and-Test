//
//  ApiServer.swift
//  Preview and Test
//
//  Created by Per Friis on 05/02/2024.
//
// This is the actual definition of the server

import Foundation



extension URL {
    /// Get the relevant base url for the current enviironment
    static var apiServer: URL {
        get throws {
            /// This can be set in the scheme, for local development I use ngrok.com
            if let serverURLString = ProcessInfo.processInfo.environment["SERVER_URL"] {
                guard let url = URL(string: serverURLString) else {
                    throw ApiError.invalidParameter("invalid Server URL: \(serverURLString)")
                }
                return url
            }
            
            /// This is for debug and test, it works on TestFlight aswell.
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
               appStoreReceiptURL.lastPathComponent == "sandboxReceipt" {
                guard let url = URL(string: "https://dev.friisconsult.net/api") else {
                    throw ApiError.invalidParameter("https://dev.friisconsult.net/api - sanbox")
                }
                return url
            }
            
            /// And finally the production server....
            guard let url = URL(string: "https://dk.friisconsult.net/api") else {
                throw ApiError.invalidParameter("https://dk.friisconsult.net/api")
            }
            
            return url
        }
    }
}

typealias ApiMethod = String
extension ApiMethod {
    static let GET = "GET"
    static let POST = "POST"
    static let PUT = "PUT"
    static let PATCH = "PATCH"
    static let DELETE = "DELETE"
}

typealias ApiComponent = String

extension ApiComponent {
    static let authenticate = "authenticate"
}


/// headerfield keys
extension String {
    static let authorization = "authorization"
    static let refreshToken = "refreshToken"
    
    static let apiKeyName = "x-api-key"
    static let apiKey = "This is not the way to store api key"
    
    static let applicationJson = "application/json"
    static let contentType = "Content-Type"
    static let since = "since"
}
