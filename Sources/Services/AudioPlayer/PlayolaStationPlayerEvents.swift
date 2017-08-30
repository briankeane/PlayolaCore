//
//  PlayolaStationPlayerEvents.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct PlayolaStationPlayerEvents
{
    public static let startedPlayingStation     =   Notification.Name(rawValue: "PSPStartedPlayingStation")
    public static let stoppedPlayingStation     =   Notification.Name(rawValue: "PSPStoppedPlayingStation")
    public static let startedLoadingStation     =   Notification.Name(rawValue: "PSPStartedLoadingStation")
    public static let loadingStationProgress    =   Notification.Name(rawValue: "PSPLoadingStationProgress")
    public static let finishedLoadingStation    =   Notification.Name(rawValue: "PSPFinishedLoadingStation")
    public static let nowPlayingChanged         =   Notification.Name(rawValue: "PSPNowPlayingChanged")
}
