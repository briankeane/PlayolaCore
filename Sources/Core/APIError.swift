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
public class APIError:NSObject, Error
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
    
    func type() -> APIErrorType
    {
        if let statusCode = self.rawResponse?.response?.statusCode
        {
            switch statusCode
            {
            case 401:
                if let dict = self.rawResponse?.result.value as? [String:Any]
                {
                    if let loginRejectionCode = dict["loginRejectionCode"] as? Int
                    {
                        if (loginRejectionCode == 1)
                        {
                            return .emailNotFound
                        }
                        else if (loginRejectionCode == 2)
                        {
                            return .passwordIncorrect
                        }
                    }
                }
                return .unauthorized
            case 404:
                return .notFound
            case 422:
                if let dict = self.rawResponse?.result.value as? [String:Any]
                {
                    if let signUpRejectionCode = dict["signUpRejectionCode"] as? Int
                    {
                        if (signUpRejectionCode == 1)
                        {
                            return .passcodeIncorrect
                        }
                    }
                }
                return .badRequest
            default:
                return .unknown
            }
        }
        return .unknown
    }
}
