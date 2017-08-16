//
//  SpinModelTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

import Foundation
import XCTest
import Quick
import Nimble

class SpinModelQuickTests: QuickSpec {
    
    override func spec()
    {
        describe("List Model Tests")
        {
            it ("initializes correctly")
            {
                let newSpin = Spin(spinInfo: ["id": "idSample",
                                              "isCommercialBlock": false,
                                              "playlistPosition": 12,
                                              "audioBlock": ["id": "audioBlockIDSample"],
                                              "audioBlockID": "audioBlockIDSample2",
                                              "userID": "userIDSample",
                                              "airtime": "2015-03-15T12:00:00.616Z",
                                              "endTime": "2015-03-15T13:00:00.616Z"])
                expect(newSpin.id).to(equal("idSample"))
                expect(newSpin.isCommercialBlock).to(equal(false))
                expect(newSpin.playlistPosition).to(equal(12))
                expect(newSpin.audioBlock!.id).to(equal("audioBlockIDSample"))
                expect(newSpin.audioBlockID).to(equal("audioBlockIDSample2"))
                expect(newSpin.userID).to(equal("userIDSample"))
                expect(newSpin.airtime!).to(equal(Date(isoString: "2015-03-15T12:00:00.616Z")))
            }
            
            it ("stores isCommercialBlock correctly")
            {
                let newSpin = Spin(spinInfo: ["isCommercialBlock": true])
                expect(newSpin.isCommercialBlock).to(beTrue())
                let otherNewSpin = Spin(spinInfo: ["test":"test"])
                expect(otherNewSpin.isCommercialBlock).to(beFalse())
            }
            
            it ("can tell if it is not currently playing")
            {
                let newSpin = Spin(spinInfo: ["id": "idSample",
                                              "isCommercialBlock": false,
                                              "playlistPosition": 12,
                                              "audioBlock": ["id": "audioBlockIDSample"],
                                              "audioBlockID": "audioBlockIDSample2",
                                              "userID": "userIDSample",
                                              "airtime": "2015-03-15T12:00:00.616Z",
                                              "endTime": "2015-03-15T13:00:00.616Z"])
                expect(newSpin.isPlaying()).to(beFalse())
            }
            
            it ("can tell if it is currently playing")
            {
                let newSpin = Spin(spinInfo: ["id": "idSample",
                                              "isCommercialBlock": false,
                                              "playlistPosition": 12,
                                              "audioBlock": ["id": "audioBlockIDSample", "eom":360000],
                                              "audioBlockID": "audioBlockIDSample2",
                                              "userID": "userIDSample",
                                              "airtime": "2015-03-15T12:00:00.616Z",
                                              "endTime": "2015-03-15T13:00:00.616Z"])
                newSpin.airtime = DateHandlerService.sharedInstance().now().addMinutes(-4)
                newSpin.endTime = DateHandlerService.sharedInstance().now().addMinutes(3)
                expect(newSpin.isPlaying()).to(beTrue())
            }
        }
    }
}
