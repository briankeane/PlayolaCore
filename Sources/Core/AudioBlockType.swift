//
//  AudioBlockType.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 1/9/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation

public enum AudioBlockType:String
{
    case commercialBlock = "CommercialBlock"
    case voiceTrack = "Commentary"
    case localVoiceTrack = "LocalVoiceTrack"
    case song = "Song"
    case playolaFailedToAcquire = "PlayolaFailedToAcquire"
    case spotifyTrack = "SpotifyTrack"
}
