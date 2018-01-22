//
//  Constants.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct PlayolaEvents
{
    // seen by everyone
    public static let signedOut:Notification.Name! = Notification.Name(rawValue: "kPlayolaSignedOut")
    
    // broadcast by the currentUserInfoService
    /// userInfo: ["user": the current logged in User"]
    public static let signedIn:Notification.Name! = Notification.Name(rawValue: "kPlayolaSignedIn")
    public static let currentUserUpdated:Notification.Name! = Notification.Name("kPlayolaCurrentUserUpdated")
    public static let userUpdated:Notification.Name! = Notification.Name(rawValue: "kPlayolaUserUpdated")
    public static let schedulerRefreshedPlaylist:Notification.Name! = Notification.Name(rawValue: "kPlayolaSchedulerRefreshedPlaylist")
    public static let schedulerNowPlayingAdvanced:Notification.Name! = Notification.Name(rawValue: "kPlayolaSchedulerNowPlayingAdvanced")
    public static let currentUserPlaylistAdvanced:Notification.Name! = Notification.Name(rawValue: "kPlayolaCurrentUserPlaylistAdvanced")
    public static let presetsUpdated:Notification.Name! = Notification.Name(rawValue: "kPlayolaPresetsUpdated")
    
    // seen by Playola only
    static let getCurrentUserReceived:Notification.Name! = Notification.Name(rawValue: "kPlayolaGetMeReceived")
    static let userUpdateRequested:Notification.Name! = Notification.Name(rawValue: "kPlayolaUserUpdateRequested")
    static let accessTokenReceived:Notification.Name! = Notification.Name(rawValue: "kPlayolaAccessTokenReceived")
    static let currentUserPresetsReceived:Notification.Name! = Notification.Name(rawValue: "kPlayolaCurrentUserPresetsReceived")
    
    
    public static let nowPlayingAdvanced:Notification.Name! = Notification.Name("kNotification.Name")
    
}

public enum PlayolaUserRole:Int {
    case guest = 0
    case user = 1
    case admin = 2
}

public struct PlayolaConstants {
    #if (arch(i386) || arch(x86_64)) && os(iOS)  // simulator
    
//    // --------- USE THESE FOR DEV SERVER --------  //
    public static let HOST_NAME = "127.0.0.1:9000"
    public static let BASE_URL = "http://\(HOST_NAME)"
    public static let S3_SONGS_BUCKET = "playolasongsdevelopment"
    public static let S3_COMMERCIAL_BLOCKS_BUCKET = "playolacommercialblocks"
    public static let S3_PROCESSED_SONGS_BUCKET = "playolaprocessedsongsdevelopment"
    public static let S3_PROFILE_IMAGES_BUCKET = "playolaprofileimagesdevelopment"
    
//     --------- USE THESE FOR PRODUCTION SERVER --------  //
//    public static let HOST_NAME = "api.playola.fm"
//    public static let S3_SONGS_BUCKET = "playolasongs"
//    public static let S3_PROCESSED_SONGS_BUCKET = "playolaprocessedsongs"
//    public static let S3_COMMERCIAL_BLOCKS_BUCKET = "playolacommercialblocks"
//    public static let S3_PROFILE_IMAGES_BUCKET = "playolaprofileimages"
//    public static let BASE_URL = "https://\(HOST_NAME)"
    
    
    #else
    // device
    public static let HOST_NAME = "api.playola.fm"
    public static let S3_SONGS_BUCKET = "playolasongs"
    public static let S3_PROCESSED_SONGS_BUCKET = "playolaprocessedsongs"
    public static let S3_COMMERCIAL_BLOCKS_BUCKET = "playolacommercialblocks"
    public static let S3_PROFILE_IMAGES_BUCKET = "playolaprofileimages"
    public static let BASE_URL = "https://\(HOST_NAME)"
    #endif
    
    
    /// song bin minimums
    public static let SONG_BIN_MINIMUMS:[String:Int] = ["heavy": 20,
                                                        "medium": 30,
                                                        "light": 40]
    
    /// the number of seconds from now when station editing can begins.
    public static let LOCKED_SECONDS_OF_PRELOAD = 180
}
