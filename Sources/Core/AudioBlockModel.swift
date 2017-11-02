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

open class AudioBlock
{
    public var id:String?
    public var __t:String?
    public var duration:Int?
    public var echonestID:String?
    public var itunesID:String?
    public var boo:Int?
    public var eoi:Int?
    public var eom:Int?
    public var title:String?
    public var artist:String?
    public var album:String?
    public var audioFileUrl:URL?
    public var key:String?
    public var albumArtworkUrl:URL?
    public var albumArtworkUrlSmall:URL?
    public var trackViewUrl:URL?
    public var voiceTrackLocalUrl:URL?
    public var isCommercialBlock:Bool = false
    
    //------------------------------------------------------------------------------
    
    public init(audioBlockInfo:Dictionary<String,Any> = Dictionary())
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
        audioFileUrl = URL(stringOptional: self.addSchemeIfNecessaryTo(urlString: audioBlockInfo["audioFileUrl"] as? String))
        key = audioBlockInfo["key"] as? String
        albumArtworkUrl = URL(stringOptional: audioBlockInfo["albumArtworkUrl"] as? String)
        albumArtworkUrlSmall = URL(stringOptional: audioBlockInfo["albumArtworkUrlSmall"] as? String)
        trackViewUrl = URL(stringOptional: audioBlockInfo["trackViewUrl"] as? String)
        
        if let isCommercialBlock = audioBlockInfo["isCommercialBlock"] as? Bool
        {
            self.isCommercialBlock = isCommercialBlock
        }
    }
    
    //------------------------------------------------------------------------------
    
    public init(original:AudioBlock)
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
        self.audioFileUrl = original.audioFileUrl
    }
    
    //------------------------------------------------------------------------------
    
    public init(id:String?=nil,
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
         audioFileUrl:URL?=nil,
         key:String?=nil,
         albumArtworkUrl:URL?=nil,
         albumArtworkUrlSmall:URL?=nil,
         trackViewUrl:URL?=nil,
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
    }
    
    //------------------------------------------------------------------------------
    
    public func toDictionary() -> Dictionary<String,Any>
    {
        return [
                "title": self.title as Any,
                "artist": self.artist as Any,
                "duration": self.duration as Any,
                "itunesID": self.itunesID as Any,
                "album": self.album as Any,
                "albumArtworkUrl": self.albumArtworkUrl as Any,
                "voiceTrackLocalUrl": self.voiceTrackLocalUrl as Any,
                "isCommercialBlock": self.isCommercialBlock as Any,
                "key": self.key as Any
                ]
    }
    
    func addSchemeIfNecessaryTo(urlString:String?) -> String?
    {
        if let urlString = urlString
        {
            if (String(urlString.prefix(2)) == "//")
            {
               return "https:\(urlString)"
            }
        }
        return urlString
    }
    
    //------------------------------------------------------------------------------
    
    public func copy() -> AudioBlock
    {
        return AudioBlock(original: self)
    }
}
