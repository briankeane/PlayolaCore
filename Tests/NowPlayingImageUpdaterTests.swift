//
//  NowPlayingImageUpdaterTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//


import Foundation
import XCTest
import Quick
import Nimble


/// TODO: ADD TESTS FOR NOWPLAYINGIMAGEUPDATER.  Should be similar to the NowPlayingLabelUpdater tests.


class NowPlayingImageUpdaterTests: QuickSpec
{
    override func spec()
    {
        describe("NowPlayingImageUpdaterTests")
        {
            var spin:Spin = Spin()
            var playerMock:PlayolaStationPlayerMock = PlayolaStationPlayerMock()
            
            beforeEach
            {
                spin = Spin(id: "imASpinID", audioBlock: AudioBlock(title:"BobsSong", artist: "Bob"))
                playerMock = PlayolaStationPlayerMock()
                PlayolaStationPlayer.replaceSharedInstance(playerMock)
            }
            
            describe("NowPlayingAlbumArtworkImageView")
            {
//                it ("starts with a placeholder")
//                {
////                    let imageView = NowPlayingAlbumArtworkImageView(image: nil)
////                    expect(imageView.image).to(equal(UIImage(named: "missingAlbumPlaceholder.png")))
//                }
            }
        }
    }
}
