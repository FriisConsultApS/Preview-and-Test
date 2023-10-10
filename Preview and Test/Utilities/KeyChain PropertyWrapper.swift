//
//  KeyChain PropertyWrapper.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation

import Security
/// @KeychainStored("userToken") var userToken: String?
@propertyWrapper struct KeychainStored {
    private let key: String

    init(_ key: String) {
        self.key = key
    }

    var wrappedValue: String? {
        get {
            guard let data = keychainData(forKey: key) else { return nil }
            return String(data: data, encoding: .utf8)
        }
        set {
            guard let newValue = newValue else {
                removeKeychainData(forKey: key)
                return
            }
            guard let data = newValue.data(using: .utf8) else { return }
            setKeychainData(data, forKey: key)
        }
    }

    private func keychainQuery(forKey key: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
    }

    private func keychainData(forKey key: String) -> Data? {
        var query = keychainQuery(forKey: key)
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        if status == noErr {
            return result as? Data
        } else {
            return nil
        }
    }

    private func setKeychainData(_ data: Data, forKey key: String) {
        var query = keychainQuery(forKey: key)
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == noErr {
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        } else {
            query[kSecValueData as String] = data
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    private func removeKeychainData(forKey key: String) {
        let query = keychainQuery(forKey: key)
        SecItemDelete(query as CFDictionary)
    }
}



/*
struct KeyChainItem {
    private static let debugLog: os.Logger = .init(subsystem: Bundle.main.bundleIdentifier!, category: "\(KeyChainItem.self)")
    let service:String

    private(set) var account:String
    let accessGroup:String?

    init(service:String, account:String, accessGroup:String? = nil) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }

    /// Get the value of the item from the Keychain
    /// - Throws: KeychainError
    /// - Returns: the value of the item
    func readItem() throws -> String {
        var query = KeyChainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        var queryResult:AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        guard status != errSecItemNotFound else {throw KeychainError.noPassword}
        guard status == noErr else {throw KeychainError.unhandledError}

        guard let existingItem = queryResult as? [String:AnyObject],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }

        return password
    }

    /// save the item to the keychain
    /// - Parameter password: item to save
    /// - Throws: KeychainError
    func saveItem(_ password:String) throws {
        let encodePassword = password.data(using: .utf8)
        do {
            try _ = readItem()
            var attributesToUpdate = [String:AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodePassword as AnyObject?

            let query = KeyChainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard status == noErr else {throw KeychainError.unhandledError}
        } catch KeychainError.noPassword {
            var newItem = KeyChainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodePassword as AnyObject?
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == noErr else {throw KeychainError.unhandledError}
        }
    }

    /// Delete the item from the keychain
    /// - Throws: KeychainError
    func deleteItem() throws {
        let query = KeyChainItem.keychainQuery(withService: service, account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else {throw KeychainError.unhandledError}
    }

    /// generel query for keychain items
    /// - Parameters:
    ///   - service: <#service description#>
    ///   - account: <#account description#>
    ///   - accessGroup: <#accessGroup description#>
    /// - Returns: the query
    static func keychainQuery(withService service:String, account:String? = nil, accessGroup:String? = nil) -> [String:AnyObject] {
        var query = [String:AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        return query
    }

    static var currentUserIdentifier:String {
        get {(try? KeyChainItem(service: Key.service, account:Key.userIdentifier).readItem()) ?? ""}
        set {try? KeyChainItem(service: Key.service, account: Key.userIdentifier).saveItem(newValue)}
    }

    static func  deleteUserIdentifierFromKeyChain() {
        do {
            try KeyChainItem(service: Key.service, account: Key.userIdentifier).deleteItem()
        } catch {
            debugLog.error("🛑:\(#line) - \(error.localizedDescription)")
            Analytics.trackEvent(#function, withProperties: ["error":error.localizedDescription, "line": "\(#line)"])
        }
    }

    /// have the latest stored accessToken to the NaviBlind Backend...
    //    static var accessTokne:String? {
    //        get {try? KeyChainItem(service: Key.service, account: Key.accessTokne).readItem()}
    //        set{
    //            if newValue != nil {
    //                try? KeyChainItem(service: Key.service, account: Key.accessTokne).saveItem(newValue!)
    //            } else {
    //                try? KeyChainItem(service: Key.service, account: Key.accessTokne).deleteItem()
    //            }
    //        }
    //    }

    /// Holds a current authorization token
    static var authToken: String? {
        get { try? KeyChainItem(service: Key.service, account: .authToken).readItem()}
        set {
            if let newValue {
                try? KeyChainItem(service: Key.service, account: .authToken).saveItem(newValue)
            } else {
                try? KeyChainItem(service: Key.service, account: .authToken).deleteItem()
            }
        }
    }

    /// Holds a current refresh token
    static var refreshToken: String? {
        get { try? KeyChainItem(service: Key.service, account: .refreshToken).readItem()}
        set {
            if let newValue {
                try? KeyChainItem(service: Key.service, account: .refreshToken).saveItem(newValue)
            } else {
                try? KeyChainItem(service: Key.service, account: .refreshToken).deleteItem()
            }
        }
    }

    static var appleIdToken: String? {
        get {try? KeyChainItem(service: Key.service, account: Key.appleIdToken).readItem()}
        set {
            if let newValue = newValue {
                try? KeyChainItem(service: Key.service, account: Key.appleIdToken).saveItem(newValue)
            } else {
                try? KeyChainItem(service: Key.service, account: Key.appleIdToken).deleteItem()
            }
        }
    }

    /// hold the latest validated userID from Sign in with Apple
    static var appleuserId:String? {
        get {try? KeyChainItem(service: Key.service, account: Key.appleUserID).readItem()}
        set {
            if newValue != nil {
                try? KeyChainItem(service: Key.service, account: Key.appleUserID).saveItem(newValue!)
            } else {
                try? KeyChainItem(service: Key.service, account: Key.appleUserID).deleteItem()
            }
        }
    }

    /// delete the user credentials, this is for both accessToken and appleUserID
    static func  deleteCredentials() {
        do {
            try KeyChainItem(service: Key.service, account: Key.appleUserID).deleteItem()
            try KeyChainItem(service: Key.service, account: Key.accessTokne).deleteItem()
            try KeyChainItem(service: Key.service, account: Key.userIdentifier).deleteItem()
        } catch {
            debugLog.error("🛑:\(#line) - \(error.localizedDescription)")
            Analytics.trackEvent(#function, withProperties: ["error": error.localizedDescription, "line":"\(#line)"])
        }
    }

    private struct Key {
        static let service = "com.naviBlind"
        static let userIdentifier = "userIdentifier"
        static let appleUserID = "appleUserID"
        static let accessTokne = "accessToken"
        static let appleIdToken = "appleIdToken"
        static let authResponse = "authResponse"
    }

    enum KeychainError:Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
    }

}

fileprivate extension String {
    static let authToken = "auth.token"
    static let refreshToken = "refresh.token"
    static let appleIdentifier = "identifier.apple"
}
*/
