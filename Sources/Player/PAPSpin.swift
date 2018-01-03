//
//  PAPSpin.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PAPSpin
{
    var fadeOutTimer:Timer?
    var audioFileURL:URL!
    var player:Player!
    var playerSet:Bool = false
    var beginFadeOutTime:Date
    var startTime:Date
    var spinInfo:[String:Any]
    
    //------------------------------------------------------------------------------
    
    init(audioFileURL:URL, player:Player!, startTime:Date, beginFadeOutTime:Date,spinInfo:[String:Any]=[:])
    {
        self.audioFileURL = audioFileURL
        self.player = player
        self.startTime = startTime
        self.beginFadeOutTime = beginFadeOutTime
        self.spinInfo = spinInfo
        self.loadPlayer()
    }
    
    //------------------------------------------------------------------------------
    
    func loadPlayer()
    {
        player.loadFile(with: self.audioFileURL)
    }
    
    //------------------------------------------------------------------------------
    
    func isPlaying() -> Bool
    {
        return (Date().isAfter(self.startTime) && Date().isBefore(self.beginFadeOutTime))
    }
}
