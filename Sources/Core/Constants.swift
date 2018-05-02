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
    public static let signInBegan:Notification.Name! = Notification.Name(rawValue: "kPlyaolaSignInBegan")
    public static let currentUserUpdated:Notification.Name! = Notification.Name("kPlayolaCurrentUserUpdated")
    public static let userUpdated:Notification.Name! = Notification.Name(rawValue: "kPlayolaUserUpdated")
    public static let schedulerRefreshedPlaylist:Notification.Name! = Notification.Name(rawValue: "kPlayolaSchedulerRefreshedPlaylist")
    public static let schedulerNowPlayingAdvanced:Notification.Name! = Notification.Name(rawValue: "kPlayolaSchedulerNowPlayingAdvanced")
    public static let currentUserPlaylistAdvanced:Notification.Name! = Notification.Name(rawValue: "kPlayolaCurrentUserPlaylistAdvanced")
    public static let favoritesUpdated:Notification.Name! = Notification.Name(rawValue: "kPlayolaPresetsUpdated")
    public static let rotationItemsCollectionUpdated:Notification.Name! = Notification.Name(rawValue: "kPlayolaRotationItemsCollectionUpdated")
    public static let commonUserListUpdated:Notification.Name! = Notification.Name(rawValue: "kPlayolaCommonUserListUpdated")
    public static let stationStarted:Notification.Name! = Notification.Name(rawValue: "kPlayolaStationStarted")
    public static let playlistViewedAtAirtime:Notification.Name! = Notification.Name(rawValue: "kPlayolaPlaylistViewedAtAirtime")
    public static let playlistShuffled:Notification.Name! = Notification.Name(rawValue: "kPlayolaPlaylistShuffled")
    
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

public enum EnvironmentType:String {
    case development = "local"
    case staging = "staging"
    case production = "production"
}

public class PlayolaConstants {
    public static var environment:EnvironmentType {
        get {
            // default environments:
            // if in simulator: .development
            // otherwise:
            if (UserDefaults.standard.string(forKey: "playolaEnvironment")  == nil)
            {
                // default to development in simulator
                #if (arch(i386) || arch(x86_64)) && os(iOS)   // simulator
                    UserDefaults.standard.set(EnvironmentType.development.rawValue, forKey: "playolaEnvironment")
                #else
                    UserDefaults.standard.set(EnvironmentType.production.rawValue, forKey: "playolaEnvironment")
                #endif
            }
            return EnvironmentType(rawValue: UserDefaults.standard.string(forKey: "playolaEnvironment")!)!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "playolaEnvironment")
        }
    }
    
    public static var HOST_NAME:String {
        get {
            switch PlayolaConstants.environment {
            case .production:
                return "api.playola.fm"
            case .development:
                return "127.0.0.1:10111"
            case .staging:
                return "api-staging.playola.fm"
            }
        }
    }
    public static var BASE_URL:String {
        get {
            switch PlayolaConstants.environment {
            case .production, .staging:
                return "https://\(HOST_NAME)"
            case .development:
                return "http://\(HOST_NAME)"
            }
        }
    }
    public static var S3_PROFILE_IMAGES_BUCKET:String {
        get {
            switch PlayolaConstants.environment {
            case .production:
                return "playolaprofileimages"
            case .staging:
                return "playolaprofileimages"
            case .development:
                return "playolaprofileimagesdevelopment"
            }
        }
    }
    
    /// song bin minimums
    public static let SONG_BIN_MINIMUMS:[String:Int] = ["heavy": 20,
                                                        "medium": 30,
                                                        "light": 40]
    
    /// the number of seconds from now when station editing can begins.
    public static let LOCKED_SECONDS_OF_PRELOAD = 180
}
