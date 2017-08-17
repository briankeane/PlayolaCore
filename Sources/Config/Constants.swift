//
//  Constants.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct PlayolaEvents {
    static let loggedOut:Notification.Name! = Notification.Name(rawValue: "kPlayolaLoggedOut")
}

enum PlayolaUserRole:Int {
    case guest = 0
    case user = 1
    case admin = 2
}

public struct PlayolaConstants {
    static let BASE_URL = "https://api.playola.fm"
}
