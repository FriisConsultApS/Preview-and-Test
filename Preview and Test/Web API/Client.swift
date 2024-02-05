//
//  Client.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices

/// This is a shell inplementatoin, as this project was not created with an actual backend.
struct Client: APIProtocol {
    var serverInfo: ServerInfo {
        get async throws {
            throw ApiError.notImplemented
        }
    }

    var userProfile: UserProfile {
        get async throws {
            throw ApiError.notImplemented
        }
    }

    func signInWithAppel(_ auth: ASAuthorization) async throws -> UserProfile {
        throw ApiError.notImplemented
    }

    func getAssignments(since: Date) async throws -> [Assignment] {
        throw ApiError.notImplemented
    }

    func post(_ assignment: Assignment) async throws {
        throw ApiError.notImplemented
    }
}
