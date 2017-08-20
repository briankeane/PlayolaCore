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
            describe("loadUser")
            {
                var stationPlayer:PlayolaStationPlayer!
                var dateHandlerMock:DateHandlerMock!
                var PAPMock:PlayolaAudioPlayerMock!
                var user:User!
                let emptyAKAudioFile = try! AKAudioFile()
                
                beforeEach
                {
                    PAPMock = PlayolaAudioPlayerMock()
                    dateHandlerMock = DateHandlerMock(dateAsReadableString: "2015-03-15 13:15:00")
                    stationPlayer = PlayolaStationPlayer()
                    stationPlayer.injectDependencies(PAPlayer: PAPMock, dateHandler: dateHandlerMock)
                    DataMocker.loadMocks()
                    user = DataMocker.users[1]!
                }
                
                it ("does nothing if already playing")
                {
                    try! PAPMock.nowPlayingPapSpin = PAPSpinMock(
                        audioFileURL: URL(fileURLWithPath: "/fakePath") , player: AKAudioPlayer(file: emptyAKAudioFile), startTime: dateHandlerMock.now().addSeconds(-10), beginFadeOutTime: dateHandlerMock.now().addSeconds(10), spinInfo: [:])
                    stationPlayer.loadUserAndPlay(user)
                    expect(PAPMock.loadAudioCalledCount).to(equal(0))
                }
                
                // TODO: Figure out how to fucking test this
            }
        }
    }
}

