//
//  APIProtocol.swift
//  Preview and Test
//
//  This protocol is used to communicate with a backend. the inspiration is taken
//  from the openAPI project however, I tried the openAPI project in August 2023
//  at that time i found that it was far from being usable, and the projected path
//  was on a way that I didn't see my self using. as it was over complicated with double,
//  double, double naming, mixture of Snake and camelcase. I see the temptation to
//  have the implementation created automatically from openAPI, but what I saw, it wasn't it
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices


protocol APIProtocol {
    var serverInfo: ServerInfo { get async throws }
    var userProfile: UserProfile { get async throws }
    func signInWithAppel(_ auth: ASAuthorization) async throws -> UserProfile

    func getTaskItems(since: Date) async throws -> [TaskItemDTO]
    func postTaskItem(_ taskItem: TaskItemDTO) async throws
}

enum ApiError: Error {
    case notAuthorized
    case notImplemented
}
