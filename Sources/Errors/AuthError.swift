//
//  AuthError.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/17/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Alamofire

// -----------------------------------------------------------------------------
//                          AuthError
// -----------------------------------------------------------------------------
/**
 Playola's custom server communication error
 ````
 case unauthorized
 case notFound
 case badRequest
 case .parsingError
 case unknown
 ````
 */
enum AuthError:Error, Equatable
{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: AuthError, rhs: AuthError) -> Bool {
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
    case badRequest(message:String?)
    
    /// indicates an error parsing the server response
    case parsingError(rawResponse:DataResponse<Any>)
    
    /// indicates unknown/undocumented error received from the server
    case unknown
    
    static func create (statusCode:Int?, message:String?) -> AuthError
    {
        if let statusCode = statusCode
        {
            switch statusCode
            {
            case 401:
                return .unauthorized
            case 404:
                return .notFound
            case 422:
                return .badRequest(message:message)
            default:
                return .unknown
            }
        }
        return .unknown
    }
    
    static func createFromAlamofireResponse(_ response:DataResponse<Any>) -> AuthError
    {
        var message:String?
        if let dict = response.result.value as? [String:Any?]
        {
            if let unwrappedMessage = dict["message"] as? String
            {
                message = unwrappedMessage
            }
        }
        
        return AuthError.create(statusCode: response.response?.statusCode, message: message)
    }
}
