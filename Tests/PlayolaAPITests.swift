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
import SwiftyJSON

class PlayolaAPITests: QuickSpec
{
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
    
    let getMePath                           =        "/api/v1/users/me"
    let getRotationItemsPath                =        "/api/v1/users/me/rotationItems"
    let getActiveSessionsCountPath          =        "/api/v1/listeningSessions/activeSessionsCount"
    let getMyPresetsPath                    =        "/api/v1/users/me/presets"
    let getTopStationsPath                  =        "/api/v1/users/topUsers"
    let updateUserPath                      =        "/api/v1/users/me"
    let findUsersByKeywordsPath             =        "/api/v1/users/findByKeywords"
    let findSongsByKeywordPath              =        "/api/v1/songs/findByKeywords"
    let getUsersByAttributesPath            =        "/api/v1/users/getByAttributes"
    let addSongToBinPath                    =        "/api/v1/rotationItems"
    let changePasswordPath                  =        "/api/v1/users/me/changePassword"
    let resetRotationItemsPath              =        "/api/v1/rotationItems/reset"
    let startStationPath                    =        "/api/v1/users/me/startStation"
    let createVoiceTrackPath                =        "/api/v1/voiceTracks"
    let removeRotationItemsAndResetPath     =        "/api/v1/rotationItems/removeAndReset"
    let shuffleStationPath                  =        "/api/v1/spins/shuffle"
    let registerSpotifyCredentialsPath      =        "/api/v1/users/me/spotifyCredentials"
    let getRotationItemsCountPath           =        "/api/v1/users/me/rotationItems/counts"
    
    
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
                api.operationQueue.cancelAllOperations()
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
                                    fileAtPath: OHPathForFile("updateUserSuccess.json", type(of: self))!,
                                    statusCode: 200,
                                    headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                    
                        api.getMe()
                        .done
                        {
                            (user) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getMePath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            
                            // check response
                            expect(user.id).to(equal(((jsonDict["user"] as! [String:Any])["id"] as! String)))
                            finished()
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
                        (finished) in
                        api.getMe()
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getRotationItems()")
            {
                it ("works with old api")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("getUserRotationItemsSuccess.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        
                        api.getRotationItems()
                        .done
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getRotationItemsPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            
                            // check response
                            expect(rotationItemsCollection).toNot(beNil())
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("getRotationItems() should not have errored")
                        }
                    }
                }
                
