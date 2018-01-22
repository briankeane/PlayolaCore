//
//  PAPSpin.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

open class PAPSpin
{
    open var fadeOutTimer:Timer?
    open var audioFileURL:URL!
    open var player:Player!
    open var playerSet:Bool = false
    open var beginFadeOutTime:Date
    open var startTime:Date
    open var spinInfo:[String:Any]
    
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
    
    open func loadPlayer()
    {
        player.loadFile(with: self.audioFileURL)
    }
    
    //------------------------------------------------------------------------------
    
    open func isPlaying() -> Bool
    {
        return (Date().isAfter(self.startTime) && Date().isBefore(self.beginFadeOutTime))
    }
}
