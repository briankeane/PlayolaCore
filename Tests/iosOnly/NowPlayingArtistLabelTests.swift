//
//  LabelUpdaterTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//


import Foundation
import XCTest
import Quick
import Nimble

class LabelUpdaterTests: QuickSpec
{
    class TestDelegate:NSObject, PlayolaAutoUpdatingLabelDelegate
    {
        
        var displayText:String? = nil
        func alternateDisplayText(_ label: UILabel, audioBlockDict: [String:Any]?) -> String?
        {
            return displayText
        }
    }
    
    override func spec()
    {
        fdescribe("LabelUpdaterTests")
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
                    label.delegate = delegate
                    expect(label.text).toEventually(equal("BILLYBOB"))
                    delegate.displayText = "BETTYSUE"
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("BETTYSUE"))
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
                    label.delegate = delegate
                    expect(label.text).toEventually(equal("BILLYBOBSSONG"))
                    delegate.displayText = "BETTYSUESSONG"
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                    expect(label.text).toEventually(equal("BETTYSUESSONG"))
                }
            }
        }
    }
}

