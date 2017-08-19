//
//  AudioBlockModel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

class AudioBlock
{
    var id:String?
    var __t:String?
    var duration:Int?
    var echonestID:String?
    var itunesID:String?
    var boo:Int?
    var eoi:Int?
    var eom:Int?
    var title:String?
    var artist:String?
    var album:String?
    var audioFileUrl:String?
    var key:String?
    var albumArtworkUrl:String?
    var albumArtworkUrlSmall:String?
    var trackViewUrl:String?
    var voiceTrackLocalUrl:URL?
    var isCommercialBlock:Bool = false
    
    //------------------------------------------------------------------------------
    
    init(audioBlockInfo:Dictionary<String,Any> = Dictionary())
    {
        id = audioBlockInfo["id"] as? String
        __t = audioBlockInfo["__t"] as? String
        duration = audioBlockInfo["duration"] as? Int
        echonestID = audioBlockInfo["echonestID"] as? String
        itunesID = audioBlockInfo["itunesID"] as? String
        boo = audioBlockInfo["boo"] as? Int
        eoi = audioBlockInfo["eoi"] as? Int
        eom = audioBlockInfo["eom"] as? Int
        title = audioBlockInfo["title"] as? String
        artist = audioBlockInfo["artist"] as? String
        album = audioBlockInfo["album"] as? String
        audioFileUrl = audioBlockInfo["audioFileUrl"] as? String
        key = audioBlockInfo["key"] as? String
        albumArtworkUrl = audioBlockInfo["albumArtworkUrl"] as? String
        albumArtworkUrlSmall = audioBlockInfo["albumArtworkUrlSmall"] as? String
        trackViewUrl = audioBlockInfo["trackViewUrl"] as? String
        
        if let isCommercialBlock = audioBlockInfo["isCommercialBlock"] as? Bool
        {
            self.isCommercialBlock = isCommercialBlock
        }
        
        //adjust audioFileUrl for no scheme included
        if let audioFileUrl = self.audioFileUrl
        {
            if (String(audioFileUrl.characters.prefix(2)) == "//")
            {
                self.audioFileUrl = "https:" + self.audioFileUrl!
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    init(original:AudioBlock)
    {
        self.id = original.id
        self.__t = original.__t
        self.duration = original.duration
        self.echonestID = original.echonestID
        self.itunesID = original.itunesID
        self.boo = original.boo
        self.eoi = original.eoi
        self.eom = original.eom
        self.title = original.title
        self.artist = original.artist
        self.album = original.album
        self.audioFileUrl = original.audioFileUrl
        self.key = original.key
        self.albumArtworkUrl = original.albumArtworkUrl
        self.albumArtworkUrlSmall = original.albumArtworkUrlSmall
        self.trackViewUrl = original.trackViewUrl
        self.isCommercialBlock = original.isCommercialBlock
        
        //adjust audioFileUrl for no scheme included
        if let audioFileUrl = self.audioFileUrl
        {
            if (String(audioFileUrl.characters.prefix(2)) == "//")
                
            {
                self.audioFileUrl = "https:" + self.audioFileUrl!
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    init(id:String?=nil,
         __t:String?=nil,
         duration:Int?=nil,
         echonestID:String?=nil,
         itunesID:String?=nil,
         boo:Int?=nil,
         eoi:Int?=nil,
         eom:Int?=nil,
         title:String?=nil,
         artist:String?=nil,
         album:String?=nil,
         audioFileUrl:String?=nil,
         key:String?=nil,
         albumArtworkUrl:String?=nil,
         albumArtworkUrlSmall:String?=nil,
         trackViewUrl:String?=nil,
         voiceTrackLocalUrl:URL?=nil,
         isCommercialBlock:Bool=false)
    {
        self.id = id
        self.__t = __t
        self.duration = duration
        self.echonestID = echonestID
        self.itunesID = itunesID
        self.boo = boo
        self.eoi = eoi
        self.eom = eom
        self.title = title
        self.artist = artist
        self.album = album
        self.audioFileUrl = audioFileUrl
        self.key = key
        self.albumArtworkUrl = albumArtworkUrl
        self.albumArtworkUrlSmall = albumArtworkUrlSmall
        self.trackViewUrl = trackViewUrl
        self.voiceTrackLocalUrl = voiceTrackLocalUrl
        self.isCommercialBlock = isCommercialBlock
        
        //adjust audioFileUrl for no scheme included
        if let audioFileUrl = self.audioFileUrl
        {
            if (String(audioFileUrl.characters.prefix(2)) == "//")
            {
                self.audioFileUrl = "https:" + self.audioFileUrl!
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func copy() -> AudioBlock
    {
        return AudioBlock(original: self)
    }
}