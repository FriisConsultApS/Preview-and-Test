//
//  CloudCoordinator.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import SwiftUI
import AuthenticationServices
import CoreData
import OSLog

@Observable class CloudCoordinator {
    private(set) var user: UserProfile?
    private(set) var serverInfo: ServerInfo?

    private(set) var authenticationStatus: AuthenticationStatus = .unknown

    private(set) var client: APIProtocol
    private let debugLog: Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "\(CloudCoordinator.self)")

    @KeychainStored("appleId") private static var appleId: String?


    init(_ client: APIProtocol = Client())  {
        self.client = client

        if let appleId = Self.appleId {
            authenticationStatus = .updating
            Task {
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
            }
        } else {
            authenticationStatus = .unknown
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
                user = try await client.userProfile
            } catch {
                authenticationStatus = .unknown
            }
        }
    }

    /// upload a list of task items
    /// - note: this is not the way I usually would do it, but for the sample purpose it will work
    /// - Parameter taskItems: list of tasks
    func uploadTaskItems(_ taskItems: [TaskItem]) async throws {
        for taskItem in taskItems {
            try await client.postTaskItem(taskItem.dto)
        }
    }


    func downloadTasks(since: Date = .distantPast, to context: NSManagedObjectContext) async throws {
        let taskDtos = try await client.getTaskItems(since: since)
        for taskDto in taskDtos {
            _ = TaskItem(taskDto, insertInto: context)
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
