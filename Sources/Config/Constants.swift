//
//  Constants.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct PlayolaEvents {
    // seen by everyone
    public static let loggedOut:Notification.Name! = Notification.Name(rawValue: "kPlayolaLoggedOut")
    public static let loggedIn:Notification.Name! = Notification.Name(rawValue: "kPlayolaLoggedIn")
    public static let currentUserUpdated:Notification.Name! = Notification.Name("kPlayolaCurrentUserUpdated")
    public static let userUpdated:Notification.Name! = Notification.Name(rawValue: "kPlayolaUserUpdated")
    
    // seen by Playola only
    static let getCurrentUserReceived:Notification.Name! = Notification.Name(rawValue: "kPlayolaGetMeReceived")
    static let userUpdateRequested:Notification.Name! = Notification.Name(rawValue: "kPlayolaUserUpdateRequested")
    
}

enum PlayolaUserRole:Int {
    case guest = 0
    case user = 1
    case admin = 2
}

public struct PlayolaConstants {
    #if (arch(i386) || arch(x86_64)) && os(iOS)  // simulator
    static let HOST_NAME = "api.playola.fm"
    static let S3_SONGS_BUCKET = "playolasongsdevelopment"
    static let S3_COMMERCIAL_BLOCKS_BUCKET = "playolacommercialblocks"
    static let S3_PROCESSED_SONGS_BUCKET = "playolaprocessedsongsdevelopment"
    static let S3_PROFILE_IMAGES_BUCKET = "playolaprofileimagesdevelopment"
    #else
    // device
    static let HOST_NAME = "api.playola.fm"
    static let S3_SONGS_BUCKET = "playolasongs"
    static let S3_PROCESSED_SONGS_BUCKET = "playolaprocessedsongs"
    static let S3_COMMERCIAL_BLOCKS_BUCKET = "playolacommercialblocks"
    static let S3_PROFILE_IMAGES_BUCKET = "playolaprofileimages"
    #endif
    
    public static let BASE_URL = "https://\(HOST_NAME)"
    
    /// the number of seconds from now when station editing can begins.
    public static let LOCKED_SECONDS_OF_PRELOAD = 180
}
