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
            var dataMocker:DataMocker!
            
            beforeEach
            {
                dataMocker = DataMocker()
                user = dataMocker.generateUsers(1)[0]
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
            
            it ("does not call if user deleted")
            {
                var callCount:Int = 0
                var deallocUser:User? = user.copy()
                deallocUser!.onNowPlayingAdvanced({
                    (user) -> Void in
                    callCount += 1
                })
                let advancer = PlayolaProgramAutoAdvancer(user: deallocUser!)
                advancer.advanceProgram()
                deallocUser = nil
                advancer.advanceProgram()
                expect(callCount).to(equal(1))
            }
            
            it ("only advances one at a time")
            {
                let oldPlaylist0ID = user.program!.playlist![0].id!
                let oldPlaylist1ID = user.program!.playlist![1].id!
                let advancer = PlayolaProgramAutoAdvancer(user: user, dateHandler: dateHandlerMock)
                let userCopy = user.copy()
                let advancer2 = PlayolaProgramAutoAdvancer(user: userCopy, dateHandler: dateHandlerMock)
                
                advancer.advanceProgram()
                advancer2.advanceProgram()
                
                expect(user.program!.nowPlaying!.id!).to(equal(oldPlaylist0ID))
                expect(user.program!.playlist![0].id!).to(equal(oldPlaylist1ID))
                expect(userCopy.program!.nowPlaying!.id!).to(equal(oldPlaylist0ID))
                expect(userCopy.program!.playlist![0].id!).to(equal(oldPlaylist1ID))
                
            }
        }
    }
}
