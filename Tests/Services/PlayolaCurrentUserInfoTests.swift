//
//  PlayolaCurrentUserInfoTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//


import Foundation
import XCTest
import Quick
import Nimble
import Locksmith

class PlayolaCurrentUserInfoTests: QuickSpec
{
    override func spec()
    {
        describe("PlayolaCurrentUserInfo")
        {
            beforeEach
            {
                // clear the singleton, so it doesn't listen and respond to the tests
                PlayolaCurrentUserInfoService.sharedInstance().deleteObservers()
            }
            describe("sets the authToken")
            {
                var userInfoService:PlayolaCurrentUserInfoService?
                
                func reinstantiateUserInfoService() -> PlayolaCurrentUserInfoService
                {
                    userInfoService?.deleteObservers()
                    userInfoService = nil
                    return PlayolaCurrentUserInfoService()
                }
                
                beforeEach
                {
                    do
                    {
                        try Locksmith.deleteDataForUserAccount(userAccount: "fm.playola")
                    }
                    catch
                    {
                        print(error)
                    }
                    
                    
                    userInfoService = reinstantiateUserInfoService()
                }
                
                afterEach
                {
                    userInfoService?.deleteObservers()
                    userInfoService = nil
                }
                
                it ("initializes token to nil if no token")
                {
                    expect(userInfoService?.getPlayolaAuthorizationToken()).to(beNil())
                }
                
                it ("initializes to something if it exists already")
                {
                    try! Locksmith.updateData(data: ["accessToken": "thisIsMyToken"], forUserAccount: "fm.playola")
                    userInfoService = reinstantiateUserInfoService()
                    expect(userInfoService?.getPlayolaAuthorizationToken()).to(equal("thisIsMyToken"))
                }
                
                it ("sets the token in locksmith")
                {
                    userInfoService?.setPlayolaAuthorizationToken(accessToken: "thisIsMyToken")
                    let dictionary = Locksmith.loadDataForUserAccount(userAccount: "fm.playola")
                    expect(dictionary!["accessToken"] as? String).to(equal("thisIsMyToken"))
                }
                
                it ("stores the accessToken in memory")
                {
                    userInfoService?.setPlayolaAuthorizationToken(accessToken: "thisIsMyToken")
                    expect(userInfoService?.getPlayolaAuthorizationToken()!).to(equal("thisIsMyToken"))
                }
            }
            
            describe("PlayolaCurrentUserInfo")
            {
                var userInfoService:PlayolaCurrentUserInfoService?
                var user:User!
                var updatedUser:User!
                var observers:[NSObjectProtocol] = Array()
                
                func reinstantiateUserInfoService() -> PlayolaCurrentUserInfoService
                {
                    userInfoService?.deleteObservers()
                    userInfoService = nil
                    return PlayolaCurrentUserInfoService()
                }
            
                beforeEach
                {
                    user = DataMocker.generateUsers(1)[0]!
                    updatedUser = user.copy()
                
                    updatedUser.displayName = "OtherDisplayName"
                    user.updatedAt = Date(dateString: "2015-3-15 13:13:35")
                    userInfoService = reinstantiateUserInfoService()
                }
            
                afterEach
                {
                    for observer in observers
                    {
                        NotificationCenter.default.removeObserver(observer)
                    }
                    observers = Array()
                    userInfoService?.deleteObservers()
                    userInfoService = nil
                }
            
                it ("updates the user if it was nil")
                {
                    updatedUser.updatedAt = Date(dateString: "2015-3-15 13:14:00")
                    var newDisplayName:String? = nil
                
                    // setup observer
                    let observer1 = NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserUpdated, object: nil, queue: .main)
                    {
                        (notification) -> Void in
                        newDisplayName = (notification.userInfo!["currentUser"] as! User).displayName!
                        expect(newDisplayName).to(equal("OtherDisplayName"))
                    }
                
                    observers.append(observer1)
                
                    // simulate receiving user
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": updatedUser])
                
                    // test async
                    expect(userInfoService?.user?.displayName).toEventually(equal("OtherDisplayName"))
                    expect(newDisplayName).toEventuallyNot(beNil())
                    expect(newDisplayName).toEventually(equal("OtherDisplayName"))
                }
            
                it ("updates the user if the new one is more up to date")
                {
                    userInfoService?.user = user
                    updatedUser.updatedAt = Date(dateString: "2015-3-15 13:14:00")
                    var newDisplayName:String? = nil
                
                    // setup observer
                    let observer1 = NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserUpdated, object: nil, queue: .main)
                    {
                        (notification) -> Void in
                        newDisplayName = (notification.userInfo!["currentUser"] as! User).displayName!
                        expect(newDisplayName).to(equal("OtherDisplayName"))
                    }
                
                    observers.append(observer1)
                
                    // simulate receiving user
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": updatedUser])
                
                    // test async
                    expect(userInfoService?.user?.displayName).toEventually(equal("OtherDisplayName"))
                    expect(newDisplayName).toEventuallyNot(beNil())
                    expect(newDisplayName).toEventually(equal("OtherDisplayName"))
                }
            
                it ("does not update the user if the new one is out of date")
                {
                    userInfoService?.user = user
                    updatedUser.updatedAt = Date(dateString: "2015-3-15 13:12:00")
                    var newDisplayName:String? = nil
                
                    // setup observer
                    let observer1 = NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserUpdated, object: nil, queue: .main)
                    {
                        (notification) -> Void in
                        newDisplayName = (notification.userInfo!["currentUser"] as! User).displayName!
//                        expect(newDisplayName).to(equal("FinalDisplayName"))  // ensures that it was not called with "OtherDisplayName"
                    }
                
                    observers.append(observer1)
                    // first post should be ignored
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user":updatedUser])
                
                    let finalUpdatedUser = updatedUser.copy()
                    finalUpdatedUser.displayName = "FinalDisplayName"
                    finalUpdatedUser.updatedAt = Date(dateString: "2015-3-15 13:15:00")
                
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": finalUpdatedUser])
                
                    expect(newDisplayName).toEventually(equal("FinalDisplayName"))
                }
            }
        }
    }
}
