//
//  RotationItemsCollectionTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble

class RotationItemsCollectionModelQuickTests: QuickSpec
{
    override func spec()
    {
        describe("Rotation Items Collection")
        {
            var dataMocker:DataMocker!
            
            beforeEach
            {
                dataMocker = DataMocker()
                dataMocker.loadMocks()
            }
            
            describe("listBins()")
            {
                it ("lists the bins")
                {
                    let bins:Array<String> = dataMocker.rotationItemsCollection.listBins()
                    expect(bins).to(equal(["heavy", "light", "medium"]))
                }
            }
            
            describe("rotationItemIDFromSongID")
            {
                it ("returns the correct rotationItemID")
                {
                    expect(dataMocker.rotationItemsCollection.rotationItemIDFromSongID(dataMocker.rotationItemsCollection.rotationItems[0].song.id!)).to(equal(dataMocker.rotationItemsCollection.rotationItems[0].id))
                }
                
                it ("returns nil if not found")
                {
                    expect(dataMocker.rotationItemsCollection.rotationItemIDFromSongID("fakeID")).to(beNil())
                }
            }
            
            describe("asList")
            {
                var rotationItemsArray:[RotationItem]!
                var rotationItemsCollection:RotationItemsCollection!
                
                beforeEach
                {
                    rotationItemsArray = [
                        RotationItem(id: "1", song: AudioBlock(__t: .song, title: "Apple", artist: "Zebra")),
                        RotationItem(id: "2", song: AudioBlock(__t: .song, title: "Banana", artist: "Stone")),
                        RotationItem(id: "3", song: AudioBlock(__t: .song, title: "Cherry", artist: "Kaia")),
                        RotationItem(id: "4", song: AudioBlock(__t: .song, title: "Cherry", artist: "Ruby")),
                        RotationItem(id: "5", song: AudioBlock(__t: .song, title: "Fruitcake", artist: "Ruby")),
                        RotationItem(id: "6", song: AudioBlock(__t: .song, title: "Fruitcake", artist: "Amy"))
                    ]
                    rotationItemsCollection = RotationItemsCollection(rotationItems: rotationItemsArray)
                }
                it ("returns in order of artist")
                {
                    let sortedByArtist = rotationItemsCollection.asList(listOrder: .artist)
                    expect(sortedByArtist.map({$0.id})).to(equal(["6","3","4","5","2","1"]))
                }
                
                it ("returns in order of song title")
                {
                    let sortedByTitle = rotationItemsCollection.asList(listOrder: .title)
                    expect(sortedByTitle.map({$0.id})).to(equal(["1","2","3","4","6","5"]))
                }
            }
            
            describe ("getters / existence checkers")
            {
                var rotationItemsArray:[RotationItem]!
                var rotationItemsCollection:RotationItemsCollection!
                
                beforeEach
                {
                    rotationItemsArray = [
                        RotationItem(id: "0", song: AudioBlock(id: "audioBlockID0", __t: .song, title: "Apple", artist: "Zebra", spotifyID: "spotifyID0")),
                        RotationItem(id: "1", song: AudioBlock(id: "audioBlockID1", __t: .song, title: "Banana", artist: "Stone", spotifyID: "spotifyID1")),
                        RotationItem(id: "2", song: AudioBlock(id: "audioBlockID2", __t: .song, title: "Cherry", artist: "Kaia", spotifyID: "spotifyID2")),
                        RotationItem(id: "3", song: AudioBlock(id: "audioBlockID3", __t: .song, title: "Cherry", artist: "Ruby", spotifyID: "spotifyID3")),
                        RotationItem(id: "4", song: AudioBlock(id: "audioBlockID4", __t: .song, title: "Fruitcake", artist: "Ruby", spotifyID: "spotifyID4")),
                        RotationItem(id: "5", song: AudioBlock(id: "audioBlockID5", __t: .song, title: "Fruitcake", artist: "Amy", spotifyID: "spotifyID5"))
                    ]
                    rotationItemsCollection = RotationItemsCollection(rotationItems: rotationItemsArray)
                }
                
                describe ("fetchers")
                {
                    it ("by spotifyID")
                    {
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "spotifyID3")!.id).to(equal(rotationItemsArray[3].id))
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "spotifyID3")!.id).to(equal(rotationItemsArray[3].id))
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "spotifyID3")!.id).to(equal(rotationItemsArray[3].id))
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "wrongID")).to(beNil())
                    }
                    
                    it ("by rotationItemID")
                    {
                        expect(rotationItemsCollection.getRotationItem(rotationItemID: "3")!.song.spotifyID).to(equal(rotationItemsArray[3].song.spotifyID))
                        expect(rotationItemsCollection.getRotationItem(rotationItemID: "4")!.song.spotifyID).to(equal(rotationItemsArray[4].song.spotifyID))
                        expect(rotationItemsCollection.getRotationItem(rotationItemID: "5")!.song.spotifyID).to(equal(rotationItemsArray[5].song.spotifyID))
                        expect(rotationItemsCollection.getRotationItem(rotationItemID: "wrongID")).to(beNil())
                    }
                    
                    it ("by songID")
                    {
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "spotifyID3")!.id).to(equal(rotationItemsArray[3].id))
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "spotifyID3")!.id).to(equal(rotationItemsArray[3].id))
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "spotifyID3")!.id).to(equal(rotationItemsArray[3].id))
                        expect(rotationItemsCollection.getRotationItem(spotifyID: "wrongID")).to(beNil())
                    }
                }
                
                describe ("check for existence")
                {
                    it ("by spotifyID")
                    {
                        expect(rotationItemsCollection.contains(spotifyID: "spotifyID3")).to(equal(true))
                        expect(rotationItemsCollection.contains(spotifyID: "spotifyID3")).to(equal(true))
                        expect(rotationItemsCollection.contains(spotifyID: "spotifyID3")).to(equal(true))
                        expect(rotationItemsCollection.contains(spotifyID: "wrongID")).to(equal(false))
                    }
                    
                    it ("by rotationItemID")
                    {
                        expect(rotationItemsCollection.contains(rotationItemID: "3")).to(equal(true))
                        expect(rotationItemsCollection.contains(rotationItemID: "4")).to(equal(true))
                        expect(rotationItemsCollection.contains(rotationItemID: "5")).to(equal(true))
                        expect(rotationItemsCollection.contains(rotationItemID: "wrongID")).to(equal(false))
                    }
                    
                    it ("by songID")
                    {
                        expect(rotationItemsCollection.contains(spotifyID: "spotifyID3")).to(equal(true))
                        expect(rotationItemsCollection.contains(spotifyID: "spotifyID3")).to(equal(true))
                        expect(rotationItemsCollection.contains(spotifyID: "spotifyID3")).to(equal(true))
                        expect(rotationItemsCollection.contains(spotifyID: "wrongID")).to(equal(false))
                    }
                }
            }
        }
    }
    
}
