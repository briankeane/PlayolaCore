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
    public var profileImageUrl:String?
    public var profileImageUrlSmall:String?
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
    
    init(userInfo:NSDictionary)
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
        profileImageUrl = userInfo["profileImageUrl"] as? String
        profileImageUrlSmall = userInfo["profileImageUrlSmall"] as? String
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
        
        
        //adjust profileImageUrl for no scheme included
        if let _ = self.profileImageUrl
        {
            if (String(self.profileImageUrl!.characters.prefix(2)) == "//")
            {
                self.profileImageUrl = "https:" + self.profileImageUrl!
            }
        }
    }
    
    init(original:User)
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
    
    
    
    //------------------------------------------------------------------------------
    
    deinit
    {
        self.advanceTimer?.invalidate()
    }
    
    //------------------------------------------------------------------------------
    
    func replaceProgram(_ program:Program?)
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
    
    func copy() -> User
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
    
    func hasRole(_ roleToCheck:PlayolaUserRole) -> Bool
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
    
    func hasInitializedStation() -> Bool
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
    
    func startAutoUpdating()
    {
        self.refresher = PlayolaProgramRefresher(user: self)
    }
    
    //------------------------------------------------------------------------------
    
    func endAutoUpdating()
    {
        self.refresher = nil
    }
}
