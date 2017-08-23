//
//  PAPEvents.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct PAPEvents
{
    public static let playerStarted        =   Notification.Name(rawValue: "PAPPlayerStarted")
    public static let playerStopped        =   Notification.Name(rawValue: "PAPPlayerStopped")
    public static let nowPlayingChanged    =   Notification.Name(rawValue: "PAPNowPlayingChanged")
}
