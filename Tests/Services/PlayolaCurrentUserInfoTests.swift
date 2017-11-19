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
                
                var apiMock:PlayolaAPIMock!
                var dataMocker:DataMocker!
                var presets:[User]!
                var replacementPresets:[User]!
                
                func reinstantiateUserInfoService() -> PlayolaCurrentUserInfoService
                {
                    userInfoService?.deleteObservers()
                    userInfoService = nil
                    return PlayolaCurrentUserInfoService()
                }
            
                beforeEach
                {
                    dataMocker = DataMocker()
                    var users:[User] = dataMocker.generateUsers(6)
                    user = users.removeFirst()
                    presets = Array(users.dropFirst(2))
                    replacementPresets = users
                    
                    updatedUser = user.copy()
                    updatedUser.displayName = "OtherDisplayName"
                    user.updatedAt = Date(dateString: "2015-3-15 13:13:35")
                    
                    presets = users
                    
                    apiMock = PlayolaAPIMock()
                    userInfoService = reinstantiateUserInfoService()
                    
                    userInfoService?.setValuesForKeys([
                        "api": apiMock
                        ])
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
                
                describe ("user updates")
                {
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
                        
                        apiMock.getPresetsPresets = presets
                        
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
                
                describe ("presets")
                {
                    it ("loads presets on .signedIn")
                    {
                        apiMock.getPresetsShouldSucceed = true
                        apiMock.getPresetsPresets = presets
                        NotificationCenter.default.post(name: PlayolaEvents.signedIn, object: nil, userInfo: nil)
                        let presetsIDs = presets.map({$0.id})
                        expect(userInfoService!.presets?.map({$0.id})).toEventually(equal(presetsIDs))
                    }
                    
                    it ("clears the presets on .signedOut")
                    {
                        userInfoService!.presets = presets
                        NotificationCenter.default.post(name: PlayolaEvents.signedOut, object: nil, userInfo: nil)
                        expect(userInfoService!.presets).toEventually(beNil())
                    }
                    
                   it ("updates the presets on .currentUserPresetsReceived")
                   {
                        userInfoService?.presets = presets

                        NotificationCenter.default.post(name: PlayolaEvents.currentUserPresetsReceived, object: nil, userInfo: ["presets": replacementPresets])
                        let replacementIDs = replacementPresets.map({$0.id})
                        expect(userInfoService!.presets?.map({$0.id})).toEventually(equal(replacementIDs))
                    }
                    
                    it ("broadcasts .presetsUpdated when the presets get updated")
                    {
                        userInfoService?.presets = presets
                        let updatedNotification = Notification(name: PlayolaEvents.presetsUpdated, object: nil, userInfo: ["presets": replacementPresets])
                        expect {
                            NotificationCenter.default.post(name: PlayolaEvents.currentUserPresetsReceived, object: nil, userInfo: ["presets": replacementPresets])
                        }.toEventually(postNotifications(contain(updatedNotification)))
                    }
                }
                
                describe ("isInPresets")
                {
                    it ("returns true if the userID is in the presets")
                    {
                        userInfoService!.presets = presets
                        let isPresentID = presets[2].id!
                        expect(userInfoService!.isInPresets(userID: isPresentID)).to(equal(true))
                    }
                    
                    it ("returns false if it is not")
                    {
                        userInfoService!.presets = presets
                        expect(userInfoService!.isInPresets(userID: "notInThePresetsID")).to(equal(false))
                    }
                    
                    it ("returns false if userID is nil")
                    {
                        userInfoService!.presets = presets
                        expect(userInfoService!.isInPresets(userID: nil)).to(equal(false))
                    }
                    
                    it ("returns fals if presets is nil")
                    {
                        userInfoService!.presets = nil
                        expect(userInfoService!.isInPresets(userID: "notInThePresetsID")).to(equal(false))
                    }
                }
            }
        }
    }
}
