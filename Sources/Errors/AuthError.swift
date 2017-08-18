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
 Playola's custom server communication error.
 */
class AuthError:NSObject, Error
{
    /// the statusCode of the response
    var statusCode:Int?
    
    ///. message if one was received
    var message: String?
    
    /// The AuthErrorType
    var type:AuthErrorType
    
    /// The rawResponse if an uknown error occured
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
