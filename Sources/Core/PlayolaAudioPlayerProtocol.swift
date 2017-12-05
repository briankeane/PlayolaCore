//
//  PlayolaAudioPlayerProtocol.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 11/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import AudioKit

// ----------------------------------------------------------------------------
//                           protocol PlayolaAudioPlayer
// -----------------------------------------------------------------------------
/**
 Interface for a playola audio player.
 */
@objc public protocol PlayolaAudioPlayer
{
    // ----------------------------------------------------------------------------
    //                           func loadAudio
    // -----------------------------------------------------------------------------
    /**
     Loads the audio into the queue for scheduling.
     
     - parameters:
        - audioFileURL: `URL` - the local url of the file to play
        - startTime: `Date` - the time when playing should begin.  If in the past, the spin will begin at the appropriate seek point.
        - beginFadeOutTime: `Date` - The time when the spin should begin fading out
        - spinInfo: `[String:Any]` - a dictionary to be broadcast with any notifications regarding this spin.  (Usually used to store title, artist, etc.)
     */
    func loadAudio(audioFileURL:URL, startTime: Date, beginFadeOutTime: Date, spinInfo:[String:Any])
    
    // -----------------------------------------------------------------------------
    //                         func getOutputNode
    // -----------------------------------------------------------------------------
    /**
        returns an AudioKit audio node for output.
     
     TODO: -- figure out how to un-audioKit-ize this
    */
    func getOutputNode() -> AKNode
    
    // -----------------------------------------------------------------------------
    //                           func stop
    // -----------------------------------------------------------------------------
    /**
     cleanly stops the audio player
     
     TODO: -- figure out how to un-audioKit-ize this
     */
    func stop()
    
    // -----------------------------------------------------------------------------
    //                          func isPlaying
    // -----------------------------------------------------------------------------
    /**
        tells whether the station is currently playing... returns false if loading
 
        - returns:
            `Bool` - true if the station is playing
    */
    func isPlaying() -> Bool
    
    // -----------------------------------------------------------------------------
    //                          func isQueued
    // -----------------------------------------------------------------------------
    /**
        tells whether a localURL is queued or not.
 
        - parameters:
            - localURL: `localURL` - the localURL of the audioFile to check for
 
        - returns:
            `BOOL` - true if the localFile has already been scheduled
    */
    func isQueued(localFileURL:URL) -> Bool
}
