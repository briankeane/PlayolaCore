//
//  APIError.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/17/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Alamofire

// -----------------------------------------------------------------------------
//                          APIError
// -----------------------------------------------------------------------------
/**
 Playola's custom server communication error.
 */
open class APIError:NSObject, Error
{
    /// the statusCode of the response
    public var statusCode:Int?
    
    ///. message if one was received
    public var message: String?
    
    /// The rawResponse if an uknown error occured
    public var rawResponse:DataResponse<Any>?
    
    public init(statusCode:Int?=nil, message:String?=nil, rawResponse:DataResponse<Any>?=nil)
    {
        self.statusCode = statusCode
        self.message = message
        self.rawResponse = rawResponse
    }
    
    public convenience init(response:DataResponse<Any>)
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
    
    open func type() -> APIErrorType
    {
        // playolaError object overrides type
        if let dict = self.rawResponse?.result.value as? [String:Any]
        {
            if let playolaError = dict["playolaError"] as? [String:Any]
            {
                if let code = playolaError["code"] as? Int
                {
                    switch code
                    {
                    case 1001:
                        return .passcodeIncorrect
                    case 1002:
                        return .invalidEmail
                    case 2001:
                        return .emailNotFound
                    case 2002:
                        return .passwordIncorrect
                    case 3001:
                        return .badRequest
                    case 3101:
                        return .zipcodeNotFound
                    case 3001:
                        return .notFound
                    default:
                        return .unknown
                    }
                }
            }
        }
        
        if let statusCode = self.rawResponse?.response?.statusCode
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
        
        if let error = self.rawResponse?.error as NSError?
        {
            if (error.code != 499)
            {
                return .networkConnectionError
            }
        }
        return .unknown
    }
}
