//
//  PAPEvents.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

struct PAPEvents
{
    static let playerStarted        =   Notification.Name(rawValue: "PAPPlayerStarted")
    static let playerStopped        =   Notification.Name(rawValue: "PAPPlayerStopped")
    static let nowPlayingChanged    =   Notification.Name(rawValue: "PAPNowPlayingChanged")
}
