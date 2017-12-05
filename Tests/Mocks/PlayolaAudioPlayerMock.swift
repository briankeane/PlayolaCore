//
//  PlayolaAudioPlayerMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import AudioKit

class PlayolaAudioPlayerMock:NSObject, PlayolaAudioPlayer {
    
    func getOutputNode() -> AKNode
    {
        return AKNode()
    }
    
    var shouldBePlaying:Bool = true
    func isPlaying() -> Bool
    {
        return self.shouldBePlaying
    }
    
    var shouldBeQueued:Bool = true
    func isQueued(localFileURL: URL) -> Bool
    {
        return self.shouldBeQueued
    }
    
    
    // just skip
    override init()
    {
        super.init()
    }
    
    var loadAudioCalledCount = 0
    var loadAudioCalledArgs:Array<[String:Any]> = []
    func loadAudio(audioFileURL: URL, startTime: Date, beginFadeOutTime: Date, spinInfo: [String : Any])
    {
        self.loadAudioCalledCount += 1
        self.loadAudioCalledArgs.append([
            
                                "audioFileURL": audioFileURL,
                                "startTime": startTime,
                                "beginFadeOutTime": beginFadeOutTime,
                                "spinInfo": spinInfo
                            ])
    }
    
    var stopCalledCount = 0
    func stop() {
        self.stopCalledCount += 1
    }
}
