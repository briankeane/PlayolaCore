//
//  PlayolaStationPlayerMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PlayolaStationPlayerMock:PlayolaStationPlayer
{    
    var nowPlayingSpin:Spin?
    override func nowPlaying() -> Spin?
    {
        return nowPlayingSpin
    }
    
    var shouldBePlaying:Bool = true
    override func isPlaying() -> Bool
    {
        return shouldBePlaying
    }
}
