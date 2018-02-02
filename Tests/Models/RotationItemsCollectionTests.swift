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
            
            describe ("isInRotation")
            {
                it ("works if it should be true")
                {
                    let song:Dictionary<String,AnyObject> = dataMocker.rawRotationItemsCollection["heavy"]![0]["song"]! as! Dictionary<String, AnyObject>
                    let id = song["id"] as! String
                    expect(dataMocker.rotationItemsCollection.isInRotation(id)).to(beTrue())
                }
                
                it ("works if it should be false")
                {
                    expect(dataMocker.rotationItemsCollection.isInRotation("fakeID")).to(beFalse())
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
        }
    }
    
}
