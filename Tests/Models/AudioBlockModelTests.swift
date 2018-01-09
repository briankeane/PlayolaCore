//
//  AudioBlockModelTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

class AudioBlockModelTests: QuickSpec
{
    override func spec()
    {
        describe("AudioBlock Model Tests")
        {
            var audioBlockInfo:Dictionary<String, Any> = Dictionary()
            
            beforeEach
            {
                audioBlockInfo = [ "id": "audioBlockID",
                                    "title":"aTitle",
                                    "artist":"bob",
                                    "song": "bobsSong",
                                    "duration": 65,
                                    "__t":"Song",
                                    "echonestID":"echonestIDPlaceholder",
                                    "itunesID": "itunesIDPlaceholder",
                                    "boo": 50,
                                    "eom": 100,
                                    "eoi": 10,
                                    "album":"bobsAlbum",
                                    "audioFileUrl":"/audioFileUrlPlaceholder",
                                    "key": "keyPlaceholder",
                                    "albumArtworkUrl": "albumArtworkUrl",
                                    "albumArtworkUrlSmall": "albumArtworkUrlSmall",
                                    "trackViewUrl": "trackViewUrlSample"]
            }
            
            it ("can be initialized with a Dictionary")
            {
                let song = AudioBlock(audioBlockInfo: audioBlockInfo)
                expect(song.title).to(equal("aTitle"))
                expect(song.artist).to(equal("bob"))
                expect(song.duration).to(equal(65))
                expect(song.__t).to(equal(AudioBlockType.song))
                expect(song.echonestID).to(equal("echonestIDPlaceholder"))
                expect(song.itunesID).to(equal("itunesIDPlaceholder"))
                expect(song.boo).to(equal(50))
                expect(song.eom).to(equal(100))
                expect(song.eoi).to(equal(10))
                expect(song.album).to(equal("bobsAlbum"))
                expect(song.audioFileUrl!.path).to(equal("/audioFileUrlPlaceholder"))
                expect(song.key).to(equal("keyPlaceholder"))
                expect(song.id).to(equal("audioBlockID"))
                expect(song.albumArtworkUrl).to(equal(URL(string: "albumArtworkUrl")))
                expect(song.albumArtworkUrlSmall).to(equal(URL(string: "albumArtworkUrlSmall")))
                expect(song.trackViewUrl).to(equal(URL(string:"trackViewUrlSample")))
            }
            
            it ("defaults to false isCommercialBlock")
            {
                let song = AudioBlock(audioBlockInfo: audioBlockInfo)
                expect(song.isCommercialBlock).to(beFalse())
            }
            
            it ("correctly initializes isCommercialBlock otherwise")
            {
                audioBlockInfo["isCommercialBlock"] = true
                let song = AudioBlock(audioBlockInfo: audioBlockInfo)
                expect(song.isCommercialBlock).to(beTrue())
            }
            
            describe ("__t")
            {
                it ("CommercialBlock")
                {
                    audioBlockInfo["__t"] = "CommercialBlock"
                    let audioBlock = AudioBlock(audioBlockInfo: audioBlockInfo)
                    expect(audioBlock.__t).to(equal(AudioBlockType.commercialBlock))
                }
                
                it ("LocalVoiceTrack")
                {
                    audioBlockInfo["__t"] = "LocalVoiceTrack"
                    let audioBlock = AudioBlock(audioBlockInfo: audioBlockInfo)
                    expect(audioBlock.__t).to(equal(AudioBlockType.localVoiceTrack))
                }
                
                it ("Song")
                {
                    audioBlockInfo["__t"] = "Song"
                    let audioBlock = AudioBlock(audioBlockInfo: audioBlockInfo)
                    expect(audioBlock.__t).to(equal(AudioBlockType.song))
                }
                
                it ("VoiceTrack")
                {
                    audioBlockInfo["__t"] = "Commentary"
                    let audioBlock = AudioBlock(audioBlockInfo: audioBlockInfo)
                    expect(audioBlock.__t).to(equal(AudioBlockType.voiceTrack))
                }
            }
        }
    }
}
