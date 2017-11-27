//
//  PlayolaAudioPlayerProtocol.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 11/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

// ----------------------------------------------------------------------------
//                           protocol PlayolaAudioPlayer
// -----------------------------------------------------------------------------
/**
 Interface for a playola audio player.
 */
protocol PlayolaAudioPlayer
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
    open func loadAudio(audioFileURL:URL, startTime: Date, beginFadeOutTime: Date, spinInfo:[String:Any])
    
    // -----------------------------------------------------------------------------
    //                         func getOutputNode
    // -----------------------------------------------------------------------------
    /**
        returns an AudioKit audio node for output.
     
     TODO: -- figure out how to un-audioKit-ize this
    */
    open func getOutputNode() -> AKNode
    
    // -----------------------------------------------------------------------------
    //                           func stop
    // -----------------------------------------------------------------------------
    /**
     cleanly stops the audio player
     
     TODO: -- figure out how to un-audioKit-ize this
     */
    open func stop()
    
    // -----------------------------------------------------------------------------
    //                          func isPlaying
    // -----------------------------------------------------------------------------
    /**
        tells whether the station is currently playing... returns false if loading
 
        - returns:
            `Bool` - true if the station is playing
    */
    open func isPlaying() -> Bool
}
