//  SpotifyTrack.swift
//  playolaCore
//
//  Created by Brian D Keane on 12/9/15.
//  Copyright © 2015 Brian D Keane. All rights reserved.
//

import Alamofire
import SwiftyJSON

open class SpotifyTrack
{
    public var spotifyID:String?
    public var duration:Int?
    public var title:String?
    public var artist:String?
    public var artistID:String?
    public var album:String?
    public var isrc:String?
    public var albumImagesData:JSON?
    public var popularity:Int?
    
    public init(spotifyID:String? = nil,
         duration:Int? = nil,
         title:String? = nil,
         artist:String? = nil,
         artistID:String? = nil,
         album:String? = nil,
         isrc:String? = nil,
         albumImagesData:JSON? = nil,
         popularity:Int? = nil)
    {
        self.spotifyID = spotifyID
        self.duration = duration
        self.title = title
        self.artist = artist
        self.artistID = artistID
        self.album = album
        self.isrc = isrc
        self.albumImagesData = albumImagesData
        self.popularity = popularity
    }
    
    public init(JSON:JSON)
    {
        if let album = JSON["album"]["name"].string
        {
            self.album = album
        }
        
        if let artistName = JSON["artists"][0]["name"].string
        {
            self.artist = artistName
            
        }
        
        if let artistID = JSON["artists"][0]["id"].string
        {
            self.artistID = artistID
        }
        
        if let title = JSON["name"].string
        {
            self.title = title
        }
        
        if let spotifyID = JSON["id"].string
        {
            self.spotifyID = spotifyID
        }
        
        if let duration = JSON["duration_ms"].int
        {
            self.duration = duration
        }
        
        if let isrc = JSON["external_ids"]["isrc"].string
        {
            self.isrc = isrc
        }
        
        if (JSON["album"]["images"].exists())
        {
            self.albumImagesData = JSON["album"]["images"]
        }
        if let popularity = JSON["popularity"].int
        {
            self.popularity = popularity
        }
    }
    
    //------------------------------------------------------------------------------
    
    func albumImageURLString() -> String?
    {
        if let albumImagesData = self.albumImagesData
        {
            return albumImagesData[0]["url"].string
        }
        return nil
    }
}
