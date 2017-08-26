//
//  PlayolaProgramRefresherTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

class PlayolaProgramRefresherTests: QuickSpec
{
    override func spec()
    {
        describe("PlayolaProgramRefresher")
        {
            var user:User!
            var observers:[NSObjectProtocol] = Array()
            var refresher:PlayolaProgramRefresher!
            
            beforeEach
            {
                DataMocker.loadMocks()
                user = DataMocker.users[0]!
                observers = Array()
                refresher = user.requireProgramUpdates()
            }
            
            afterEach
            {
                for observer in observers
                {
                    NotificationCenter.default.removeObserver(observer)
                }
                observers = Array()
            }
            
            it ("updates")
            {
                NotificationCenter.default.post(name: PlayolaEvents.userUpdateRequested, object: nil, userInfo: ["userID":"aUserID"])
                expect(apiMock.getUserCallCount).to(equal(1))
                expect(apiMock.getUserArgs[0]).to(equal("aUserID"))
            }
        }
    }
}
            
