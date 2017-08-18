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
import OHHTTPStubs.NSURLRequest_HTTPBodyTesting

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
    let getMyPresetsPath            =        "/api/v1/users/me/presets"
    let getTopUsersPath             =        "/api/v1/users/topUsers"
    let updateUserPath              =        "/api/v1/users/me"
    let findUsersByKeywordsPath     =        "/api/v1/users/findByKeywords"
    let getMultipleUsersPath        =        "/api/v1/users/getMultipleUsers"
    
    override func spec()
    {
        describe("AuthService")
        {
            var sentRequest:URLRequest?
            var stubbedResponse:OHHTTPStubsResponse?
            var sentBody:[String:Any]?
            
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
                    
                    let castRequest = request as NSURLRequest
                    if let bodyData = castRequest.ohhttpStubs_HTTPBody()
                    {
                        sentBody = try! JSONSerialization.jsonObject(with: bodyData) as! [String:Any]
                        
                    }
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
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getRotationItems()")
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
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
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
                        AuthService.sharedInstance().getActiveSessionsCount(broadcasterID: "aBroadcasterID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getPresets()")
            {
                it ("works for the current User")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getPresetsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                            
                        AuthService.sharedInstance().getPresets()
                        .then
                        {
                            (presets) -> Void in
                            let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                            
                            
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getMyPresetsPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                
                            
                            // check response
                            let rawPresets = (jsonDict["presets"] as! Array<NSDictionary>)
                            let rawID = rawPresets[0]["id"] as! String
                            // check response
                            print(rawID)
                            expect(presets[0]!.id!).to(equal(rawID))
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
                
                it ("passes the proper id in params")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getPresetsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().getPresets(userID: "aUserID")
                        .then
                        {
                            (presets) -> Void in
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aUserID/presets"))
                            done()
                        }
                        .catch
                        {
                            (error) in
                            print(error)
                            fail("passes the proper id in params should not have errored")
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
                        AuthService.sharedInstance().getPresets()
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getTopUsers()")
            {
                it ("works for the current User")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getTopUsersSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().getTopUsers()
                        .then
                        {
                            (topUsers) -> Void in
                            let jsonDict = self.readLocalJsonFile("getTopUsersSuccess.json")!
                            
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getTopUsersPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            
                            // check response
                            let rawTopUsers = (jsonDict["topUsers"] as! Array<NSDictionary>)
                            let rawID = rawTopUsers[0]["id"] as! String
                            // check response
                            expect(topUsers[0]!.id!).to(equal(rawID))
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
                        AuthService.sharedInstance().getTopUsers()
                        .then
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("updateUser")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("updateUserSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().updateUser(["displayName": "bob",
                                                                 "email": "bob@bob.com"
                                                                ])
                        .then
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.updateUserPath))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            expect((sentBody!["displayName"] as! String)).to(equal("bob"))
                            expect((sentBody!["email"] as! String)).to(equal("bob@bob.com"))
                            
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                            // check response
                            expect(updatedUser!.id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("updateUser() should not have errored")
                        }
                    }
                }
                
                it ("properly returns an error")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("422.json", type(of: self))!,
                        statusCode: 422,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().updateUser(["displayName": "bob",
                                                                 "email": "bob@bob.com"
                                                                ])
                        .then
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                            
                            let authError = error as! AuthError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("follow()")
            {
                it ("works for the current User")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getPresetsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().follow(broadcasterID:"aBroadcasterID")
                        .then
                        {
                            (presets) -> Void in
                            let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                            
                            // check request
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aBroadcasterID/follow"))
                            
                            // check response
                            let rawPresets = (jsonDict["presets"] as! Array<NSDictionary>)
                            let rawID = rawPresets[0]["id"] as! String
                            // check response
                            expect(presets[0]!.id!).to(equal(rawID))
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
                
                it ("passes the proper id in params")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getPresetsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().follow(broadcasterID: "aUserID")
                        .then
                        {
                            (presets) -> Void in
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aUserID/follow"))
                            done()
                        }
                        .catch
                        {
                            (error) in
                            print(error)
                            fail("passes the proper id in params should not have errored")
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
                        AuthService.sharedInstance().follow(broadcasterID:"aBroadcasterID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("unfollow()")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getPresetsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().unfollow(broadcasterID:"aBroadcasterID")
                        .then
                        {
                            (presets) -> Void in
                            let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aBroadcasterID/unfollow"))
                                    
                            // check response
                            let rawPresets = (jsonDict["presets"] as! Array<NSDictionary>)
                            let rawID = rawPresets[0]["id"] as! String
                            
                            // check response
                            expect(presets[0]!.id!).to(equal(rawID))
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
                
                it ("passes the proper id in params")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getPresetsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().unfollow(broadcasterID: "aUserID")
                        .then
                        {
                            (presets) -> Void in
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aUserID/unfollow"))
                            done()
                        }
                        .catch
                        {
                            (error) in
                            print(error)
                            fail("passes the proper id in params should not have errored")
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
                        AuthService.sharedInstance().unfollow(broadcasterID:"aBroadcasterID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("findUsersByKeywords")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("userSearchResultsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().findUsersByKeywords(searchString:"Bob")
                        .then
                        {
                            (presets) -> Void in
                            let jsonDict = self.readLocalJsonFile("userSearchResultsSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            expect(sentRequest!.url!.path).to(equal(self.findUsersByKeywordsPath))
                            expect(sentRequest!.url!.query!).to(equal("searchString=Bob"))
                                    
                            // check response
                            let rawSearchResults = (jsonDict["searchResults"] as! Array<NSDictionary>)
                            let rawID = rawSearchResults[0]["id"] as! String
                                
                            // check response
                            expect(presets[0]!.id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("getRotationItems() should not have errored")
                            done()
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
                        AuthService.sharedInstance().findUsersByKeywords(searchString:"Bob")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getMultipleUsers")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("userSearchResultsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        AuthService.sharedInstance().getMultipleUsers(userIDs: ["userOneID", "userTwoID"])
                        .then
                        {
                            (presets) -> Void in
                            let jsonDict = self.readLocalJsonFile("userSearchResultsSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            expect(sentRequest!.url!.path).to(equal(self.getMultipleUsersPath))
                            expect(sentRequest!.url!.query!).to(equal("userIDs%5B%5D=userOneID&userIDs%5B%5D=userTwoID"))
                            
                            // check response
                            let rawSearchResults = (jsonDict["searchResults"] as! Array<NSDictionary>)
                            let rawID = rawSearchResults[0]["id"] as! String
                                    
                            // check response
                            expect(presets[0]!.id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            fail("getRotationItems() should not have errored")
                            done()
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
                        AuthService.sharedInstance().getMultipleUsers(userIDs: ["userOneID", "userTwoID"])
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! AuthError).type).to(equal(AuthErrorType.notFound))
                            done()
                        }
                    }
                }
            }
        }
    }
}
