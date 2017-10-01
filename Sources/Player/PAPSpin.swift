//
//  PAPSpin.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import AudioKit

class PAPSpin
{
    var fadeOutTimer:Timer?
    var audioFileURL:URL!
    var player:AKAudioPlayer!
    var playerSet:Bool = false
    var beginFadeOutTime:Date
    var startTime:Date
    var spinInfo:[String:Any]
    
    //------------------------------------------------------------------------------
    
    init(audioFileURL:URL, player:AKAudioPlayer!, startTime:Date, beginFadeOutTime:Date,spinInfo:[String:Any]=[:])
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
        do
        {
            let file = try AKAudioFile(forReading: self.audioFileURL)
            try self.player.replace(file: file)
        }
        catch let err
        {
            print("error loading file in papSpin: \(err.localizedDescription)")
        }
    }
    
    //------------------------------------------------------------------------------
    
    func isPlaying() -> Bool
    {
        return (Date().isAfter(self.startTime) && Date().isBefore(self.beginFadeOutTime))
    }
}
