//
//  RotationItemsCollection.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct RotationItemsCollection
{
    public var rotationItems: [RotationItem] = Array() {
        didSet
        {
            // create searchables along with the array
            self.rotationItemsByID = Dictionary()
            self.rotationItemsBySpotifyID = Dictionary()
            for rotationItem in rotationItems
            {
                self.rotationItemsByID[rotationItem.id] = rotationItem
                if let spotifyID = rotationItem.song.spotifyID
                {
                    self.rotationItemsBySpotifyID[spotifyID] = rotationItem
                }
                if let songID = rotationItem.song.id
                {
                    self.rotationItemsBySongID[songID] = rotationItem
                }
            }
        }
    }
    
    public var rotationItemsByID:[String:RotationItem] = Dictionary()
    public var rotationItemsBySpotifyID:[String:RotationItem] = Dictionary()
    public var rotationItemsBySongID:[String:RotationItem] = Dictionary()
    
    //------------------------------------------------------------------------------
    
    public init(rawRotationItems: [String:[[String:Any]]])
    {
        // allows didSet to be called
        defer { self.refresh(rawRotationItems) }
    }
    
    //------------------------------------------------------------------------------
    
    public init(rotationItems:[RotationItem])
    {
        defer { self.rotationItems = rotationItems }
    }
    
    //------------------------------------------------------------------------------
    
    public init(rawRotationItemsArray: [[String:Any]])
    {
        defer { self.rotationItems = rawRotationItemsArray.map({ RotationItem(rawDictionary: $0) })
        }
    }
    
    //------------------------------------------------------------------------------
    
   public func listBins () -> [String]
    {
        var binNamesArray:Array<String> = []
        var binNamesDictionary:Dictionary<String,Bool> = Dictionary()
        for i in 0..<self.rotationItems.count
        {
            if (binNamesDictionary[rotationItems[i].bin] == nil)
            {
                binNamesDictionary[rotationItems[i].bin] = true
                binNamesArray.append(rotationItems[i].bin)
            }
        }
        return binNamesArray.sorted()
    }
    
    //------------------------------------------------------------------------------
    
    public func contains(rotationItemID:String?) -> Bool
    {
        return (self.getRotationItem(rotationItemID: rotationItemID) != nil)
    }
    
    //------------------------------------------------------------------------------
    
    public func contains(songID:String?) -> Bool
    {
        return (self.getRotationItem(songID: songID) != nil)
    }
    
    //------------------------------------------------------------------------------
    
    public func contains(spotifyID:String?) -> Bool
    {
        return (self.getRotationItem(spotifyID: spotifyID) != nil)
    }
    
    //------------------------------------------------------------------------------
    
    public func getRotationItem(spotifyID:String?) -> RotationItem?
    {
        if let spotifyID = spotifyID
        {
            return self.rotationItemsBySpotifyID[spotifyID]
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public func getRotationItem(songID:String?) -> RotationItem?
    {
        if let songID = songID
        {
            return self.rotationItemsBySongID[songID]
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public func getRotationItem(rotationItemID:String?) -> RotationItem?
    {
        if let rotationItemID = rotationItemID
        {
            return self.rotationItemsByID[rotationItemID]
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public func getAllItemsInBin(_ binName:String) -> Array<RotationItem>
    {
        var list:Array<RotationItem> = []
        
        for item in self.rotationItems
        {
            if (item.bin == binName)
            {
                list.append(item)
            }
        }
        return list
    }
    
    //------------------------------------------------------------------------------
    
    public func rotationItemIDFromSongID(_ songID:String) -> String?
    {
        for i in 0..<self.rotationItems.count
        {
            if self.rotationItems[i].song.id == songID
            {
                return rotationItems[i].id
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    public mutating func removeRotationItem(songID:String)
    {
        for i in 0..<self.rotationItems.count
        {
            if (self.rotationItems[i].song.id == songID)
            {
                self.rotationItems.remove(at: i)
                break
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    public mutating func refresh(_ rawRotationItems: Dictionary<String, Array<Dictionary<String,Any>>>)
    {
        for (_, bin) in rawRotationItems
        {
            for rawRotationItem in bin {
                rotationItems.append(RotationItem(rawDictionary: rawRotationItem))
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    public func asList(listOrder:RotationItemsListOrder = .artist) -> [RotationItem]
    {
        switch listOrder
        {
        case .artist:
            return self.rotationItemsSortedByArtist()
        case .title:
            return self.rotationItemsSortedByTitle()
        }
    }
    
    //------------------------------------------------------------------------------
    
    private func rotationItemsSortedByArtist() -> [RotationItem]
    {
        return rotationItems.sorted(by: { (itemA, itemB) -> Bool in
            if let artistA = itemA.song.artist, let artistB = itemB.song.artist
            {
                if (artistA == artistB)
                {
                    if let titleA = itemA.song.title, let titleB = itemB.song.title
                    {
                        return (titleA < titleB)
                    }
                }
                return (artistA < artistB)
            }
            return false
        })
    }
    
    //------------------------------------------------------------------------------
    
    private func rotationItemsSortedByTitle() -> [RotationItem]
    {
        return rotationItems.sorted(by: { (itemA, itemB) -> Bool in
            if let titleA = itemA.song.title, let titleB = itemB.song.title
            {
                if (titleA == titleB)
                {
                    if let artistA = itemA.song.artist, let artistB = itemB.song.artist
                    {
                        return (artistA < artistB)
                    }
                }
                return (titleA < titleB)
            }
            return false
        })
    }
    
    //------------------------------------------------------------------------------
    
    public func toRawRotationItemsDictionary() -> [String:[[String:Any]]]
    {
        var rawRotationItemsDict:[String:[[String:Any]]] = Dictionary()
        for rotationItem in self.rotationItems
        {
            if (rawRotationItemsDict[rotationItem.bin] == nil) {
                rawRotationItemsDict[rotationItem.bin] = Array()
            }
            rawRotationItemsDict[rotationItem.bin]?.append(rotationItem.toDictionary())
        }
        return rawRotationItemsDict
    }
}

public enum RotationItemsListOrder {
    case artist
    case title
}
