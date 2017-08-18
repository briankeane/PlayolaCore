//
//  AuthErrorTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/18/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//
import Foundation
import XCTest
import Quick
import Nimble
import Alamofire

class AuthErrorTests: QuickSpec
{
    override func spec()
    {
        describe("AuthError")
        {
            it ("can be created with a message")
            {
                let newErr = AuthError(statusCode: 401, message: "damn")
                expect(newErr.statusCode).to(equal(401))
                expect(newErr.message).to(equal("damn"))
            }
            
            it ("creates AuthErrorType properly for statusCode 401")
            {
                let newErr = AuthError(statusCode: 401)
                expect(newErr.type).to(equal(AuthErrorType.unauthorized))
            }
            
            it ("creates AuthErrorType properly for statusCode 404")
            {
                let newErr = AuthError(statusCode: 404)
                expect(newErr.type).to(equal(AuthErrorType.notFound))
            }
            
            it ("creates AuthErrorType properly for statusCode 422")
            {
                let newErr = AuthError(statusCode: 422)
                expect(newErr.type).to(equal(AuthErrorType.badRequest))
            }
            
            it ("creates AuthErrorType properly for unknown statusCode")
            {
                let newErr = AuthError(statusCode: 999999999)
                expect(newErr.type).to(equal(AuthErrorType.unknown))
            }
            
            describe("create with Alamofire request")
            {
                it ("401 stores message and correct AuthErrorType")
                {
                    let resultDict:NSDictionary = ["statusCode": 401,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 401, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = AuthError(response: response)
                    expect(newErr.statusCode).to(equal(401))
                    expect(newErr.message).to(equal("damn motherfucker"))
                    expect(newErr.type).to(equal(AuthErrorType.unauthorized))
                }
                
                it ("404 with correct type")
                {
                    let resultDict:NSDictionary = ["statusCode": 404,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 404, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = AuthError(response: response)
                    expect(newErr.statusCode).to(equal(404))
                }
                
                it ("422 stores message")
                {
                    let resultDict:NSDictionary = ["statusCode": 422,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 422, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = AuthError(response: response)
                    expect(newErr.statusCode).to(equal(422))
                    expect(newErr.message).to(equal("damn motherfucker"))
                    expect(newErr.type).to(equal(AuthErrorType.badRequest))
                }
                
                it("unknown stores response")
                {
                    let resultDict:NSDictionary = ["statusCode": 9999,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 9999, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = AuthError(response: response)
                    expect(newErr.message).to(equal("damn motherfucker"))
                    expect(newErr.type).to(equal(AuthErrorType.unknown))
                    
                    let dict = newErr.rawResponse!.result.value as! [String:Any]
                    expect((dict["message"] as! String)).to(equal("damn motherfucker"))
                }
            }
        }
    }
}

