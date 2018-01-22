//
//  SpinModel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class Spin
{
    public var id:String?
    public var playlistPosition:Int?
    public var audioBlock:AudioBlock?
    public var audioBlockID:String?
    public var userID: String?
    public var airtime: Date?
    public var endTime: Date?
    
    //------------------------------------------------------------------------------
    
    public init(spinInfo:Dictionary<String,Any>, DateHandler:DateHandlerService = DateHandlerService.sharedInstance())
    {
        id = spinInfo["id"] as? String
        
        playlistPosition = spinInfo["playlistPosition"] as? Int
        
        if let audioBlockDict = spinInfo["audioBlock"] as? Dictionary<String,AnyObject>
        {
            audioBlock = AudioBlock(audioBlockInfo: audioBlockDict)
        }
        else if let passedAudioBlock = spinInfo["audioBlock"] as? AudioBlock
        {
            audioBlock = passedAudioBlock
        }
        
        audioBlockID = spinInfo["audioBlockID"] as? String
        userID = spinInfo["userID"] as? String
        if let airtimeString = spinInfo["airtime"] as? String
        {
            self.airtime = Date(isoString: airtimeString)
        }
    }
    
    //------------------------------------------------------------------------------
    
    public init(original:Spin)
    {
        self.id = original.id
        self.playlistPosition = original.playlistPosition
        self.audioBlock = original.audioBlock?.copy()
        self.userID = original.userID
        self.airtime = original.airtime
    }
    
    //------------------------------------------------------------------------------
    
    public init(id:String?=nil,
                isCommercialBlock:Bool?=nil,
                playlistPosition:Int? = nil, audioBlock:AudioBlock? = nil, audioBlockID:String? = nil, userID:String? = nil, airtime:Date? = nil, endTime:Date? = nil)
    {
        self.id = id
        self.playlistPosition = playlistPosition
        self.audioBlock = audioBlock
        self.audioBlockID = audioBlockID
        self.userID = userID
        self.airtime = airtime
        self.endTime = endTime
    }
    
    //------------------------------------------------------------------------------
    
    public func copy() -> Spin
    {
        return Spin(original: self)
    }
    
    // -----------------------------------------------------------------------------
    //                          func isPlaying
    // -----------------------------------------------------------------------------
    /// returns true if the current time is between airtime and endTime
    ///
    /// ----------------------------------------------------------------------------
    public func isPlaying() -> Bool
    {
        if let airtime = self.airtime
        {
            if let eom = self.audioBlock?.eom
            {
                let endTime = airtime.addMilliseconds(eom)
                let dateHandler = DateHandlerService.sharedInstance()
                if (dateHandler.now().isAfter(airtime) && dateHandler.now().isBefore(endTime))
                {
                    return true
                }
            }
        }
        return false
    }
    
    // -----------------------------------------------------------------------------
    //                          func eomTime
    // -----------------------------------------------------------------------------
    /// returns true if the current time is between airtime and endTime
    ///
    /// ----------------------------------------------------------------------------
    public func eomTime() -> Date?
    {
        if let airtime = self.airtime
        {
            if let eom = self.audioBlock?.eom
            {
                return airtime.addMilliseconds(eom)
            }
        }
        return nil
    }
    
    public func isCommercialBlock() -> Bool
    {
        return (self.audioBlock?.__t == AudioBlockType.commercialBlock)
    }
}
