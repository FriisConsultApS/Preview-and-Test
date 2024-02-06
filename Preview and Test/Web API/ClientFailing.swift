//
//  ClientFailing.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices

/// This is to ensure that we can request error and thereby handle errors accordantly
struct ClientFailing: APIProtocol {
    var serverInfo: ServerInfo {
        get async throws {
            try await Task.sleep(nanoseconds: 2_000_000)
            throw ApiError.unauthorized
        }
    }

    var userProfile: UserProfile {
        get async throws {
            throw ApiError.unauthorized
        }
    }

    func signInWithAppel(_ auth: ASAuthorization) async throws -> UserProfile {
        throw ApiError.unauthorized
    }
    
    func getAssignments(since: Date) async throws -> [Assignment] {
        throw ApiError.unauthorized
    }
    
    func post(_ assignment: Assignment) async throws {
        throw ApiError.unauthorized
    }
}

