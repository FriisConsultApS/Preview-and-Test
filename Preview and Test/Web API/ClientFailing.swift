//
//  ClientFailing.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices

struct ClientFailing: APIProtocol {
    var serverInfo: ServerInfo {
        get async throws {
            try await Task.sleep(nanoseconds: 2_000_000)
            throw ApiError.notAuthorized
        }
    }

    var userProfile: UserProfile {
        get async throws {
            throw ApiError.notAuthorized
        }
    }

    func signInWithAppel(_ auth: ASAuthorization) async throws -> UserProfile {
        throw ApiError.notAuthorized
    }
    
    func getTaskItems(since: Date) async throws -> [TaskItemDTO] {
        throw ApiError.notAuthorized
    }
    
    func postTaskItem(_ taskItem: TaskItemDTO) async throws {
        throw ApiError.notAuthorized
    }
}

