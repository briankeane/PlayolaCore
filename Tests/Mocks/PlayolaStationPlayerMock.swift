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
    override init()
    {
        // do nothing
        print("hi")
    }
    
    var nowPlayingSpin:Spin?
    override func nowPlaying() -> Spin?
    {
        return nowPlayingSpin
    }
}
