//
//  CloudCoordinator.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import SwiftUI
import AuthenticationServices
import SwiftData
import OSLog

/// This coordinator, is the layer between the actual backend and the app.
///
/// The advantage of this, is that you can switch the ``CloudCoordinator/client`` around to use a mock of the backend, this is used for Preview and Test
@Observable class CloudCoordinator {
    private(set) var user: UserProfile?
    private(set) var serverInfo: ServerInfo?
    
    private(set) var authenticationStatus: AuthenticationStatus = .unknown
    
    private(set) var client: APIProtocol
    var modelContainer: ModelContainer!
    
    private let debugLog: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "\(CloudCoordinator.self)")
    
    @KeychainStored("appleId") private static var appleId: String?
    
    /// Initialize the Cloud coordinator
    /// - Parameter client: connection to the backend
    init(_ client: APIProtocol = Client())  {
        self.client = client
        Task {
            self.serverInfo = try await client.serverInfo
            
            if let appleId = Self.appleId {
                authenticationStatus = .updating
                do {
                    let authState = try await ASAuthorizationAppleIDProvider()
                        .credentialState(forUserID: appleId)
                    switch authState {
                    case .revoked,
                            .notFound,
                            .transferred:
                        self.authenticationStatus = .unauthorized
                        
                    case .authorized:
                        self.authenticationStatus = .authorized
                        self.user = try await client.userProfile
                        
                    @unknown default:
                        fatalError()
                    }
                } catch {
                    authenticationStatus = .unknown
                }
            } else {
                authenticationStatus = .unknown
            }
        }
    }
    
    /// do the sign in to the backend
    /// - Parameter authorization: sign in with apple authorization
    func signInWithApple(_ authorization: ASAuthorization) {
        authenticationStatus = .updating
        guard let credentials = authorization.credential as? ASAuthorizationAppleIDCredential else {
            authenticationStatus = .unauthorized
            return
        }
        Task {
            do {
                Self.appleId = credentials.user
                authenticationStatus = .authorized
                user = try await client.signInWithAppel(authorization)
            } catch {
                authenticationStatus = .unknown
            }
        }
    }
    
    /// upload a list of assignment items
    /// - note: this is not the way I usually would do it, but for the sample purpose it will work
    /// - Parameter assignments: list of assignment
    func uploadTaskItems(_ assignments: [Assignment]) async throws {
        for assignment in assignments {
            try await client.post(assignment)
        }
    }
    
    
    /// Download all tasks from the backend
    /// - Parameter since: only download task that has been updated since ...
    func downloadTasks(since: Date = .distantPast) async throws {
        let assignments = try await client.getAssignments(since: since)
        let context = ModelContext(modelContainer)
        for assignment in assignments {
            if let existing = context.model(for: assignment.id) as? Assignment {
                existing.update(assignment)
            } else {
                context.insert(assignment)
            }
        }
        try context.save()
    }
}

enum AuthenticationStatus {
    case unknown
    case updating
    case authorized
    case unauthorized
}

extension CloudCoordinator {
    static let preview = CloudCoordinator(ClientPreview())
    static let previewAuthorized: CloudCoordinator = {
        let coordinator = CloudCoordinator(ClientPreview())
        coordinator.authenticationStatus = .authorized
        return coordinator
    }()
    
    static let previewUpdating: CloudCoordinator = {
        let coordinator = CloudCoordinator(ClientPreview())
        coordinator.authenticationStatus = .updating
        return coordinator
    }()
}
