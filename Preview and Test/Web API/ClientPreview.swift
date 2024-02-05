//
//  ClientPreview.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices

/// The Preview can be used for preview in SwiftUI and for runninng unit test
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
    
    func getAssignments(since: Date) async throws -> [Assignment] {
        return try .load(filename: "assignments")
    }
    
    func post(_ assignment: Assignment) async throws {

    }
}

