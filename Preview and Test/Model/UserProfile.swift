//
//  UserProfile.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation

/// Just a struct, not currently used in the demo app
struct UserProfile: Codable {
    var userId: String
    var givenName: String
    var familyName: String
    var email: String
}

extension UserProfile {
    static let preview = UserProfile(userId: "1234234", givenName: "Per", familyName: "Friis", email: "per.friis@friisconsult.com")
}
