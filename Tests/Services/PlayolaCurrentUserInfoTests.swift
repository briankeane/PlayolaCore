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
        
            it ("provides a deviceID")
            {
                let deviceID = PlayolaCurrentUserInfoService.sharedInstance().getDeviceID()
                expect(deviceID).toNot(beNil())
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
                        expect(newDisplayName).to(equal("FinalDisplayName"))  // ensures that it was not called with "OtherDisplayName"
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
