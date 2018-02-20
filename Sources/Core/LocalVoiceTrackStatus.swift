//
//  LocalVoiceTrackStatus.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/15/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation

public enum LocalVoiceTrackStatus:Int
{
    case uploading = 100
    case processing = 200
    case completed = 300
    case failed = 400
}
