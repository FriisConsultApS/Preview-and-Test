//
//  Client.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation
import AuthenticationServices

/// This is a shell inplementatoin, as this project was not created with an actual backend.
class Client: APIProtocol {
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
    
    
    // MARK: - actual implementation of the calls to the endpoint
    @KeychainStored("authToken") var authTokenKeyChain
    @KeychainStored("refreshToken") var refreshTokenKeyChain
    
    private let urlSession = URLSession.shared
    
    private var authResponse: ApiAuthResponse? {
        didSet {
            authTokenKeyChain = authResponse?.authorizationToken
            refreshTokenKeyChain = authResponse?.refreshToken
        }
    }
    
    private var authToken: String? {
        get async throws {
            guard let authToken = authResponse?.authorizationToken,
                  !authToken.isEmpty,
                  let refreshToken = authResponse?.refreshToken,
                  !refreshToken.isEmpty else {
                throw ApiError.notAuthenticated
            }

            guard authToken.expired else {
                return authToken
            }

            let data = try await apiEndPoint(method: .POST, apiComponents: .authenticate, header: [.authorization: authToken.bearer, .refreshToken: refreshToken], authorize: false)
            self.authResponse = try JSONDecoder().decode(ApiAuthResponse.self, from: data)
            return authResponse?.authorizationToken
        }
    }
    
    
    /// Standard implemtation of the url request/session returning the data
    @discardableResult
    private func apiEndPoint(method: ApiMethod = .GET, apiComponents: ApiComponent..., form: Encodable? = nil, header: [String: String]? = nil, since: Date? = nil, authorize: Bool = true) async throws -> Data {
        do {
            let authToken: String?
            if authorize {
                authToken = try await self.authToken
            } else {
                authToken = nil
            }
            
            var url = try URL.apiServer
            for apiComponent in apiComponents {
                url.append(component: apiComponent)
            }
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method
            urlRequest.addValue(.apiKey, forHTTPHeaderField: .apiKeyName)
            urlRequest.addValue(.applicationJson, forHTTPHeaderField: .contentType)
            #if DEBUG
            urlRequest.addValue("development", forHTTPHeaderField: "environment")
            #else
            urlRequest.addValue("production", forHTTPHeaderField: "environment")
            #endif

            
            if let authToken {
                urlRequest.addValue(authToken.bearer, forHTTPHeaderField: .authorization)
            }
            
            
            urlRequest.httpBody = form?.json
            if let header {
                header.forEach { (key: String, value: String) in
                    urlRequest.addValue(value, forHTTPHeaderField: key)
                }
            }
            
            if let since {
                urlRequest.addValue(since.ISO8601Format(.iso8601WithTimeZone()), forHTTPHeaderField: .since)
            }
            let (data, response) = try await urlSession.data(for: urlRequest)
            
            guard response.http.success else {
                throw response.http
            }
            return data
        } catch {
            throw error
        }        
    }
}



