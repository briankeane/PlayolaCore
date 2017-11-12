//
//  APIErrorType.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/18/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public enum APIErrorType:Error, Equatable
{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: APIErrorType, rhs: APIErrorType) -> Bool {
        switch (lhs, rhs)
        {
        case (.emailNotFound, .emailNotFound):
            return true
        case (.passwordIncorrect, .passwordIncorrect):
            return true
        case (.passcodeIncorrect, .passcodeIncorrect):
            return true
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
    
    /// the email was not found -- localLogin only
    case emailNotFound
    
    /// the password was incorrect -- localLogin only
    case passwordIncorrect
    
    /// the passcode was incorrect -- createUser only
    case passcodeIncorrect
    
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
