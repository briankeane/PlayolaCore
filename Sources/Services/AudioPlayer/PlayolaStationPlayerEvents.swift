//
//  PlayolaStationPlayerEvents.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

struct PlayolaStationPlayerEvents
{
    static let startedPlayingStation     =   Notification.Name(rawValue: "PSPStartedPlayingStation")
    static let stoppedPlayingStation     =   Notification.Name(rawValue: "PSPStoppedPlayingStation")
    static let startedLoadingStation     =   Notification.Name(rawValue: "PSPStartedLoadingStation")
    static let loadingStationProgress    =   Notification.Name(rawValue: "PSPLoadingStationProgress")
    static let finishedLoadingStation    =   Notification.Name(rawValue: "PSPFinishedLoadingStation")
}