                it ("works with new api")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getUserRotationItemsSuccessNew.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        api.getRotationItems()
                        .done
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getRotationItemsPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                                    
                            // check response
                            expect(rotationItemsCollection).toNot(beNil())
                            expect(rotationItemsCollection.rotationItems.count).to(equal(3))
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error.localizedDescription)
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
                        (finished) in
                        api.getRotationItems()
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                            
                        api.getActiveSessionsCount(broadcasterID:"aBroadcasterID")
                        .done
                        {
                            (count) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getActiveSessionsCountPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            expect(sentRequest!.url!.query!).to(equal("broadcasterID=aBroadcasterID"))
                            
                            // check response
                            expect(count).to(equal(42))
                            finished()
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
                        (finished) in
                        api.getActiveSessionsCount(broadcasterID: "aBroadcasterID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getRotationItemsCount()")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getRotationItemsCountSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                            
                        api.getRotationItemsCount()
                        .done
                        {
                            (counts) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getRotationItemsCountPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            
                            // check response
                            let jsonDict = self.readLocalJsonFile("getRotationItemsCountSuccess.json")!
                            expect(counts["binCounts"]["light"].int!).to(equal((jsonDict["binCounts"] as! [String:Int])["light"]))
                            finished()
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
                        (finished) in
                        api.getRotationItemsCount()
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                            
                        api.getPresets()
                        .done
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
                            finished()
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
                    
                    beforeEach
                    {
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
                            (finished) in
                            
                            checkNotificationBlock = {
                                (notification) -> Void in
                                let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                                let presets = notification.userInfo?["favorites"] as! [User]
                                let rawPresets = (jsonDict["presets"] as! [NSDictionary])
                                let rawID = rawPresets[0]["id"] as! String
                                expect(presets[0].id!).to(equal(rawID))
                                finished()
                            }
                            
                            api.getPresets()
                            .done
                            {
                                (presets) -> Void in
                                // wait for checkNotificationsBlock to execute
//                                expect(checkNotificationsFinished).toEventually(equal(true))
//                                finished()
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
                        (finished) in
                        api.getPresets(userID: "aUserID")
                        .done
                        {
                            (presets) -> Void in
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aUserID/presets"))
                            finished()
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
                        (finished) in
                        api.getPresets()
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("getTopStations()")
            {
                it ("works for the current User")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("getTopStationsSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        api.getTopStations()
                        .done
                        {
                            (topUsers) -> Void in
                            let jsonDict = self.readLocalJsonFile("getTopStationsSuccess.json")!
                            
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getTopStationsPath))
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            
                            // check response
                            let rawTopUsers = (jsonDict["topUsers"] as! Array<NSDictionary>)
                            let rawID = rawTopUsers[0]["id"] as! String
                            // check response
                            expect(topUsers[0].id!).to(equal(rawID))
                            finished()
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
                        (finished) in
                        api.getTopStations()
                        .done
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.updateUser(["displayName": "bob",
                                                                 "email": "bob@bob.com"
                                                                ])
                        .done
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
                            finished()
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
                        (finished) in
                        api.updateUser(["displayName": "bob",
                                                                 "email": "bob@bob.com"
                                                                ])
                        .done
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
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("registerSpotifyCredentials")
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
                        (finished) in
                        api.registerSpotifyCredentials(refreshToken: "aRefreshToken", accessToken: "anAccessToken")
                        .done
                        {
                            (updatedUser) -> Void in
                            
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.registerSpotifyCredentialsPath))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            expect((sentBody!["refreshToken"] as! String)).to(equal("aRefreshToken"))
                            expect((sentBody!["accessToken"] as! String)).to(equal("anAccessToken"))
                                    
                            // check response
                            finished()
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
                        (finished) in
                        api.registerSpotifyCredentials(refreshToken: "aRefreshToken", accessToken: "anAccessToken")
                        .done
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
                            finished()
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
                        (finished) in
                        api.follow(broadcasterID:"aBroadcasterID")
                        .done
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
                            finished()
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
                        observers.append(NotificationCenter.default.addObserver(forName:
                            PlayolaEvents.currentUserPresetsReceived, object: nil, queue: .main)
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
                            (finished) in
                            checkNotificationBlock = {
                                (notification) -> Void in
                                let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                                let presets = notification.userInfo?["favorites"] as! [User]
                                let rawPresets = (jsonDict["presets"] as! Array<NSDictionary>)
                                let rawID = rawPresets[0]["id"] as! String
                                expect(presets[0].id!).to(equal(rawID))
                                checkNotificationsFinished = true
                                finished()
                            }
                            
                            api.follow(broadcasterID: "aBroadcasterID")
                            .done
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
                        (finished) in
                        api.follow(broadcasterID: "aUserID")
                        .done
                        {
                            (presets) -> Void in
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aUserID/follow"))
                            finished()
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
                        (finished) in
                        api.follow(broadcasterID:"aBroadcasterID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.unfollow(broadcasterID:"aBroadcasterID")
                        .done
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
                            finished()
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
                            (finished) in
                            checkNotificationBlock = {
                                (notification) -> Void in
                                let jsonDict = self.readLocalJsonFile("getPresetsSuccess.json")!
                                let presets = notification.userInfo?["favorites"] as! [User]
                                let rawPresets = (jsonDict["presets"] as! [NSDictionary])
                                let rawID = rawPresets[0]["id"] as! String
                                expect(presets[0].id!).to(equal(rawID))
                                checkNotificationsFinished = true
                                finished()
                            }
                                
                            api.unfollow(broadcasterID: "aBroadcasterID")
                            .done
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
                        (finished) in
                        api.unfollow(broadcasterID: "aUserID")
                        .done
                        {
                            (presets) -> Void in
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/aUserID/unfollow"))
                            finished()
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
                        (finished) in
                        api.unfollow(broadcasterID:"aBroadcasterID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.findUsersByKeywords(searchString:"Bob")
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("getRotationItems() should not have errored")
                            finished()
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
                        (finished) in
                        api.findUsersByKeywords(searchString:"Bob")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.findSongsByKeywords(searchString:"Bob")
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("findSongsByKeywords() should not have errored")
                            finished()
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
                        (finished) in
                        api.findSongsByKeywords(searchString:"Bob")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
                        }
                    }
                }
            }

            
            //------------------------------------------------------------------------------
            
            describe("getUser()")
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
                        (finished) in
                        api.getUser(userID: "userOneID")
                        .done
                        {
                            (user) -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.httpMethod).to(equal("GET"))
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/userOneID"))
                            
                            // check response
                            let userResult = (jsonDict as NSDictionary)
                            let rawID = (userResult["user"] as! [String:Any])["id"] as! String
                                    
                            // check response
                            expect(user.id!).to(equal(rawID))
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            fail("getUser() should not have errored")
                            finished()
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
                        (finished) in
                        api.getUser(userID: "userOneID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.getUsersByAttributes(attributes: ["displayName": "bob",
                                                              "email": "bob@bob.com"
                        ])
                        .done
                        {
                            (searchResults) -> Void in
                            let jsonDict = self.readLocalJsonFile("userSearchResultsSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.getUsersByAttributesPath))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["displayName"] as! String)).to(equal("bob"))
                            expect((sentBody!["email"] as! String)).to(equal("bob@bob.com"))
                                    
                                    
                            // check response
                            let rawUpdatedUser = (jsonDict["searchResults"] as! Array<NSDictionary>)[0]
                            let rawID = rawUpdatedUser["id"] as! String
                            // check response
                            expect(searchResults[0].id!).to(equal(rawID))
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("getUserByAttributes() should not have errored")
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
                        (finished) in
                        api.getUsersByAttributes(attributes: ["displayName": "bob",
                                                                     "email": "bob@bob.com"
                                ])
                        .done
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            finished()
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
                        (finished) in
                        api.addSongsToBin(songIDs: ["songOneID", "songTwoID"], bin: "heavy")
                        .done
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.addSongToBinPath))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["songIDs"] as! Array<String>)).to(equal(["songOneID", "songTwoID"]))
                            expect((sentBody!["bin"] as! String)).to(equal("heavy"))
                                    
                            // check response
                            expect(rotationItemsCollection).toNot(beNil())
                            finished()
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
                        (finished) in
                        api.addSongsToBin(songIDs:["songOneID", "songTwoID"], bin: "heavy")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.deactivateRotationItem(rotationItemID: "rotationItemID")
                        .done
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/rotationItems/rotationItemID"))
                            expect(sentRequest!.httpMethod).to(equal("DELETE"))
                            
                            // check response
                            expect(rotationItemsCollection).toNot(beNil())
                            finished()
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
                        (finished) in
                        api.deactivateRotationItem(rotationItemID:"rotationItemID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                                    finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("RotationItems -- removeAndReset")
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
                        (finished) in
                        api.removeRotationItemsAndReset(rotationItemIDs: ["rotationItemID"])
                        .done
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.removeRotationItemsAndResetPath))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            expect((sentBody!["rotationItemIDs"] as! [String])).to(equal(["rotationItemID"]))
                                
                            // check response
                            expect(rotationItemsCollection).toNot(beNil())
                            finished()
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
                        (finished) in
                        api.removeRotationItemsAndReset(rotationItemIDs: ["rotationItemID"])
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.reportListeningSession(broadcasterID: "aBroadcastersID")
                        .done
                        {
                            (responseDict) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["userBeingListenedToID"] as! String)).to(equal("aBroadcastersID"))
                                    
                            // check response
                            expect((responseDict["message"] as! String)).to(equal("success"))
                            finished()
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
                        (finished) in
                        api.reportListeningSession(broadcasterID: "aBroadcastersID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.reportAnonymousListeningSession(broadcasterID: "aBroadcastersID", deviceID: "aUniqueDeviceID")
                        .done
                        {
                            (responseDict) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions/anonymous"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["userBeingListenedToID"] as! String)).to(equal("aBroadcastersID"))
                            expect((sentBody!["deviceID"] as! String)).to(equal("aUniqueDeviceID"))
                            
                            // check response
                            expect((responseDict["message"] as! String)).to(equal("success"))
                            finished()
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
                        (finished) in
                        api.reportAnonymousListeningSession(broadcasterID: "aBroadcastersID", deviceID: "aUniqueDeviceID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.reportEndOfListeningSession()
                        .done
                        {
                            (responseDict) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions/endSession"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                                    
                            // check response
                            expect((responseDict["message"] as! String)).to(equal("success"))
                            finished()
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
                            (finished) in
                            api.reportEndOfListeningSession()
                                .done
                                {
                                    (user) -> Void in
                                    fail("there should have been an error")
                                }
                                .catch
                                {
                                    (error) -> Void in
                                    expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                                    finished()
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
                            (finished) in
                            api.reportEndOfAnonymousListeningSession(deviceID: "aUniqueDeviceID")
                            .done
                            {
                                (responseDict) -> Void in
                                // check request
                                expect(sentRequest!.url!.path).to(equal("/api/v1/listeningSessions/endAnonymous"))
                                expect(sentRequest!.httpMethod).to(equal("POST"))
                                expect((sentBody!["deviceID"] as! String)).to(equal("aUniqueDeviceID"))
                                    
                                // check response
                                expect((responseDict["message"] as! String)).to(equal("success"))
                                finished()
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
                        (finished) in
                        api.reportEndOfAnonymousListeningSession(deviceID: "aUniqueDeviceID")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.notFound))
                            finished()
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
                        (finished) in
                        api.moveSpin(spinID:"thisIsASpinID", newPlaylistPosition:42)
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("moveSpin() should not have errored")
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
                        (finished) in
                        api.moveSpin(spinID:"thisIsASpinID", newPlaylistPosition:42)
                        .done
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
                            finished()
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
                        (finished) in
                        api.removeSpin(spinID:"thisIsASpinID")
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("removeSpin() should not have errored")
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
                        (finished) in
                        api.removeSpin(spinID:"thisIsASpinID")
                        .done
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
                            finished()
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
                        (finished) in
                        api.insertSpin(audioBlockID:"thisIsAnAudioBlockID", playlistPosition:42)
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("insertSpin() should not have errored")
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
                        (finished) in
                        api.insertSpin(audioBlockID:"thisIsAnAudioBlockID", playlistPosition:42)
                        .done
                        {
                            (updatedUser) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                            
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("shuffleStation")
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
                        (finished) in
                        api.shuffleStation()
                        .done
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.shuffleStationPath))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("insertSpin() should not have errored")
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
                        (finished) in
                        api.insertSpin(audioBlockID:"thisIsAnAudioBlockID", playlistPosition:42)
                        .done
                        {
                            (updatedUser) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                                    
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            finished()
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
                        (finished) in
                        api.loginViaFacebook(accessTokenString: "someFacebookTokenString")
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("loginViaFacebook() should not have errored")
                            finished()
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
                        (finished) in
                        api.loginViaFacebook(accessTokenString: "someFacebookTokenString")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
           describe("loginViaSpotify")
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
                        (finished) in
                        api.loginViaSpotify(accessTokenString: "someSpotifyTokenString", refreshTokenString: "someSpotifyRefreshTokenString")
                        .done
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("loginSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/auth/spotify/mobile"))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["accessToken"] as! String)).to(equal("someSpotifyTokenString"))
                            expect((sentBody!["refreshToken"] as! String)).to(equal("someSpotifyRefreshTokenString"))
                                    
                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                                    
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("loginViaSpotify() should not have errored")
                            finished()
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
                        (finished) in
                        api.loginViaSpotify(accessTokenString: "someSpotifyTokenString", refreshTokenString: "someSpotifyRefreshTokenString")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
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
                            (finished) in
                            api.loginViaGoogle(accessTokenString: "someGoogleTokenString", refreshTokenString: "someGoogleRefreshTokenString")
                                .done
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
                                    finished()
                                }
                                .catch
                                {
                                    (error) -> Void in
                                    print(error)
                                    fail("loginViaGoogle() should not have errored")
                                    finished()
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
                            (finished) in
                            api.loginViaGoogle(accessTokenString: "someGoogleTokenString", refreshTokenString: "someGoogleRefreshTokenString")
                                .done
                                {
                                    (user) -> Void in
                                    fail("there should have been an error")
                                }
                                .catch
                                {
                                    (error) -> Void in
                                    expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                                    finished()
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
                        (finished) in
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("loginLocak() should not have errored")
                            finished()
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
                        (finished) in
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
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
                        (finished) in
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.emailNotFound))
                            finished()
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
                        (finished) in
                        api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.passwordIncorrect))
                            finished()
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
                        (finished) in
                        api.createUser(emailConfirmationID: "anEmailConfirmationID", passcode: "1234")
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("createUser() should not have errored")
                            finished()
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
                        (finished) in
                        api.createUser(emailConfirmationID: "anEmailConfirmationID", passcode: "1234")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
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
                        (finished) in
                        api.createUser(emailConfirmationID: "anEmailConfirmationID", passcode: "1234")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.passcodeIncorrect))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("requestSongFromSpotifyID")
            {
                describe ("old api")
                {
                    it ("works when song exists")
                    {
                        // setup
                        stubbedResponse = OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("requestSongBySpotifyIDSongExistsOldAPI.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                        )
                        waitUntil()
                            {
                                (finished) in
                                api.requestSongBySpotifyID(spotifyID: "bobsSpotifyID")
                                    .done
                                    {
                                        (songStatus, song) -> Void in
                                        let jsonDict = self.readLocalJsonFile("requestSongBySpotifyIDSongExistsOldAPI.json")!
                                        
                                        // check request
                                        expect(sentRequest!.url!.path).to(equal("/api/v1/songs/requestViaSpotifyID/bobsSpotifyID"))
                                        expect(sentRequest!.httpMethod).to(equal("POST"))
                                        
                                        // check response
                                        let rawSong = jsonDict["song"] as! NSDictionary
                                        let rawID = rawSong["id"] as! String
                                        
                                        // check response
                                        expect(songStatus).to(equal(SongStatus.songExists))
                                        expect(song?.id).to(equal(rawID))
                                        finished()
                                    }
                                    .catch
                                    {
                                        (error) -> Void in
                                        print(error)
                                        fail("requestSongBySong() should not have errored")
                                        finished()
                                }
                        }
                    }
                    
                    it ("works when song is processing")
                    {
                        // setup
                        stubbedResponse = OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("requestSongBySpotifyIDSongProcessingOldAPI.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                        )
                        waitUntil()
                            {
                                (finished) in
                                api.requestSongBySpotifyID(spotifyID: "bobsSpotifyID")
                                    .done
                                    {
                                        (songStatus, song) -> Void in
                                        
                                        // check request
                                        expect(sentRequest!.url!.path).to(equal("/api/v1/songs/requestViaSpotifyID/bobsSpotifyID"))
                                        expect(sentRequest!.httpMethod).to(equal("POST"))
                                        
                                        // check response
                                        expect(songStatus).to(equal(SongStatus.processing))
                                        expect(song).to(beNil())
                                        finished()
                                    }
                                    .catch
                                    {
                                        (error) -> Void in
                                        print(error)
                                        fail("requestSongBySong() should not have errored")
                                        finished()
                                }
                        }
                    }
                }
                
                describe ("new api")
                {
                    it ("works when song exists")
                    {
                        // setup
                        stubbedResponse = OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("requestSongBySpotifyIDSongExists.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                        )
                        waitUntil()
                        {
                            (finished) in
                            api.requestSongBySpotifyID(spotifyID: "bobsSpotifyID")
                            .done
                            {
                                (songStatus, song) -> Void in
                                let jsonDict = self.readLocalJsonFile("requestSongBySpotifyIDSongExists.json")!
                                        
                                // check request
                                expect(sentRequest!.url!.path).to(equal("/api/v1/songs/requestViaSpotifyID/bobsSpotifyID"))
                                expect(sentRequest!.httpMethod).to(equal("POST"))
                                
                                // check response
                                let rawSong = jsonDict["song"] as! NSDictionary
                                let rawID = rawSong["id"] as! String
                                
                                // check response
                                expect(songStatus).to(equal(SongStatus.songExists))
                                expect(song?.id).to(equal(rawID))
                                finished()
                            }
                            .catch
                            {
                                (error) -> Void in
                                print(error)
                                fail("requestSongBySong() should not have errored")
                                finished()
                            }
                        }
                    }
                    
                    it ("works when song is processing")
                    {
                        // setup
                        stubbedResponse = OHHTTPStubsResponse(
                            fileAtPath: OHPathForFile("requestSongBySpotifyIDSongProcessing.json", type(of: self))!,
                            statusCode: 200,
                            headers: ["Content-Type":"application/json"]
                        )
                        waitUntil()
                        {
                            (finished) in
                            api.requestSongBySpotifyID(spotifyID: "bobsSpotifyID")
                            .done
                            {
                                (songStatus, song) -> Void in
                                
                                // check request
                                expect(sentRequest!.url!.path).to(equal("/api/v1/songs/requestViaSpotifyID/bobsSpotifyID"))
                                expect(sentRequest!.httpMethod).to(equal("POST"))
                                        
                                // check response
                                expect(songStatus).to(equal(SongStatus.processing))
                                expect(song).to(beNil())
                                finished()
                            }
                            .catch
                            {
                                (error) -> Void in
                                print(error)
                                fail("requestSongBySong() should not have errored")
                                finished()
                            }
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
                        (finished) in
                        api.requestSongBySpotifyID(spotifyID: "bobsSpotifyID")
                        .done
                        {
                            (songStatus, song) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("createVoiceTrack")
            {
                let myVoiceTrackURL = "https://www.briankeane.net/myVoiceTrack.m4a"
                
                it ("works when a voiceTrack exists")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("createVoiceTrackExists.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        api.createVoiceTrack(voiceTrackURL: myVoiceTrackURL)
                        .done
                        {
                            (voiceTrackStatus, voiceTrack) -> Void in
                            let jsonDict = self.readLocalJsonFile("createVoiceTrackExists.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.createVoiceTrackPath))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                            expect((sentBody!["url"] as! String)).to(equal(myVoiceTrackURL))
                                    
                            // check response
                            let rawVoiceTrack = jsonDict["voiceTrack"] as! NSDictionary
                            let rawID = rawVoiceTrack["id"] as! String
                            
                                    
                            // check response
                            expect(voiceTrackStatus).to(equal(VoiceTrackStatus.completed))
                            expect(voiceTrack?.id).to(equal(rawID))
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("createVoiceTrack() should not have errored")
                            finished()
                        }
                    }
                }
                
                it ("works when a voiceTrack is processing")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("createVoiceTrackProcessing.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        
                        api.createVoiceTrack(voiceTrackURL: myVoiceTrackURL)
                        .done
                        {
                            (voiceTrackStatus, voiceTrack) -> Void in
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.createVoiceTrackPath))
                            expect(sentRequest!.httpMethod).to(equal("POST"))
                                    
                            // check response
                            expect(voiceTrackStatus).to(equal(VoiceTrackStatus.processing))
                            expect(voiceTrack).to(beNil())
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("requestSongBySong() should not have errored")
                            finished()
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
                        (finished) in
                        api.createVoiceTrack(voiceTrackURL: myVoiceTrackURL)
                        .done
                        {
                            (voiceTrackStatus, voiceTrack) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
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
                        (finished) in
                        api.createEmailConfirmation(email: "bob@bob.com", displayName: "Bob", password: "bobsSecurePassword")
                        .done
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
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("createUserConfirmation() should not have errored")
                            finished()
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
                        (finished) in
                        api.createEmailConfirmation(email: "bob@bob.com", displayName: "Bob", password: "bobsSecurePassword")
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
           describe("requestPasswordReset")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("passwordResetSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        api.requestPasswordReset()
                        .done
                        {
                            () -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal("/api/v1/users/me/changePassword"))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                                
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("createUserConfirmation() should not have errored")
                            finished()
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
                        (finished) in
                        api.requestPasswordReset()
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.badRequest))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("changePassword")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("genericSuccess200.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        api.changePassword(oldPassword: "oldPasswordExample",
                                           newPassword: "newPasswordExample")
                        .done
                        {
                            () -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                            
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.changePasswordPath))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            expect((sentBody!["oldPassword"] as! String)).to(equal("oldPasswordExample"))
                            expect((sentBody!["newPassword"] as! String)).to(equal("newPasswordExample"))
                            
                            // check response
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("changePassword() should not have errored")
                        }
                    }
                }
                
                it ("properly returns an error")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("passwordIncorrect.json", type(of: self))!,
                        statusCode: 422,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (finished) in
                        api.changePassword(oldPassword: "oldPasswordExample",
                                           newPassword: "newPasswordExample")
                        .done
                        {
                            (topUsers) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.passwordIncorrect))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("resetRotationItems")
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
                        (finished) in
                        api.resetRotationItems(items:[(songID:"song1ID", bin: "heavy"),
                                                      (songID:"song2ID", bin: "medium"),
                                                      (songID:"song3ID", bin: "light")
                                               ])
                        .done
                        {
                            (rotationItemsCollection) -> Void in
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.resetRotationItemsPath))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))
                            let sentItemDicts = sentBody!["items"] as! [[String:String]]
                            expect(sentItemDicts[0]["songID"]).to(equal("song1ID"))
                            expect(sentItemDicts[1]["songID"]).to(equal("song2ID"))
                            expect(sentItemDicts[2]["songID"]).to(equal("song3ID"))
                            expect(sentItemDicts[0]["bin"]).to(equal("heavy"))
                            expect(sentItemDicts[1]["bin"]).to(equal("medium"))
                            expect(sentItemDicts[2]["bin"]).to(equal("light"))
                            
                            // check response
                            expect(rotationItemsCollection).toNot(beNil())
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("getRotationItems() should not have errored")
                        }
                    }
                }
                
                it ("properly returns a rotationItemBinMinimumsNotMet error")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("binMinimums.json", type(of: self))!,
                        statusCode: 422,
                        headers: [:]
                    )
                    
                    // test
                    waitUntil()
                    {
                        (finished) in
                        api.resetRotationItems(items:[(songID:"song1ID", bin: "heavy"),
                                                      (songID:"song2ID", bin: "medium"),
                                                      (songID:"song3ID", bin: "light")])
                        .done
                        {
                            (user) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            expect((error as! APIError).type()).to(equal(APIErrorType.rotationItemMinimumsNotMet))
                            finished()
                        }
                    }
                }
            }
            
            //------------------------------------------------------------------------------
            
            describe("startStation")
            {
                it ("works")
                {
                    // setup
                    stubbedResponse = OHHTTPStubsResponse(
                        fileAtPath: OHPathForFile("startStationSuccess.json", type(of: self))!,
                        statusCode: 200,
                        headers: ["Content-Type":"application/json"]
                    )
                    waitUntil()
                    {
                        (finished) in
                        api.startStation()
                        .done
                        {
                            (updatedUser) -> Void in
                            let jsonDict = self.readLocalJsonFile("updateUserSuccess.json")!
                                    
                            // check request
                            expect(sentRequest!.url!.path).to(equal(self.startStationPath))
                            expect(sentRequest!.httpMethod).to(equal("PUT"))

                            // check response
                            let rawUpdatedUser = jsonDict["user"] as! NSDictionary
                            let rawID = rawUpdatedUser["id"] as! String
                            // check response
                            expect(updatedUser.id!).to(equal(rawID))
                            finished()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print(error)
                            fail("startStation() should not have errored")
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
                        (finished) in
                        api.startStation()
                        .done
                        {
                            (updatedUser) -> Void in
                            fail("there should have been an error")
                        }
                        .catch
                        {
                            (error) -> Void in
                            let jsonDict = self.readLocalJsonFile("422.json")!
                            
                            let authError = error as! APIError
                            expect(authError.message!).to(equal((jsonDict["message"] as! String)))
                            finished()
                        }
                    }
                }
            }
        }
    }
}
