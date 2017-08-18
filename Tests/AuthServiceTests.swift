//
//  AuthServiceTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble
import Alamofire
import OHHTTPStubs

class AuthServiceTests: QuickSpec {
    
    private func readLocalJsonFile(_ filename:String!) -> [String:AnyObject]?
    {
        if let urlPathString = OHPathForFile(filename, type(of: self))
        {
            do
            {
                let urlPath = URL(fileURLWithPath: urlPathString)
                let jsonData = try Data(contentsOf: urlPath, options: .mappedIfSafe)
                
                if let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [String: AnyObject]
                {
                    return jsonDict
                }
            }
            catch let jsonError
            {
                print(jsonError)
            }
        }
        return nil
    }
    
    let getMePath                   =        "/api/v1/users/me"
    let getRotationItemsPath        =        "/api/v1/users/me/rotationItems"
    let getActiveSessionsCountPath  =        "/api/v1/listeningSessions/activeSessionsCount"
    
    override func spec()
    {
        describe("AuthService")
        {
            var sentRequest:URLRequest?
            var stubbedResponse:OHHTTPStubsResponse?
            
            afterEach
            {
                OHHTTPStubs.removeAllStubs()
            }
            
            beforeEach
            {
                print(PlayolaConstants.HOST_NAME)
                stub(condition: isHost(PlayolaConstants.HOST_NAME))
                {
                    (request) in
                    sentRequest = request
                    return stubbedResponse!
                }
            }
            
            describe("getMe()")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                                    fileAtPath: OHPathForFile("getUserSuccess.json", type(of: self))!,
                                    statusCode: 200,
                                    headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        let jsonDict = self.readLocalJsonFile("getUserSuccess.json")!
                    
                        AuthService.sharedInstance().getMe()
                        .then
                        {
                            (user) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getMePath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            
                            // check response
                            expect(user.id).to(equal(jsonDict["id"] as? String))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("there was an error")
                        }
                    }
                }
            
                it ("properly returns an error")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("404.json", type(of: self))!,
                        statusCode: 404,
                        headers: [:]
                    )
                
                    // test
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().getMe()
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError)).to(equal(AuthError.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getMe()")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("getUserRotationItemsSuccess.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        
                        AuthService.sharedInstance().getRotationItems()
                        .then
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getRotationItemsPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            
                            // check response
                            expect(rotationItemsCollection).toNot(beNil())
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("getRotationItems() should not have errored")
                        }
                    }
                }
                
                it ("properly returns an error")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("404.json", type(of: self))!,
                        statusCode: 404,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().getRotationItems()
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError)).to(equal(AuthError.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getActiveSessionsCount()")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getActiveSessionsCountSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                            
                        AuthService.sharedInstance().getActiveSessionsCount(broadcasterID:"aBroadcasterID")
                        .then
                        {
                            (count) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getActiveSessionsCountPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            expect(sentRequest!.url!.query!).to(equal("broadcasterID=aBroadcasterID"))
                            
                            // check response
                            expect(count).to(equal(42))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("getRotationItems() should not have errored")
                        }
                    }
                }
                
                it ("properly returns an error")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("404.json", type(of: self))!,
                        statusCode: 404,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().getRotationItems()
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError)).to(equal(AuthError.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            
        }
    }
}
