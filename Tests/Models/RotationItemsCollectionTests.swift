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
            beforeEach
            {
                DataMocker.loadMocks()
            }
            
            describe("listBins()")
            {
                it ("lists the bins")
                {
                    let bins:Array<String> = DataMocker.rotationItemsCollection.listBins()
                    expect(bins).to(equal(["heavy", "light", "medium"]))
                }
            }
            
            describe ("isInRotation")
            {
                it ("works if it should be true")
                {
                    let song:Dictionary<String,AnyObject> = DataMocker.rawRotationItemsCollection["heavy"]![0]["song"]! as! Dictionary<String, AnyObject>
                    let id = song["id"] as! String
                    expect(DataMocker.rotationItemsCollection.isInRotation(id)).to(beTrue())
                }
                
                it ("works if it should be false")
                {
                    expect(DataMocker.rotationItemsCollection.isInRotation("fakeID")).to(beFalse())
                }
            }
            
            describe("rotationItemIDFromSongID")
            {
                it ("returns the correct rotationItemID")
                {
                    expect(DataMocker.rotationItemsCollection.rotationItemIDFromSongID(DataMocker.rotationItemsCollection.rotationItems[0].song.id!)).to(equal(DataMocker.rotationItemsCollection.rotationItems[0].id))
                }
                
                it ("returns nil if not found")
                {
                    expect(DataMocker.rotationItemsCollection.rotationItemIDFromSongID("fakeID")).to(beNil())
                }
            }
        }
    }
    
}
