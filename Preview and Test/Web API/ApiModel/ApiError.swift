//
//  ApiError.swift
//  Preview and Test
//
//  Created by Per Friis on 05/02/2024.
//

import Foundation

/// Holds all the APIProtocol errors available for the implementation of the API protocol
enum ApiError: Error, LocalizedError, CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        switch self {
        case .offLine:
            "Server is unreachable"

        case .invalidParameter(let string):
            "Invalid parameter \(string)"

        case .notAuthenticated:
            "Not authenticated"

        case .unauthorized:
            "Unauthorized user"

        case .notImplemented:
            "This property/function has not been implemented"
            
        case .notModified:
            "The content have not been modified since last call"
            
        case .passthrough(let error):
            error.localizedDescription
        }
    }

    
    var debugDescription: String { description }

    /// The server could not be reached or call fails to respond correctly
    case offLine

    /// The parameter to the function call is invalid or are missing critical characteristic
    case invalidParameter(String)

    /// if the user haven't been authenticated yet
    case notAuthenticated

    /// If the user can't login
    case unauthorized
    
    /// the content has not change since last call
    case notModified
    
    /// Used for placeholders that has not been implemented yet or not necessary for the current purpose
    case notImplemented
    
    case passthrough(Error)
}
