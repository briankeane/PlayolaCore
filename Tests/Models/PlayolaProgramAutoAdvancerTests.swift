//
//  PlayolaProgramAutoAdvancerTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/29/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

class PlayolaProgramAdvancerTests: QuickSpec
{
    override func spec()
    {
        describe("PlayolaProgramAutoAdvancer")
        {
            let dateHandlerMock:DateHandlerMock = DateHandlerMock()
            var user:User!
            
            beforeEach
            {
                user = DataMocker.generateUsers(1)[0]!
            }
            
            it ("schedules the next advance")
            {
                // set dateHandler time to 5 secs before advance
                dateHandlerMock.setDate(user.program!.playlist![0].airtime?.addSeconds(-5))
                
                let advancer = PlayolaProgramAutoAdvancer(user: user, dateHandler: dateHandlerMock)
                
                advancer.scheduleNextAdvance()
                expect(advancer.advanceTimer!.fireDate).to(equal(user.program!.playlist![0].airtime))
            }
            
            it ("performs an advance")
            {
                let oldPlaylist0ID = user.program!.playlist![0].id!
                let oldPlaylist1ID = user.program!.playlist![1].id!
                let advancer = PlayolaProgramAutoAdvancer(user: user, dateHandler: dateHandlerMock)
                advancer.advanceProgram()
                expect(user.program!.nowPlaying!.id!).to(equal(oldPlaylist0ID))
                expect(user.program!.playlist![0].id!).to(equal(oldPlaylist1ID))
            }
            
            it ("executes callbacks on nowPlaying change")
            {
                var numberOneFired = false
                var numberTwoFired = false
                let advancer = PlayolaProgramAutoAdvancer(user: user)
                user.onNowPlayingAdvanced({
                    (user) in
                    numberOneFired = true
                })
                    .onNowPlayingAdvanced({
                        (user) in
                        numberTwoFired = true
                    })
                advancer.advanceProgram()
                expect(numberOneFired).toEventually(equal(true))
                expect(numberTwoFired).toEventually(equal(true))
            }
            
            
        }
    }
}
