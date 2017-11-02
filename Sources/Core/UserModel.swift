//
//  UserModel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class User
{
    public var displayName:String?
    public var twitterUID:String?
    public var facebookUID:String?
    public var googleUID:String?
    public var instagramUID:String?
    public var email:String?
    public var birthYear:String?
    public var gender:String?
    public var zipcode:String?
    public var timezone:String?
    var role:PlayolaUserRole?
    public var lastCommercial:NSMutableDictionary?
    public var profileImageUrl:URL?
    public var profileImageUrlSmall:URL?
    public var id:String?
    public var secsOfCommercialPerHour:Int?
    public var dailyListenTimeMS:Int?
    public var dailyListenTimeCalculationDate:Date?
    public var program:Program?
    public var warnings:Array<String>?
    public var advanceTimer:Timer?
    public var deepLink:String?
    public var profileImageKey:String?
    public var bio:String?
    public var passwordExists:Bool?
    public var minListenersToReport:Int?=1
    public var deviceID:String?
    public var stationStatus:String?
    public var updatedAt:Date?
    
    var refresher:PlayolaProgramRefresher?
    var advancer:PlayolaProgramAutoAdvancer?
    
    /// an array of blocks to execute when the program's nowPlaying changes.
    fileprivate var onNowPlayingAdvancedBlocks:Array<((User)->Void)> = Array()
    
    public init(userInfo:NSDictionary)
    {
        displayName = userInfo["displayName"] as? String
        twitterUID = userInfo["twitterUID"] as? String
        facebookUID = userInfo["facebookUID"] as? String
        googleUID = userInfo["googleUID"] as? String
        instagramUID = userInfo["instagramUID"] as? String
        email = userInfo["email"] as? String
        birthYear = userInfo["birthYear"] as? String
        gender = userInfo["gender"] as? String
        zipcode = userInfo["zipcode"] as? String
        timezone = userInfo["timezone"] as? String
        self.setRole(userInfo["role"] as? String)
        deepLink = userInfo["deepLink"] as? String
        bio = userInfo["bio"] as? String
        passwordExists = userInfo["passwordExists"] as? Bool
        stationStatus = userInfo["stationStatus"] as? String
        
        if let rawDictionary = userInfo["lastCommercial"] as? NSDictionary
        {
            lastCommercial = NSMutableDictionary(dictionary: rawDictionary)
        }
        
        // default minListeners is 1
        if let minListeners = userInfo["minListenersToReport"] as? Int
        {
            self.minListenersToReport = minListeners
        }
        
        if let updatedAtString = userInfo["updatedAt"] as? String
        {
            self.updatedAt = Date(isoString: updatedAtString)
        }
        
        profileImageKey = userInfo["profileImageKey"] as? String
        
        //adjust profileImageUrl for no scheme included
        if var profileImageString = userInfo["profileImageUrl"] as? String
        {
            if (String(profileImageString.prefix(2)) == "//")
            {
                profileImageString = "https:" + profileImageString
            }
            self.profileImageUrl = URL(string: profileImageString)
        }
        
        
        profileImageUrlSmall = URL(stringOptional: userInfo["profileImageUrlSmall"] as? String)
        id = userInfo["id"] as? String
        secsOfCommercialPerHour = userInfo["secsOfCommercialPerHour"] as? Int
        dailyListenTimeMS = userInfo["dailyListenTimeMS"] as? Int
        dailyListenTimeCalculationDate = userInfo["dailyListenTimeCalculationDate"] as? Date
        deviceID = userInfo["deviceID"] as? String
        
        if let rawPlaylist = userInfo["playlist"] as? Array<Dictionary<String,AnyObject>>
        {
            if (rawPlaylist.count > 0)
            {
                program = Program(rawPlaylist: rawPlaylist )
            }
        }
        
        if let warnings = userInfo["warnings"] as? Array<String>
        {
            self.warnings = warnings
        }
        
        
        
    }
    
    public init(original:User)
    {
        self.displayName = original.displayName
        self.twitterUID = original.twitterUID
        self.facebookUID = original.facebookUID
        self.googleUID = original.googleUID
        self.instagramUID = original.instagramUID
        self.email = original.email
        self.birthYear = original.birthYear
        self.gender = original.gender
        self.zipcode = original.zipcode
        self.timezone = original.timezone
        self.role = original.role
        self.lastCommercial = original.lastCommercial
        self.profileImageUrl = original.profileImageUrl
        self.profileImageUrlSmall = original.profileImageUrlSmall
        self.profileImageKey = original.profileImageKey
        self.id = original.id
        self.secsOfCommercialPerHour = original.secsOfCommercialPerHour
        self.dailyListenTimeMS = original.dailyListenTimeMS
        self.dailyListenTimeCalculationDate = original.dailyListenTimeCalculationDate
        self.warnings = original.warnings
        self.deepLink = original.deepLink
        self.minListenersToReport = original.minListenersToReport
        self.bio = original.bio
        self.passwordExists = original.passwordExists
        self.deviceID = original.deviceID
        self.stationStatus = original.stationStatus
        if let minListeners = original.minListenersToReport
        {
            self.minListenersToReport = minListeners
        }
        self.program = original.program?.copy()
    }
    
    public init(id:String?=nil,
                displayName:String?=nil,
                twitterUID:String?=nil,
                facebookUID:String?=nil,
                googleUID:String?=nil,
                instagramUID:String?=nil,
                email:String?=nil,
                birthYear:String?=nil,
                gender:String?=nil,
                zipcode:String?=nil,
                timezone:String?=nil,
                role:PlayolaUserRole?=nil,
                lastCommercial:NSMutableDictionary?=nil,
                profileImageUrl:URL?=nil,
                profileImageUrlSmall:URL?=nil,
                secsOfCommercialPerHour:Int?=nil,
                dailyListenTimeMS:Int?=nil,
                dailyListenTimeCalculationDate:Date?=nil,
                program:Program?=nil,
                warnings:Array<String>?=nil,
                advanceTimer:Timer?=nil,
                deepLink:String?=nil,
                profileImageKey:String?=nil,
                bio:String?=nil,
                passwordExists:Bool?=nil,
                minListenersToReport:Int?=nil,
                deviceID:String?=nil,
                stationStatus:String?=nil,
                updatedAt:Date?=nil)
    {
        self.id = id
        self.displayName = displayName
        self.twitterUID = twitterUID
        self.facebookUID = facebookUID
        self.googleUID = googleUID
        self.instagramUID = instagramUID
        self.email = email
        self.birthYear = birthYear
        self.gender = gender
        self.zipcode = zipcode
        self.timezone = timezone
        self.role = role
        self.lastCommercial = lastCommercial
        self.profileImageUrl = profileImageUrl
        self.profileImageUrlSmall = profileImageUrlSmall
        self.profileImageKey = profileImageKey
        self.secsOfCommercialPerHour = secsOfCommercialPerHour
        self.dailyListenTimeMS = dailyListenTimeMS
        self.dailyListenTimeCalculationDate = dailyListenTimeCalculationDate
        self.warnings = warnings
        self.deepLink = deepLink
        self.minListenersToReport = minListenersToReport
        self.bio = bio
        self.passwordExists = passwordExists
        self.deviceID = deviceID
        self.stationStatus = stationStatus
        self.minListenersToReport = minListenersToReport
        self.program = program
    }
    
    //------------------------------------------------------------------------------
    
    deinit
    {
        self.advanceTimer?.invalidate()
    }
    
    //------------------------------------------------------------------------------
    
    public func replaceProgram(_ program:Program?)
    {
        self.program = program
    }
    
    //------------------------------------------------------------------------------
    
    fileprivate func setRole(_ roleString:String?)
    {
        if let roleString = roleString
        {
            switch roleString {
            case "admin":
                self.role = .admin
            case "user":
                self.role = .user
            default:
                self.role = .guest
            }
        }
        else
        {
            self.role = .guest
        }
    }
    //------------------------------------------------------------------------------
    
    public func copy() -> User
    {
        return User(original: self)
    }
    
    //------------------------------------------------------------------------------
    
    func prepareForIdle()
    {
        self.advanceTimer?.invalidate()
        print("preparing for Idle -- userModel")
    }
    
    //------------------------------------------------------------------------------
    
    public func hasRole(_ roleToCheck:PlayolaUserRole) -> Bool
    {
        if let userRole = self.role
        {
            if (userRole.rawValue >= roleToCheck.rawValue)
            {
                return true
            }
        }
        
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func hasInitializedStation() -> Bool
    {
        if let playlist = self.program?.playlist
        {
            if (playlist.count > 0)
            {
                return true
            }
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    public func startAutoUpdating()
    {
        self.refresher = PlayolaProgramRefresher(user: self)
    }
    
    //------------------------------------------------------------------------------
    
    public func endAutoUpdating()
    {
        self.refresher = nil
    }
    
    //------------------------------------------------------------------------------
    
    public func startAutoAdvancing()
    {
        if (self.advancer == nil)
        {
            self.advancer = PlayolaProgramAutoAdvancer(user: self)
        }
        else
        {
            puts("tried to double set")
        }
        self.advancer?.startAutoAdvancing()
    }
    
    func handleNowPlayingAdvanced()
    {
        for block in self.onNowPlayingAdvancedBlocks
        {
            block(self)
        }
    }
    
    func toDictionary() -> [String:Any]
    {
        return [
            "displayName": self.displayName as Any,
            "twitterUID": self.twitterUID as Any,
            "facebookUID": self.facebookUID as Any,
            "ggogleUID": self.googleUID as Any,
            "instagramUID": self.instagramUID as Any,
            "email": self.email as Any,
            "birthYear": self.birthYear as Any,
            "gender": self.gender as Any,
            "zipcode": self.zipcode as Any,
            "timezone": self.timezone as Any,
            "lastCommercial": self.lastCommercial as Any,
            "profileImageUrl": self.profileImageUrl as Any,
            "profileImageUrl": self.profileImageUrlSmall as Any,
            "profileImageKey":  self.profileImageKey as Any,
            "id": self.id as Any,
            "secsOfCommercialPerHour": self.secsOfCommercialPerHour as Any,
            "dailyListenTimeMS": self.dailyListenTimeMS as Any,
            "dailyListenTimeCalculationDate": self.dailyListenTimeCalculationDate as Any,
            "warnings": self.warnings as Any,
            "deepLink": self.deepLink as Any,
            "minListenersToReport": self.minListenersToReport as Any,
            "bio": self.bio as Any,
            "passwordExists": self.passwordExists as Any,
            "deviceID": self.deviceID as Any,
            "stationStatus": self.stationStatus as Any
        ]
    }
    
    // -----------------------------------------------------------------------------
    //                          func onNowPlayingAdvanced
    // -----------------------------------------------------------------------------
    /// stores a block to execute when nowPlaying advances.  
    /// If there is already a block, it the new completion block will be added 
    /// in addition to it.
    ///
    /// - parameters:
    ///     - onCompletionBlock: `(((User)->Void)!))` - a block to be
    ///                             executed upon completion of the download.  The
    ///                             block is passed the User who's program has just
    ///                             changed
    ///
    /// ----------------------------------------------------------------------------
    @discardableResult public func onNowPlayingAdvanced(_ block:((User?)->Void)!) -> User
    {
        self.onNowPlayingAdvancedBlocks.append(block)
        return self
    }
    
    // -----------------------------------------------------------------------------
    //                          func onNowPlayingAdvanced
    // -----------------------------------------------------------------------------
    /// clears nowPlayingAdvanced blocks
    ///
    ///
    /// ----------------------------------------------------------------------------
    @discardableResult public func clearOnNowPlayingAdvanced() -> User
    {
        self.onNowPlayingAdvancedBlocks = Array()
        return self
    }
}
