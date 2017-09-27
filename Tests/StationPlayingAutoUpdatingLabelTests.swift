//
//  StationPlayingAutoUpdatingLabelTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//


//
//  StationPlayingAutoUpdatingLabelTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//


import Foundation
import XCTest
import Quick
import Nimble

class StationPlayingAutoUpdatingLabelTests: QuickSpec
{
    class TestDelegate:NSObject, StationPlayingLabelDelegate
    {
        var displayText:String? = nil
        func alternateDisplayText(_ label: AutoUpdatingLabel, userPlayingDict: [String:Any]?) -> String?
        {
            return displayText
        }
    }
    
    override func spec()
    {
        describe("LabelUpdaterTests")
        {
            var user1:User = User()
            var delegate:TestDelegate = TestDelegate()
            var playerMock:PlayolaStationPlayerMock = PlayolaStationPlayerMock()
            
            beforeEach
            {
                user1 = User(id: "bobsUserID", displayName: "Bob")
                delegate = TestDelegate()
                playerMock = PlayolaStationPlayerMock()
                PlayolaStationPlayer.replaceSharedInstance(playerMock)
            }
            
            describe("StationPlayingDisplayNameLabel")
            {
                it ("updates")
                {
                    let label = StationPlayingDisplayNameLabel()
                    playerMock.userPlaying = user1
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stationChanged, object: nil, userInfo: ["userPlaying": user1])
                    expect(label.text).toEventually(equal("Bob"))
                }
                
                it ("sets its initial value if something is playing")
                {
                    playerMock.userPlaying = user1
                    
                    let label = StationPlayingDisplayNameLabel()
                    expect(label.text).toEventually(equal("Bob"))
                }
                
                it ("grabs alternate text from the protocol")
                {
                    let label = StationPlayingDisplayNameLabel()
                    delegate.displayText = "BILLYBOB"
                    label.autoUpdatingDelegate = delegate
                    expect(label.text).toEventually(equal("BILLYBOB"))
                    delegate.displayText = "BETTYSUE"
                    NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stationChanged, object: nil, userInfo: ["userPlaying": user1])
                    expect(label.text).toEventually(equal("BETTYSUE"))
                }
            }
        }
    }
}
