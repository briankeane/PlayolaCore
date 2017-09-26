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

class NowPlayingArtistLabelTests: QuickSpec
{
    override func spec()
    {
        describe("NowPlayingArtistLabelTests")
        {
            var spin:Spin = Spin()
            beforeEach
            {
                spin = Spin(id: "imASpinID", audioBlock: AudioBlock(artist: "Bob"))
            }
            
            it ("updates")
            {
                let label = NowPlayingArtistLabel()
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin": spin])
                expect(label.text).toEventually(equal("Bob"))
            }
            
            fit ("sets its initial value if something is playing")
            {
                let playerMock = PlayolaStationPlayerMock()
                PlayolaStationPlayer.replaceSharedInstance(playerMock)
                playerMock.nowPlayingSpin = spin
                let label = NowPlayingArtistLabel()
                expect(label.text).toEventually(equal("Bob"))
                
                
            }
        }
    }
}

