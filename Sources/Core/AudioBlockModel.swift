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
import SwiftyJSON

open class AudioBlock:NSObject
{
    public var id:String?
    public var __t:AudioBlockType?
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
    public var spotifyID:String?
    public var localVoiceTrackStatus:LocalVoiceTrackStatus?
    
    //------------------------------------------------------------------------------
    
    public init(audioBlockInfo:[String:Any] = Dictionary())
    {
        super.init()
        id = audioBlockInfo["id"] as? String
        if let __tString = audioBlockInfo["__t"] as? String
        {
            __t = AudioBlockType(rawValue: __tString)
        }
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
        spotifyID = audioBlockInfo["spotifyID"] as? String
    }
    
    public init(json:JSON)
    {
        super.init()
        id = json["id"].string
        if let __tString = json["__t"].string
        {
            __t = AudioBlockType(rawValue: __tString)
        }
        duration = json["duration"].int
        echonestID = json["echonestID"].string
        itunesID = json["itunesID"].string
        boo = json["boo"].int
        eoi = json["eoi"].int
        eom = json["eom"].int
        title = json["title"].string
        artist = json["artist"].string
        album = json["album"].string
        audioFileUrl = URL(stringOptional: self.addSchemeIfNecessaryTo(urlString: json["audioFileUrl"].string))
        key = json["key"].string
        albumArtworkUrl = URL(stringOptional: json["albumArtworkUrl"].string)
        albumArtworkUrlSmall = URL(stringOptional: json["albumArtworkUrlSmall"].string)
        trackViewUrl = URL(stringOptional: json["trackViewUrl"].string)
        spotifyID = json["spotifyID"].string
    }
    
    //------------------------------------------------------------------------------
    
    public init(original:AudioBlock)
    {
        super.init()
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
        self.audioFileUrl = original.audioFileUrl
        self.spotifyID = original.spotifyID
    }
    
    //------------------------------------------------------------------------------
    
    public init(id:String?=nil,
         __t:AudioBlockType?=nil,
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
         spotifyID:String?=nil)
    {
        super.init()
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
        self.spotifyID = spotifyID
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
                "key": self.key as Any,
                "__t": self.__t as Any,
                "spotifyID": self.spotifyID as Any
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
