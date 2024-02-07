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
            let data = try await apiEndPoint(apiComponents: .users, .profile)
            return try JSONDecoder().decode(UserProfile.self, from: data)
        }
    }

    func signInWithAppel(_ auth: ASAuthorization) async throws -> UserProfile {
        let data = try await apiEndPoint(method: .POST, apiComponents: .authenticate, .signInWithApple, authorize: false)
        self.authResponse = try JSONDecoder().decode(ApiAuthResponse.self, from: data)
        return try await userProfile
    }

    func getAssignments(since: Date) async throws -> [Assignment] {
        let data = try await apiEndPoint(apiComponents: .assignments)
        return try JSONDecoder().decode([Assignment].self, from: data)
    }

    func post(_ assignment: Assignment) async throws {
        try await apiEndPoint(method: .POST, apiComponents: .assignments, form: assignment)
    }
    
    
    // MARK: - actual implementation of the calls to the endpoint
    @KeychainStored("authToken") var authTokenKeyChain
    @KeychainStored("refreshToken") var refreshTokenKeyChain
    
    private let urlSession = URLSession.shared
    
    /// Holds the response from authorization on backend
    private var authResponse: ApiAuthResponse? {
        didSet {
            authTokenKeyChain = authResponse?.authorizationToken
            refreshTokenKeyChain = authResponse?.refreshToken
        }
    }
    
    /// return a valid authorization token, if the token has expired, it will try to refresh the doken
    private var authToken: JsonWebToken? {
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
    
    
    /// Standard implementation of the URL requstt
    /// - Parameters:
    ///   - method: Http Method for the endpoint, default is  .GET, other helper values is ``ApiMethod``
    ///   - apiComponents: a list of parth elements, eg. /users/gdpr would be .users, .gdpr and the static will be definded as ``ApiComponent``
    ///   - form: any endodable object, if needed for the call
    ///   - header: Dictionary of header, note, this is not reversed as the actual addValue.forHTTPHeaderField
    ///   - since: this value will be added to a header field, with the same name, formatted as ISO8601
    ///   - authorize: if the authorization/ standard JWT is to be in the header, this is default true, as it is only for signin it is omittetd
    /// - Returns: Data data returned from the endpoint
    /// - Throws: There is an extension on ``HTTPURLResponse`` that returns the response as an error. other errors thrown from the system calls is also carried on
    @discardableResult private func apiEndPoint(method: ApiMethod = .GET, apiComponents: ApiComponent..., form: Encodable? = nil, header: [String: String]? = nil, since: Date? = nil, authorize: Bool = true) async throws -> Data {
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



