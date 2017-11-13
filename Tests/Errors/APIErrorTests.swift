//
//  APIErrorTests.swift
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

class APIErrorTests: QuickSpec
{
    override func spec()
    {
        describe("APIError")
        {
            it ("can be created with a message")
            {
                let newErr = APIError(statusCode: 401, message: "damn")
                expect(newErr.statusCode).to(equal(401))
                expect(newErr.message).to(equal("damn"))
            }
            
            it ("creates APIErrorType properly for unknown statusCode")
            {
                let newErr = APIError(statusCode: 999999999)
                expect(newErr.type()).to(equal(APIErrorType.unknown))
            }
            
            describe("create with Alamofire request")
            {
                it ("401 stores message and correct APIErrorType")
                {
                    let resultDict:NSDictionary = ["statusCode": 401,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 401, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = APIError(response: response)
                    expect(newErr.statusCode).to(equal(401))
                    expect(newErr.message).to(equal("damn motherfucker"))
                    expect(newErr.type()).to(equal(APIErrorType.unauthorized))
                }
                
                it ("404 with correct type")
                {
                    let resultDict:NSDictionary = ["statusCode": 404,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 404, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = APIError(response: response)
                    expect(newErr.statusCode).to(equal(404))
                }
                
                it ("422 stores message")
                {
                    let resultDict:NSDictionary = ["statusCode": 422,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 422, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = APIError(response: response)
                    expect(newErr.statusCode).to(equal(422))
                    expect(newErr.message).to(equal("damn motherfucker"))
                    expect(newErr.type()).to(equal(APIErrorType.badRequest))
                }
                
                it("unknown stores response")
                {
                    let resultDict:NSDictionary = ["statusCode": 9999,
                                                   "message": "damn motherfucker"]
                    
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "/hi/im/here")!, statusCode: 9999, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = APIError(response: response)
                    expect(newErr.message).to(equal("damn motherfucker"))
                    expect(newErr.type()).to(equal(APIErrorType.unknown))
                    
                    let dict = newErr.rawResponse!.result.value as! [String:Any]
                    expect((dict["message"] as! String)).to(equal("damn motherfucker"))
                }
                
                it ("works for passcodeIncorrect")
                {
                    let resultDict:NSDictionary = [ "playolaError": [
                                                                    "code": 1001,
                                                                    "decription": "passcode incorrect"]
                                                  ]
                    let result = Result<Any>.success(resultDict)
                    let httpResponse = HTTPURLResponse(url: URL(string: "a/url/address")!, statusCode: 422, httpVersion: nil, headerFields: nil)
                    let response = DataResponse(request: nil, response: httpResponse, data: Data(), result: result)
                    let newErr = APIError(response: response)
                    expect(newErr.type()).to(equal(APIErrorType.passcodeIncorrect))
                }
                
            }
        }
    }
}

