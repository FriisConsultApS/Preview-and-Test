//
//  Network.swift
//  Preview and Test
//
//  Created by Per Friis on 10/10/2023.
//

import Foundation

extension URLResponse {
    var http: HTTPURLResponse {
        guard let response = self as? HTTPURLResponse else {
            fatalError("The URLResponse could not be casted as a HTTPURLResponse")
        }
        return response
    }
}

extension HTTPURLResponse: Error {
    /// is valid if the status code within the __Informational__ range of HTTP Status Codes
    var informational: Bool { 100..<200 ~= statusCode }

    /// is valid if the status code within the __Success__ range of HTTP Status Codes
    ///
    ///  For more information checkout [Http Status Code Glossary](https://www.webfx.com/web-development/glossary/http-status-codes)
    var success: Bool { 200..<300 ~= statusCode }

    /// is valid if the status code within the __Redirection__ range of HTTP Status Codes
    var redirection: Bool { 300..<400 ~= statusCode }

    /// is valid if the status code within the __Client Error__ range of HTTP Status Codes
    var clientError: Bool { 400..<500 ~= statusCode }

    /// is valid if the status code within the __Server Error__ range of HTTP Status Codes
    var serverError: Bool { 500..<600 ~= statusCode }
}
