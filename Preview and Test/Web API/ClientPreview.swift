//
//  ClientPreview.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices

struct ClientPreview: APIProtocol {
    var serverInfo: ServerInfo {
        get async throws {
            try await Task.sleep(nanoseconds: 1_500_000)
            return .preview
        }
    }


    var userProfile: UserProfile {
        get async throws {
            .preview
        }
    }


    func signInWithAppel(_ auth: ASAuthorization) async throws -> UserProfile {
        .preview
    }
    
    func getTaskItems(since: Date) async throws -> [TaskItemDTO] {
        return try .load(filename: "tasks")
    }
    
    func postTaskItem(_ taskItem: TaskItemDTO) async throws {

    }
}

