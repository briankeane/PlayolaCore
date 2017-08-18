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

 ````
 */
class AuthError:NSObject, Error
{
    var statusCode:Int?
    var message: String?
    var type:AuthErrorType
    var rawResponse:DataResponse<Any>?
    
    init(statusCode:Int?=nil, message:String?=nil, rawResponse:DataResponse<Any>?=nil)
    {
        self.statusCode = statusCode
        self.message = message
        self.type = AuthError.typeFromStatusCode(statusCode: statusCode)
        self.rawResponse = rawResponse
    }
    
    convenience init(response:DataResponse<Any>)
    {
        var message:String?
        if let dict = response.result.value as? [String:Any?]
        {
            if let unwrappedMessage = dict["message"] as? String
            {
                message = unwrappedMessage
            }
        }
        self.init(statusCode: response.response?.statusCode, message: message, rawResponse: response)
    }
    
    static func typeFromStatusCode(statusCode:Int?) -> AuthErrorType
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
                return .badRequest
            default:
                return .unknown
            }
        }
        return .unknown
    }
}


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
