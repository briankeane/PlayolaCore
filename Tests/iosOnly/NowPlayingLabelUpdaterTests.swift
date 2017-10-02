//
//  NowPlayingLabelUpdaterTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//


import Foundation
import XCTest
import Quick
import Nimble

class NowPlayingLabelUpdaterTests: QuickSpec
{
    class TestDelegate:NSObject, NowPlayingLabelDelegate
    {
        
        var displayText:String? = nil
        
        func alternateDisplayText(_ label: NowPlayingLabel, audioBlockDict: [String : Any]?, defaultText:String) -> String? {
            return displayText
        }
    }
    
    override func spec()
    {
        describe("LabelUpdaterTests")
        {
            var spin:Spin = Spin()
            var delegate:TestDelegate = TestDelegate()
            var playerMock:PlayolaStationPlayerMock = PlayolaStationPlayerMock()
            
            beforeEach
            {
                spin = Spin(id: "imASpinID", audioBlock: AudioBlock(title:"BobsSong", artist: "Bob"))
                delegate = TestDelegate()
                playerMock = PlayolaStationPlayerMock()
                PlayolaStationPlayer.replaceSharedInstance(playerMock)
            }
            
            describe("NowPlayingArtistLabel")
            {
                it ("updates")
                {
                    let label = NowPlayingArtistLabel()
                    playerMock.nowPlayingSpin = spin
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("Bob"))
                }
                
                it ("sets its initial value if something is playing")
                {
                    playerMock.nowPlayingSpin = spin
                    let label = NowPlayingArtistLabel()
                    expect(label.text).toEventually(equal("Bob"))
                }
                
                it ("grabs alternate text from the protocol")
                {
                    let label = NowPlayingArtistLabel()
                    delegate.displayText = "BILLYBOB"
                    label.autoUpdatingDelegate = delegate
                    expect(label.text).toEventually(equal("BILLYBOB"))
                    delegate.displayText = "BETTYSUE"
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("BETTYSUE"))
                }
                
                it ("uses a placeholder if the player stops")
                {
                    let label = NowPlayingArtistLabel()
                    playerMock.nowPlayingSpin = nil
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: [:])
                    expect(label.text).toEventually(equal(label.blankText))
                }
            }
            
            describe("NowPlayingTitleLabel")
            {
                it ("updates")
                {
                    let label = NowPlayingTitleLabel()
                    playerMock.nowPlayingSpin = spin
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("BobsSong"))
                }
                
                it ("sets its initial value if something is playing")
                {
                    playerMock.nowPlayingSpin = spin
                    let label = NowPlayingTitleLabel()
                    expect(label.text).toEventually(equal("BobsSong"))
                }
                
                it ("grabs alternate text from the protocol")
                {
                    let label = NowPlayingTitleLabel()
                    delegate.displayText = "BILLYBOBSSONG"
                    label.autoUpdatingDelegate = delegate
                    expect(label.text).toEventually(equal("BILLYBOBSSONG"))
                    delegate.displayText = "BETTYSUESSONG"
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("BETTYSUESSONG"))
                }
                it ("uses a placeholder if the player stops")
                {
                    let label = NowPlayingTitleLabel()
                    playerMock.nowPlayingSpin = nil
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: [:])
                    expect(label.text).toEventually(equal(label.blankText))
                }
            }
            
            describe("NowPlayingTitleAndArtistLabel")
            {
                it ("updates")
                {
                    let label = NowPlayingTitleAndArtistLabel()
                    playerMock.nowPlayingSpin = spin
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("BobsSong - Bob"))
                }
                
                it ("sets its initial value if something is playing")
                {
                    playerMock.nowPlayingSpin = spin
                    let label = NowPlayingTitleAndArtistLabel()
                    expect(label.text).toEventually(equal("BobsSong - Bob"))
                }
                
                it ("grabs alternate text from the protocol")
                {
                    let label = NowPlayingTitleAndArtistLabel()
                    delegate.displayText = "BILLYBOBSSONG"
                    label.autoUpdatingDelegate = delegate
                    expect(label.text).toEventually(equal("BILLYBOBSSONG"))
                    delegate.displayText = "BETTYSUESSONG"
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("BETTYSUESSONG"))
                }
                
                it ("properly displays a commercial")
                {
                    let commercialBlock = AudioBlock(__t: "CommercialBlock", isCommercialBlock:true)
                    playerMock.nowPlayingSpin = Spin(audioBlock: commercialBlock)
                    let label = NowPlayingTitleAndArtistLabel()
                    expect(label.text).toEventually(equal("Commercials"))
                }
                
                it ("properly displays a VoiceTrack")
                {
                    let voicetrack = AudioBlock(__t: "Commentary")
                    playerMock.nowPlayingSpin = Spin(audioBlock: voicetrack)
                    let label = NowPlayingTitleAndArtistLabel()
                    expect(label.text).toEventually(equal("VoiceTrack"))
                }
                
                fit ("uses a placeholder if the player stops")
                {
                    let label = NowPlayingTitleAndArtistLabel()
                    playerMock.nowPlayingSpin = nil
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: [:])
                    expect(label.text).toEventually(equal(label.blankText))
                }
            }
        }
    }
}

