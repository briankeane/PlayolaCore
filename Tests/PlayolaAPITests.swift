//
//  PlayolaAPITests.swift
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

class PlayolaAPITests: QuickSpec {
    
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
    let findSongsByKeywordPath      =        "/api/v1/songs/findByKeywords"
    let getUsersByAttributesPath    =        "/api/v1/users/getByAttributes"
    let addSongToBinPath            =        "/api/v1/rotationItems"
    
    
    override func spec()
    {
        describe("PlayolaAPI")
        {
            var api:PlayolaAPI!
            var sentRequest:URLRequest?
            var stubbedResponse:OHHTTPStubsResponse?
            var sentBody:[String:Any]?
            
            afterEach
            {
                OHHTTPStubs.removeAllStubs()
            }
            
            beforeEach
            {
                sentBody = nil
                sentRequest = nil
                
                UserDefaults.standard.removeObject(forKey: "playolaAccessToken")
                api = PlayolaAPI(accessTokenString: "This Is A Token String", baseURL: "http://127.0.0.1:9000")
                print(PlayolaConstants.HOST_NAME)
                stub(condition: isHost("127.0.0.1"))
                {
                    (request) in
                    
                    if (sentRequest == nil)
                    {
                        sentRequest = request
                    }
                    
                    let castRequest = request as NSURLRequest
                    if let bodyData = castRequest.ohhttpStubs_HTTPBody()
                    {
                        // only capture initial sentBody
                        if (sentBody == nil)
                        {
                            sentBody = try! JSONSerialization.jsonObject(with: bodyData) as! [String:Any]
                        }
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
                    
                        api.getMe()
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
                        api.getMe()
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
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
                        
                        api.getRotationItems()
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
                        api.getRotationItems()
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
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
                            
                        api.getActiveSessionsCount(broadcasterID:"aBroadcasterID")
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
                        api.getActiveSessionsCount(broadcasterID: "aBroadcasterID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
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
                            
                        api.getPresets()
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
                            expect(presets[0].id!).to(equal(rawID))
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
                
                describe ("notification check")
                {
                    var observers:[NSObjectProtocol] = Array()
                    var checkNotificationBlock:((_ notification: Notification) -> ())?
                    var checkNotificationsFinished:Bool = false
                    
                    beforeEach
                    {
                        checkNotificationsFinished = false
                        observers = Array()
                        observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserPresetsReceived, object: nil, queue: .main)
                        {
                            (notification) -> Void in
                            checkNotificationBlock?(notification)
                        })
                    }
                    
                    afterEach
                    {
                        for observer in observers
                        {
                            NotificationCenter.default.removeObserver(observer)
                        }
                    }
                
                
                    it ("broadcasts ")
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
                            
                            checkNotificationBlock = {
                                (notification) -> Void in
                                let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                                let presets = notification.userInfo?["presets"] as! [User]
                                let rawPresets = (jsonDict["presets"] as! Array<NSDictionary>)
                                let rawID = rawPresets[0]["id"] as! String
                                expect(presets[0].id!).to(equal(rawID))
                                checkNotificationsFinished = true
                                done()
                            }
                            
                            api.getPresets()
                            .then
                            {
                                (presets) -> Void in
                                // wait for checkNotificationsBlock to execute
//                                expect(checkNotificationsFinished).toEventually(equal(true))
//                                done()
                            }
                            .catch
                            {
                                (error) -> Void in
                                print(error)
                                fail("getRotationItems() should not have errored")
                            }
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
                        api.getPresets(userID: "aUserID")
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
                        api.getPresets()
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
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
                        api.getTopUsers()
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
                        api.getTopUsers()
                        .then
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
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
                        api.updateUser(["displayName": "bob",
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
                            expect(updatedUser.id!).to(equal(rawID))
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
                        api.updateUser(["displayName": "bob",
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
                            
                            let authError = error as! APIError
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
                        api.follow(broadcasterID:"aBroadcasterID")
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
                            expect(presets[0].id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("follow() should not have errored")
                        }
                    }
                }
                
                describe ("notification check")
                {
                    var observers:[NSObjectProtocol] = Array()
                    var checkNotificationBlock:((_ notification: Notification) -> ())?
                    var checkNotificationsFinished:Bool = false
                    
                    beforeEach
                        {
                            checkNotificationsFinished = false
                            observers = Array()
                            observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserPresetsReceived, object: nil, queue: .main)
                            {
                                (notification) -> Void in
                                checkNotificationBlock?(notification)
                            })
                    }
                    
                    afterEach
                        {
                            for observer in observers
                            {
                                NotificationCenter.default.removeObserver(observer)
                            }
                    }
                    
                    
                    it ("broadcasts ")
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
                            checkNotificationBlock = {
                                (notification) -> Void in
                                let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                                let presets = notification.userInfo?["presets"] as! [User]
                                let rawPresets = (jsonDict["presets"] as! Array<NSDictionary>)
                                let rawID = rawPresets[0]["id"] as! String
                                expect(presets[0].id!).to(equal(rawID))
                                checkNotificationsFinished = true
                                done()
                            }
                            
                            api.follow(broadcasterID: "aBroadcasterID")
                            .then
                            {
                                (presets) -> Void in
                                // tests are in async block above
                            }
                            .catch
                            {
                                (error) -> Void in
                                print(error)
                                fail("getRotationItems() should not have errored")
                            }
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
                        api.follow(broadcasterID: "aUserID")
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
                        api.follow(broadcasterID:"aBroadcasterID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
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
                        api.unfollow(broadcasterID:"aBroadcasterID")
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
                            expect(presets[0].id!).to(equal(rawID))
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
                
                describe ("notification check")
                {
                    var observers:[NSObjectProtocol] = Array()
                    var checkNotificationBlock:((_ notification: Notification) -> ())?
                    var checkNotificationsFinished:Bool = false
                    
                    beforeEach
                    {
                        checkNotificationsFinished = false
                        observers = Array()
                        observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserPresetsReceived, object: nil, queue: .main)
                        {
                            (notification) -> Void in
                            checkNotificationBlock?(notification)
                        })
                    }
                    
                    afterEach
                    {
                        for observer in observers
                        {
                            NotificationCenter.default.removeObserver(observer)
                        }
                    }
                    
                    
                    it ("broadcasts ")
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
                            checkNotificationBlock = {
                                (notification) -> Void in
                                let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                                let presets = notification.userInfo?["presets"] as! [User]
                                let rawPresets = (jsonDict["presets"] as! Array<NSDictionary>)
                                let rawID = rawPresets[0]["id"] as! String
                                expect(presets[0].id!).to(equal(rawID))
                                checkNotificationsFinished = true
                                done()
                            }
                                
                            api.unfollow(broadcasterID: "aBroadcasterID")
                            .then
                            {
                                (presets) -> Void in
                                // tests are in async block above
                            }
                            .catch
                            {
                                (error) -> Void in
                                print(error)
                                fail("getRotationItems() should not have errored")
                            }
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
                        api.unfollow(broadcasterID: "aUserID")
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
                        api.unfollow(broadcasterID:"aBroadcasterID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
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
                        api.findUsersByKeywords(searchString:"Bob")
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
                            expect(presets[0].id!).to(equal(rawID))
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
                        api.findUsersByKeywords(searchString:"Bob")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("findSongsByKeywords")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("songSearchResultsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.findSongsByKeywords(searchString:"Bob")
                        .then
                        {
                            (songs) -> Void in
                            let jsonDict = self.readLocalJsonFile("songSearchResultsSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            expect(sentRequest!.url!.path).to(equal(self.findSongsByKeywordPath))
                            expect(sentRequest!.url!.query!).to(equal("searchString=Bob"))
                                    
                            // check response
                            let rawSearchResults = (jsonDict["searchResults"] as! Array<NSDictionary>)
                            let rawID = rawSearchResults[0]["id"] as! String
                                    
                            // check response
                            expect(songs[0].id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("findSongsByKeywords() should not have errored")
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
                        api.findSongsByKeywords(searchString:"Bob")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            done()
                        }
                    }
                }
            }

            
            //------------------------------------------------------------------------------
            
            describe("getUser")
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
                        api.getUser(userID: "userOneID")
                        .then
                        {
                            (user) -> Void in
                            let jsonDict = self.readLocalJsonFile("getUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/userOneID"))
                            
                            // check response
                            let userResult = (jsonDict as NSDictionary)
                            let rawID = userResult["id"] as! String
                                    
                            // check response
                            expect(user.id!).to(equal(rawID))
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
                        api.getUser(userID: "userOneID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getUsersByAttributes")
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
                            api.getUsersByAttributes(attributes: ["displayName": "bob",
                                                                     "email": "bob@bob.com"
                                ])
                                .then
                                {
                                    (searchResults) -> Void in
                                    let jsonDict = self.readLocalJsonFile("userSearchResultsSuccess.json")!
                                    
                                    // check request
                                    expect(sentRequest!.url!.path).to(equal(self.getUsersByAttributesPath))
                                    expect(sentRequest!.httpMethod).to(equal("GET"))
                                    expect(sentRequest!.url!.query!).to(equal("displayName=bob&email=bob%40bob.com"))
                                    
                                    
                                    // check response
                                    let rawUpdatedUser = (jsonDict["searchResults"] as! Array<NSDictionary>)[0]
                                    let rawID = rawUpdatedUser["id"] as! String
                                    // check response
                                    expect(searchResults[0].id!).to(equal(rawID))
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
                        headers: ["Content-Type":"application/json"]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (done) in
                        api.getUsersByAttributes(attributes: ["displayName": "bob",
                                                                     "email": "bob@bob.com"
                                ])
                        .then
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("addSongsToBin")
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
                        api.addSongsToBin(songIDs: ["songOneID", "songTwoID"], bin: "heavy")
                        .then
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.addSongToBinPath))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["songIDs"] as! Array<String>)).to(equal(["songOneID", "songTwoID"]))
                            expect((sentBody!["bin"] as! String)).to(equal("heavy"))
                                    
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
                        api.addSongsToBin(songIDs:["songOneID", "songTwoID"], bin: "heavy")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("deactivateRotationItem")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getUserRotationItemsSuccess.json",
                                                    type(of: self))!,
                                                    statusCode: 200,
                                                    headers: ["Content-Type":"application/json"]
                                                  )
                    waitUntil()
                    {
                        (done) in
                        api.deactivateRotationItem(rotationItemID: "rotationItemID")
                        .then
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/rotationItems/rotationItemID"))
                            expect(sentRequest!.httpMethod).to(equal("DELETE"))
                            
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
                    waitUntil()
                    {
                        (done) in
                        api.deactivateRotationItem(rotationItemID:"rotationItemID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                                    done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("reportListeningSession")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("genericSuccess200.json",
                                                  type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.reportListeningSession(broadcasterID: "aBroadcastersID")
                        .then
                        {
                            (responseDict) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["userBeingListenedToID"] as! String)).to(equal("aBroadcastersID"))
                                    
                            // check response
                            expect((responseDict["message"] as! String)).to(equal("success"))
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
                    waitUntil()
                    {
                        (done) in
                        api.reportListeningSession(broadcasterID: "aBroadcastersID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("reportAnonymousListeningSession")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("genericSuccess200.json",
                                                  type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.reportAnonymousListeningSession(broadcasterID: "aBroadcastersID", deviceID: "aUniqueDeviceID")
                        .then
                        {
                            (responseDict) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions/anonymous"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["userBeingListenedToID"] as! String)).to(equal("aBroadcastersID"))
                            expect((sentBody!["deviceID"] as! String)).to(equal("aUniqueDeviceID"))
                            
                            // check response
                            expect((responseDict["message"] as! String)).to(equal("success"))
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
                    waitUntil()
                    {
                        (done) in
                        api.reportAnonymousListeningSession(broadcasterID: "aBroadcastersID", deviceID: "aUniqueDeviceID")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("reportEndOfListeningSession")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("genericSuccess200.json",
                                                  type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.reportEndOfListeningSession()
                        .then
                        {
                            (responseDict) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions/endSession"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                                    
                            // check response
                            expect((responseDict["message"] as! String)).to(equal("success"))
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
                    waitUntil()
                        {
                            (done) in
                            api.reportEndOfListeningSession()
                                .then
                                {
                                    (user) -> Void in
                                    fail("there should have been an error")
                                }
                                .catch
                                {
                                    (error) -> Void in
                                    expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                                    done()
                            }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("reportEndOfAnonymousListeningSession")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("genericSuccess200.json",
                                                  type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                        {
                            (done) in
                            api.reportEndOfAnonymousListeningSession(deviceID: "aUniqueDeviceID")
                            .then
                            {
                                (responseDict) -> Void in
                                // check request
                                expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions/endAnonymous"))
                                expect(sentRequest!.httpMethod).to(equal("POST"))
                                expect((sentBody!["deviceID"] as! String)).to(equal("aUniqueDeviceID"))
                                    
                                // check response
                                expect((responseDict["message"] as! String)).to(equal("success"))
                                done()
                            }
                            .catch
                            {
                                (error) -> Void in
                                print(error)
                                fail("reportEndOfAnonymousListeningSession() should not have errored")
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
                    waitUntil()
                        {
                            (done) in
                            api.reportEndOfAnonymousListeningSession(deviceID: "aUniqueDeviceID")
                                .then
                                {
                                    (user) -> Void in
                                    fail("there should have been an error")
                                }
                                .catch
                                {
                                    (error) -> Void in
                                    expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                                    done()
                            }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("moveSpin")
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
                        api.moveSpin(spinID:"thisIsASpinID", newPlaylistPosition:42)
                        .then
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/spins/thisIsASpinID/move"))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            expect((sentBody!["newPlaylistPosition"] as! Int)).to(equal(42))
                            
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
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
                        api.moveSpin(spinID:"thisIsASpinID", newPlaylistPosition:42)
                        .then
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                                    
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("removeSpin")
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
                        api.removeSpin(spinID:"thisIsASpinID")
                        .then
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/spins/thisIsASpinID"))
                            expect(sentRequest!.httpMethod).to(equal("DELETE"))
                                    
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
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
                        api.removeSpin(spinID:"thisIsASpinID")
                        .then
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                                    
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("insertSpin")
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
                        api.insertSpin(audioBlockID:"thisIsAnAudioBlockID", playlistPosition:42)
                        .then
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/spins"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["audioBlockID"] as! String)).to(equal("thisIsAnAudioBlockID"))
                            expect((sentBody!["playlistPosition"] as! Int)).to(equal(42))
                            
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
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
                        api.removeSpin(spinID:"thisIsASpinID")
                        .then
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                            
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("loginViaFacebook")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("loginSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.loginViaFacebook(accessTokenString: "someFacebookTokenString")
                        .then
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("loginSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/auth/facebook/mobile"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["accessToken"] as! String)).to(equal("someFacebookTokenString"))
                                    
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                            
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("updateUser() should not have errored")
                            done()
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
                        api.loginViaFacebook(accessTokenString: "someFacebookTokenString")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("loginViaGoogle")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("loginSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.loginViaGoogle(accessTokenString: "someGoogleTokenString", refreshTokenString: "someGoogleRefreshTokenString")
                        .then
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("loginSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/auth/google/mobile"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["accessToken"] as! String)).to(equal("someGoogleTokenString"))
                            expect((sentBody!["refreshToken"] as! String)).to(equal("someGoogleRefreshTokenString"))
                                    
                                    // check response
                                    let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                                    let rawID = rawUpdatedUser["id"] as! String
                                    
                                    // check response
                                    expect(updatedUser.id!).to(equal(rawID))
                                    done()
                                }
                                .catch
                                {
                                    (error) -> Void in
                                    print(error)
                                    fail("updateUser() should not have errored")
                                    done()
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
                        api.loginViaGoogle(accessTokenString: "someGoogleTokenString", refreshTokenString: "someGoogleRefreshTokenString")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            done()
                        }
                    }
                }
            }

            //------------------------------------------------------------------------------
            
            describe("loginLocal")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("loginSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .then
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("loginSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/auth/local"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["email"] as! String)).to(equal("bob@bob.com"))
                            expect((sentBody!["password"] as! String)).to(equal("bobsPassword"))
                                    
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                                    
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("updateUser() should not have errored")
                            done()
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
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            done()
                        }
                    }
                }
                
                it ("properly returns .emailNotFound")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("emailNotFound.json", type(of: self))!,
                        statusCode: 404,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (done) in
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.emailNotFound))
                            done()
                        }
                    }
                }
                
                it ("properly returns .passwordIncorrect")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("passwordIncorrect.json", type(of: self))!,
                        statusCode: 401,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (done) in
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.passwordIncorrect))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("createUser")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("loginSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.createUser(emailConfirmationID: "anEmailConfirmationID", passcode: "1234")
                        .then
                        {
                            (createdUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("loginSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["emailConfirmationID"] as! String)).to(equal("anEmailConfirmationID"))
                            expect((sentBody!["passcode"] as! String)).to(equal("1234"))
                            
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                                    
                            // check response
                            expect(createdUser.id!).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("createUser() should not have errored")
                            done()
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
                        api.createUser(emailConfirmationID: "anEmailConfirmationID", passcode: "1234")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            done()
                        }
                    }
                }
                
                it ("properly returns .passcodeIncorrect")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("incorrectPasscode.json", type(of: self))!,
                        statusCode: 422,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (done) in
                        api.createUser(emailConfirmationID: "anEmailConfirmationID", passcode: "1234")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.passcodeIncorrect))
                            done()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("createEmailConfirmation")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("emailConfirmationSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (done) in
                        api.createEmailConfirmation(email: "bob@bob.com", displayName: "Bob", password: "bobsSecurePassword")
                        .then
                        {
                            (confirmationID) -> Void in
                            let jsonDict = self.readLocalJsonFile("emailConfirmationSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/emailConfirmations"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["email"] as! String)).to(equal("bob@bob.com"))
                            expect((sentBody!["displayName"] as! String)).to(equal("Bob"))
                            expect((sentBody!["password"] as! String)).to(equal("bobsSecurePassword"))
                                    
                            // check response
                            let rawID = jsonDict["id"] as! String
                                    
                            // check response
                            expect(confirmationID).to(equal(rawID))
                            done()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("updateUser() should not have errored")
                            done()
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
                        api.createEmailConfirmation(email: "bob@bob.com", displayName: "Bob", password: "bobsSecurePassword")
                        .then
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            done()
                        }
                    }
                }
            }
            
        }
    }
}
