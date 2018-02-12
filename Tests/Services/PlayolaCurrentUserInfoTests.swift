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
                        apiMock.getRotationItemsResponse = dataMocker.rotationItemsCollection
                        
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
                        apiMock.getRotationItemsShouldNeverReturn = true
                        apiMock.getPresetsShouldSucceed = true
                        apiMock.getPresetsPresets = presets
                        NotificationCenter.default.post(name: PlayolaEvents.signedIn, object: nil, userInfo: nil)
                        let presetsIDs = presets.map({$0.id})
                        expect(userInfoService!.favorites?.map({$0.id})).toEventually(equal(presetsIDs))
                    }
                    
                    it ("clears the presets on .signedOut")
                    {
                        userInfoService!.favorites = presets
                        NotificationCenter.default.post(name: PlayolaEvents.signedOut, object: nil, userInfo: nil)
                        expect(userInfoService!.favorites).toEventually(beNil())
                    }
                    
                   it ("updates the presets on .currentUserPresetsReceived")
                   {
                        userInfoService?.favorites = presets

                        NotificationCenter.default.post(name: PlayolaEvents.currentUserPresetsReceived, object: nil, userInfo: ["presets": replacementPresets])
                        let replacementIDs = replacementPresets.map({$0.id})
                        expect(userInfoService!.favorites?.map({$0.id})).toEventually(equal(replacementIDs))
                    }
                    
                    it ("broadcasts .presetsUpdated when the presets get updated")
                    {
                        userInfoService?.favorites = presets
                        let updatedNotification = Notification(name: PlayolaEvents.favoritesUpdated, object: nil, userInfo: ["favorites": replacementPresets])
                        expect {
                            NotificationCenter.default.post(name: PlayolaEvents.currentUserPresetsReceived, object: nil, userInfo: ["favorites": replacementPresets])
                        }.toEventually(postNotifications(contain(updatedNotification)))
                    }
                }
                
                describe ("isInPresets")
                {
                    it ("returns true if the userID is in the presets")
                    {
                        userInfoService!.favorites = presets
                        let isPresentID = presets[2].id!
                        expect(userInfoService!.isInPresets(userID: isPresentID)).to(equal(true))
                    }
                    
                    it ("returns false if it is not")
                    {
                        userInfoService!.favorites = presets
                        expect(userInfoService!.isInPresets(userID: "notInThePresetsID")).to(equal(false))
                    }
                    
                    it ("returns false if userID is nil")
                    {
                        userInfoService!.favorites = presets
                        expect(userInfoService!.isInPresets(userID: nil)).to(equal(false))
                    }
                    
                    it ("returns fals if presets is nil")
                    {
                        userInfoService!.favorites = nil
                        expect(userInfoService!.isInPresets(userID: "notInThePresetsID")).to(equal(false))
                    }
                }
                
                describe ("lastSeenAirtimeReported")
                {
                    it ("initializes as nil")
                    {
                        expect(userInfoService!.lastSeenAirtime).to(beNil())
                    }
                    
                    it ("records a later time if starting with nil")
                    {
                        userInfoService!.lastSeenAirtime = nil
                        let newDate = Date.init(dateString: "2016-04-15 13:02:00")
                        NotificationCenter.default.post(name: PlayolaEvents.playlistViewedAtAirtime, object: nil, userInfo: ["airtime": newDate ])
                        expect(userInfoService!.lastSeenAirtime).toEventually(equal(newDate))
                    }
                    
                    it ("records a later time if starting with earlier date")
                    {
                        let earlierDate = Date.init(dateString: "2016-04-15 13:02:00")
                        let laterDate = Date.init(dateString: "2016-04-15 14:30:00")
                        userInfoService!.lastSeenAirtime = earlierDate
                        NotificationCenter.default.post(name: PlayolaEvents.playlistViewedAtAirtime, object: nil, userInfo: ["airtime": laterDate ])
                        expect(userInfoService!.lastSeenAirtime).toEventually(equal(laterDate))
                    }
                    
                    it ("does not record an earlier time")
                    {
                        userInfoService!.lastSeenAirtime = Date.init(dateString: "2016-04-15 13:02:00")
                        let earlierDate = Date.init(dateString: "2016-04-15 12:00:00")
                        NotificationCenter.default.post(name: PlayolaEvents.playlistViewedAtAirtime, object: nil, userInfo: ["airtime": earlierDate ])
                        expect(userInfoService!.lastSeenAirtime).toNotEventually(equal(earlierDate))
                    }
                }
                
                describe ("current user's rotationItemsCollection")
                {
                    describe ("initialization")
                    {
                        it ("loads rotationItems on .signedIn")
                        {
                            userInfoService!.rotationItemsCollection = nil
                            apiMock.getRotationItemsResponse = dataMocker.rotationItemsCollection
                            apiMock.getPresetsPresets = Array()
                            
                            NotificationCenter.default.post(name: PlayolaEvents.signedIn, object: nil, userInfo: nil)
                            expect(apiMock.getRotationItemsCount).toEventually(equal(1))
                            expect(userInfoService!.rotationItemsCollection?.rotationItems.map({$0.id})).toEventually(equal(dataMocker.rotationItemsCollection.rotationItems.map({$0.id})))
                        }
                    }
                    
                    describe ("deactivation")
                    {
                        it ("sets the current ri as .removalInProgress")
                        {
                            userInfoService!.rotationItemsCollection = dataMocker.rotationItemsCollection
                            let riToRemove = userInfoService!.rotationItemsCollection!.rotationItems[2]
                            apiMock.removeRotationItemsAndResetShouldNeverReturn = true
                            _ = userInfoService!.deactivateRotationItem(rotationItemID: riToRemove.id)
                            expect(userInfoService!.rotationItemsCollection?.getRotationItem(rotationItemID: riToRemove.id)?.removalInProgress).toEventually(equal(true))
                        }
                        
                        describe ("api success")
                        {
                            var riToRemove:RotationItem!
                            var responseRotationItemsCollection:RotationItemsCollection!
                            
                            beforeEach
                            {
                                userInfoService!.rotationItemsCollection = dataMocker.rotationItemsCollection
                                riToRemove = userInfoService!.rotationItemsCollection!.rotationItems[2]
                                responseRotationItemsCollection = RotationItemsCollection(rotationItems: userInfoService!.rotationItemsCollection!.rotationItems)
                                responseRotationItemsCollection.rotationItems.remove(at: 2)
                                apiMock.removeRotationItemsAndResetResponse = responseRotationItemsCollection
                            }
                            
                            it ("calls api properly on success")
                            {
                                waitUntil
                                {
                                    (done) -> Void in
                                    userInfoService!.deactivateRotationItem(rotationItemID: riToRemove.id)
                                    .then
                                    {
                                        (newRotationItemsCollection) -> Void in
                                        expect(apiMock.removeRotationItemsAndResetCount).to(equal(1))
                                        expect(apiMock.removeRotationItemsAndResetArgs[0]["rotationItemIDs"] as? [String]).to(equal([riToRemove.id]))
                                        done()
                                    }
                                    .catch
                                    {
                                        (error) -> Void in
                                        fail("deactivateRotationItem should not have failed. \(error.localizedDescription)")
                                    }
                                }
                            }
                            
                            it ("passes the new rotationItemsCollection along properly")
                            {
                                waitUntil
                                {
                                    (done) -> Void in
                                    userInfoService!.deactivateRotationItem(rotationItemID: riToRemove.id)
                                    .then
                                    {
                                        (newRotationItemsCollection) -> Void in
                                        let riIDs = newRotationItemsCollection.rotationItems.map({$0.id})
                                        expect(riIDs).toNot(contain(riToRemove.id))
                                        expect(newRotationItemsCollection.rotationItems.count).to(equal(dataMocker.rotationItemsCollection.rotationItems.count-1))
                                        done()
                                    }
                                    .catch
                                    {
                                        (error) -> Void in
                                        fail("deactivateRotationItem should not have failed. \(error.localizedDescription)")
                                    }
                                }
                            }
                            
                            it ("replaces it's own rotationItemsCollection with the new one")
                            {
                                waitUntil
                                {
                                    (done) -> Void in
                                    userInfoService!.deactivateRotationItem(rotationItemID: riToRemove.id)
                                    .then
                                    {
                                        (newRotationItemsCollection) -> Void in
                                        let riIDs = userInfoService!.rotationItemsCollection!.rotationItems.map({$0.id})
                                        expect(riIDs).toNot(contain(riToRemove.id))
                                        expect(newRotationItemsCollection.rotationItems.count).to(equal(dataMocker.rotationItemsCollection.rotationItems.count-1))
                                        done()
                                    }
                                    .catch
                                    {
                                        (error) -> Void in
                                        fail("deactivateRotationItem should not have failed. \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        
                        describe ("api error")
                        {
                            var riToRemove:RotationItem!
                            var responseRotationItemsCollection:RotationItemsCollection!
                            
                            beforeEach
                            {
                                userInfoService!.rotationItemsCollection = dataMocker.rotationItemsCollection
                                riToRemove = userInfoService!.rotationItemsCollection!.rotationItems[2]
                                responseRotationItemsCollection = RotationItemsCollection(rotationItems: userInfoService!.rotationItemsCollection!.rotationItems)
                                responseRotationItemsCollection.rotationItems.remove(at: 2)
                                apiMock.removeRotationItemsAndResetShouldSucceed = false
                                apiMock.removeRotationItemsAndResetError = APIErrorMock(type: APIErrorType.badRequest)
                            }
                            
                            it ("resets .removalInProgress")
                            {
                                waitUntil
                                {
                                    (done) -> Void in
                                    userInfoService!.deactivateRotationItem(rotationItemID: riToRemove.id)
                                    .then
                                    {
                                        (newRotationItemsCollection) -> Void in
                                        fail("deactivateRotationItem should not have succeeded")
                                    }
                                    .catch
                                    {
                                        (error) -> Void in
                                        let riIDs = userInfoService!.rotationItemsCollection!.rotationItems.map({$0.id})
                                        expect(riIDs).to(contain(riToRemove.id))
                                    expect(userInfoService!.rotationItemsCollection!.rotationItems.count).to(equal(dataMocker.rotationItemsCollection.rotationItems.count))
                                        expect(userInfoService!.rotationItemsCollection!.getRotationItem(rotationItemID: riToRemove.id)?.removalInProgress).to(equal(false))
                                        done()
                                    }
                                }
                            }
                            
                            it ("passes along the error")
                            {
                                waitUntil
                                {
                                    (done) -> Void in
                                    userInfoService!.deactivateRotationItem(rotationItemID: riToRemove.id)
                                    .then
                                    {
                                        (newRotationItemsCollection) -> Void in
                                        fail("deactivateRotationItem should not have succeeded")
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
        }
    }
}
