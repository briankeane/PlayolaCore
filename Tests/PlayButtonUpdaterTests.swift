//
//  PlayButtonUpdaterTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/30/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble

class PlayButtonUpdaterTests: QuickSpec
{
    override func spec()
    {
        describe("PlayButtonUpdaterTests")
        {
            var spin:Spin = Spin()
            var playerMock:PlayolaStationPlayerMock = PlayolaStationPlayerMock()
            
            beforeEach
            {
                spin = Spin(id: "imASpinID", audioBlock: AudioBlock(title:"BobsSong", artist: "Bob"))
                playerMock = PlayolaStationPlayerMock()
                    PlayolaStationPlayer.replaceSharedInstance(playerMock)
                
            }
            
            describe("playButton")
            {
                describe ("text")
                {
                    it ("updates if stopped")
                    {
                        let button = AutoUpdatingPlayButtonWithText()
                        button.setTitle(title: "-----")
                        playerMock.nowPlayingSpin = nil
                        playerMock.shouldBePlaying = false
                        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stationChanged, object: nil, userInfo: [:])
                        
                        expect(button.getTitle()).toEventually(equal("Play"))
                    }
                    
                    it ("updates if playing")
                    {
                        let button = AutoUpdatingPlayButtonWithText()
                        button.setTitle(title: "-----")
                        playerMock.nowPlayingSpin = spin
                        playerMock.shouldBePlaying = true
                        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stationChanged, object: nil, userInfo: ["spin": spin])
                        expect(button.getTitle()).toEventually(equal("Stop"))
                    }
                    
                    it ("updates if loading")
                    {
                        let button = AutoUpdatingPlayButtonWithText()
                        button.setTitle(title: "------")
                        playerMock.nowPlayingSpin = nil
                        playerMock.isLoading = true
                        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stationChanged, object: nil, userInfo: ["spin": spin])
                        expect(button.getTitle()).toEventually(equal("Stop"))
                    }
                }
                
                describe ("image")
                {
                    // TODO: Test Images
                }
            }
        }
    }
}

