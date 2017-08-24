//
//  PlayolaStationPlayerTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble
import AudioKit

class PlayolaStationPlayerTests: QuickSpec {
    override func spec()
    {
        describe("PlayolaStationPlayer")
        {
            var user:User! = DataMocker.users[1]!
            
            beforeEach
            {
                DataMocker.loadMocks()
                user = DataMocker.users[1]!
            }
            
            describe("loadUser")
            {
                var stationPlayer:PlayolaStationPlayer!
                var dateHandlerMock:DateHandlerMock!
                var PAPMock:PlayolaAudioPlayerMock!
                let emptyAKAudioFile = try! AKAudioFile()
                
                beforeEach
                {
                    PAPMock = PlayolaAudioPlayerMock()
                    dateHandlerMock = DateHandlerMock(dateAsReadableString: "2015-03-15 13:15:00")
                    stationPlayer = PlayolaStationPlayer()
                    stationPlayer.injectDependencies(PAPlayer: PAPMock, dateHandler: dateHandlerMock)
                }
                
                it ("does nothing if already playing the same user")
                {
                    try! PAPMock.nowPlayingPapSpin = PAPSpinMock(
                        audioFileURL: URL(fileURLWithPath: "/fakePath") , player: AKAudioPlayer(file: emptyAKAudioFile), startTime: dateHandlerMock.now().addSeconds(-10), beginFadeOutTime: dateHandlerMock.now().addSeconds(10), spinInfo: [:])
                    stationPlayer.userPlaying = user
                    stationPlayer.loadUserAndPlay(user: user)
                    expect(PAPMock.loadAudioCalledCount).to(equal(0))
                }
                
                it ("broadcasts loading")
                {
                    
                }
                
                
                // TODO: Figure out how to fucking test this
            }
            
            describe("clearPlayer()")
            {
                var PAPMock:PlayolaAudioPlayerMock!
                var stationPlayer:PlayolaStationPlayer!
                
                beforeEach
                {
                    PAPMock = PlayolaAudioPlayerMock()
                    stationPlayer = PlayolaStationPlayer()
                    stationPlayer.injectDependencies(PAPlayer: PAPMock)
                    stationPlayer.userPlaying = user
                }
                
                it ("clears the audioPlayer")
                {
                    stationPlayer.stop()
                    expect(PAPMock.stopCalledCount).to(equal(1))
                }
                
                it ("clears the previous user")
                {
                    stationPlayer.stop()
                    expect(stationPlayer.userPlaying).to(beNil())
                }
                
                it ("broadcasts that the player stopped")
                {
                    var transmittedUserInfo:[AnyHashable:Any]? = nil
                    var didBroadcast:Bool = false
                    NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.stoppedPlayingStation, object: nil, queue: .main, using: { (notification) in
                        transmittedUserInfo = notification.userInfo!
                        didBroadcast = true
                    })
                    stationPlayer.stop()
                    expect(didBroadcast).toEventually(equal(true))
                    let broadcastUser = transmittedUserInfo?["user"] as! User
                    expect(broadcastUser.id).to(equal(user.id))
                }
            }
        }
    }
}

