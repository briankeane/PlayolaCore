//  SpotifyTrack.swift
//  playolaCore
//
//  Created by Brian D Keane on 12/9/15.
//  Copyright © 2015 Brian D Keane. All rights reserved.
//

import Alamofire
import SwiftyJSON
open class SpotifyTrack:AudioBlock
{
    public var artistID:String?
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
        super.init()
        self.__t = .spotifyTrack
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
        super.init()
        self.__t = .spotifyTrack
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
            if let urlString = self.albumImagesData?[0]["url"].string
            {
                self.albumArtworkUrl = URL(string: urlString)
            }
        }
        
        if let popularity = JSON["popularity"].int
        {
            self.popularity = popularity
        }
    }
    
    public static func removeDuplicatesFromList(tracks:[SpotifyTrack]) -> [SpotifyTrack]
    {
        var exists = Set<String>()
        var uniqueTracks:Array<SpotifyTrack> = Array()
        for track in tracks
        {
            if let trackID = track.spotifyID
            {
                if (!exists.contains(trackID))
                {
                    uniqueTracks.append(track)
                    exists.insert(trackID)
                }
            }
        }
        return uniqueTracks
    }
}
