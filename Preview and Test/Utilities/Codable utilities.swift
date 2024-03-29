//
//  Codable utilities.swift
//  Preview and Test
//
//  Created by Per Friis on 08/10/2023.
//

import Foundation

extension Decodable {
    
    /// Load a file and pars the json
    /// - Parameter url: the url for the file
    /// - Returns: Parsed version of the file
    static func load(_ url: URL) throws -> Self {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Self.self, from: data)
        } catch let error as NSError {
            print("\(error.description)")
            throw error
        }
    }

    
    /// Load a file from the bundle
    /// - Parameters:
    ///   - filename: the file name
    ///   - ext: the extension, this is "json" by default
    ///   - bundle: if not using main bundle, you can pars another bundle
    /// - Throws: pars on the json decoder errors, or if the file is not in the bundle ``DecodableError/fileNotInBundle(_:)`` is thrown
    static func load(filename: String, ext: String = "json", from bundle: Bundle = .main) throws -> Self {
        guard let url = bundle.url(forResource: filename, withExtension: ext) else {     
            print("\(filename).\(ext) was not found in the bundle")
            throw DecodableError.fileNotInBundle("\(filename).\(ext) was not found in the bundle")
        }
        return try load(url)
    }
}

extension Encodable {
    var json: Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try! encoder.encode(self)
    }
}

enum DecodableError: Error {
    case fileNotInBundle(String)
}
