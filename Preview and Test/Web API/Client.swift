//
//  Client.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices

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

    func getTaskItems(since: Date) async throws -> [TaskItemDTO] {
        throw ApiError.notImplemented
    }

    func postTaskItem(_ taskItem: TaskItemDTO) async throws {
        throw ApiError.notImplemented
    }
}
