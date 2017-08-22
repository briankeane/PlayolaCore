//
//  SpinModel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class Spin
{
    var id:String?
    var isCommercialBlock:Bool?
    var playlistPosition:Int?
    var audioBlock:AudioBlock?
    var audioBlockID:String?
    var userID: String?
    var airtime: Date?
    var endTime: Date?
    
    //------------------------------------------------------------------------------
    
    init(spinInfo:Dictionary<String,Any>, DateHandler:DateHandlerService = DateHandlerService.sharedInstance())
    {
        id = spinInfo["id"] as? String
        if let _ = spinInfo["isCommercialBlock"]
        {
            isCommercialBlock = spinInfo["isCommercialBlock"] as? Bool
        }
        else
        {
            isCommercialBlock = false
        }
        
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
    
    init(original:Spin)
    {
        self.id = original.id
        self.isCommercialBlock = original.isCommercialBlock
        self.playlistPosition = original.playlistPosition
        self.audioBlock = original.audioBlock?.copy()
        self.userID = original.userID
        self.airtime = original.airtime
    }
    
    //------------------------------------------------------------------------------
    
    init(id:String? = nil, isCommercialBlock:Bool? = nil, playlistPosition:Int? = nil, audioBlock:AudioBlock? = nil, audioBlockID:String? = nil, userID:String? = nil, airtime:Date? = nil, endTime:Date? = nil)
    {
        self.id = id
        self.isCommercialBlock = isCommercialBlock
        self.playlistPosition = playlistPosition
        self.audioBlock = audioBlock
        self.audioBlockID = audioBlockID
        self.userID = userID
        self.airtime = airtime
        self.endTime = endTime
    }
    
    //------------------------------------------------------------------------------
    
    func copy() -> Spin
    {
        return Spin(original: self)
    }
    
    // -----------------------------------------------------------------------------
    //                          func isPlaying
    // -----------------------------------------------------------------------------
    /// returns true if the current time is between airtime and endTime
    ///
    /// ----------------------------------------------------------------------------
    func isPlaying() -> Bool
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
}
