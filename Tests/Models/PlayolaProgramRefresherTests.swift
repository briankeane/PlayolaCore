//
//  PlayolaProgramRefresherTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Nimble
import Quick

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
                user.startAutoUpdating()
                refresher = PlayolaProgramRefresher(user: user)
            }
            
            afterEach
            {
                for observer in observers
                {
                    NotificationCenter.default.removeObserver(observer)
                }
                observers = Array()
            }
            
            it ("grabs updates when they occur")
            {
                let userCopy = user.copy()
                userCopy.updatedAt = Date(dateString: "2090-3-15 08:55:55")
                userCopy.program?.nowPlaying = Spin(id: "theNewSpinID")
                NotificationCenter.default.post(name: PlayolaEvents.userUpdated, object: nil, userInfo: ["user":userCopy])
                expect(user.program?.nowPlaying?.id).to(equal("theNewSpinID"))
            }
            
            it ("resets the timer if an outside update occurs")
            {
                // TODO: Figure out how to test this
                let userCopy = user.copy()
                userCopy.updatedAt = Date(dateString: "2090-3-15 08:55:55")
                userCopy.program?.nowPlaying = Spin(id: "theNewSpinID")
                refresher.restartTimer()
                let oldFireDate = refresher.refreshTimer!.fireDate
                NotificationCenter.default.post(name: PlayolaEvents.userUpdated, object: nil, userInfo: ["user":userCopy])
                expect(refresher.refreshTimer!.fireDate).to(beGreaterThan(oldFireDate))
            }
        }
    }
}
            
