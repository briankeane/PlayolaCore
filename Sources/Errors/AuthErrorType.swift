//
//  AuthErrorType.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/18/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

enum AuthErrorType:Error, Equatable
{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: AuthErrorType, rhs: AuthErrorType) -> Bool {
        switch (lhs, rhs)
        {
        case (.unauthorized, .unauthorized):
            return true
        case (.notFound, .notFound):
            return true
        case (.badRequest, .badRequest):
            return true
        case (.parsingError, .parsingError):
            return true
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
    
    /// indicates statusCode 404 received from server
    case notFound
    
    /// indicates statusCode 411 received from server
    case unauthorized
    
    /// indicates statusCode 422 received from server.
    case badRequest
    
    /// indicates an error parsing the server response
    case parsingError
    
    /// indicates unknown/undocumented error received from the server
    case unknown
}
