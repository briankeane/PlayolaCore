//
//  UserModelTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

class UserModelQuickTests: QuickSpec {
    
    override func spec()
    {
        describe("User Model Tests")
        {
            var dataMocker:DataMocker!
            
            beforeEach
            {
                dataMocker = DataMocker()
            }
            
            it ("initializes correctly with raw server info")
            {
                let userInfo:NSDictionary = [  "displayName": "Bob",
                                  "twitterUID": "bobsTwitterUID",
                                  "facebookUID": "bobsFacebookUID",
                                  "googleUID":"bobsGoogleUID",
                                  "instagramUID":"bobsInstagramUID",
                                  "email":"bob@bob.com",
                                  "birthYear":"1977",
                                  "zipcode":"78748",
                                  "timezone":"America/Chicago",
                                  "updatedAt": Date(dateString: "2015-3-15 13:15:00").toISOString(),
                                  "role":"user",
                                  "lastCommercial": [ "commercialBlockNumber":58,
                                                      "audioFileID":25 ],
                                  "playlist": [["airtime": Date(dateString: "2015-3-15 13:19:00").toISOString()]],
                                  "profileImageUrl":"profileImageUrlSample",
                                  "profileImageUrlSmall":"profileImageUrlSmall",
                                  "id": "sampleID",
                                  "secsOfCommercialPerHour": 180,
                                  "dailyListenTimeMS": 50,
                                  "apotifyPlaylistID": "aSampleSpotifyPlaylistID"
                                ]
                let bob = User(userInfo: userInfo)
                expect(bob.birthYear).to(equal("1977"))
                expect(bob.displayName).to(equal("Bob"))
                expect(bob.twitterUID).to(equal("bobsTwitterUID"))
                expect(bob.facebookUID).to(equal("bobsFacebookUID"))
                expect(bob.googleUID).to(equal("bobsGoogleUID"))
                expect(bob.instagramUID).to(equal("bobsInstagramUID"))
                expect(bob.email).to(equal("bob@bob.com"))
                expect(bob.zipcode).to(equal("78748"))
                expect(bob.timezone).to(equal("America/Chicago"))
                expect(bob.role).to(equal(PlayolaUserRole.user))
                expect(bob.lastCommercial!["commercialBlockNumber"] as? Int).to(equal(58))
                expect(bob.lastCommercial!["audioFileID"] as? Int).to(equal(25))
                expect(bob.profileImageUrl?.absoluteString).to(equal("profileImageUrlSample"))
                expect(bob.profileImageUrlSmall?.absoluteString).to(equal("profileImageUrlSmall"))
                expect(bob.id).to(equal("sampleID"))
                expect(bob.secsOfCommercialPerHour).to(equal(180))
                expect(bob.dailyListenTimeMS).to(equal(50))
                expect(bob.program).toNot(beNil())
                expect(bob.updatedAt?.toISOString()).to(equal(userInfo["updatedAt"] as? String))
                expect(bob.spotifyPlaylistID).to(equal("aSampleSpotifyPlaylistID"))
            }
            
            it ("does not create a program if the playlist is nil")
            {
                var rawBob:Dictionary<String,Any> = dataMocker.getRawServerUsers(1)[0]
                rawBob["playlist"] = nil
                let bob = User(userInfo: rawBob as NSDictionary)
                expect(bob.program).to(beNil())
            }
            
            it ("does not create a program if the playlist is empty")
            {
                var rawBob:Dictionary<String,Any> = dataMocker.getRawServerUsers(1)[0]
                rawBob["playlist"] = Array<Dictionary<String,Any>>() as Any?
                let bob = User(userInfo: rawBob as NSDictionary)
                expect(bob.program).to(beNil())
            }
        }
        
        describe("roles")
        {
            it ("can tell if a server has the proper role")
            {
                let user = User(userInfo: ["displayName":"Bob",
                                           "role": "user"
                    ])
                expect(user.hasRole(.admin)).to(equal(false))
                user.role = .admin
                expect(user.hasRole(.admin)).to(equal(true))
            }
        }
    }
}
