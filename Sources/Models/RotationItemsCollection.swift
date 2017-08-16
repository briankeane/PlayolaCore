//
//  RotationItemsCollection.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

struct RotationItemsCollection
{
    var rotationItems: Array<RotationItem> = []
    
    //------------------------------------------------------------------------------
    
    init(rawRotationItems: Dictionary<String, Array<Dictionary<String, Any>>>)
    {
        self.refresh(rawRotationItems)
    }
    
    //------------------------------------------------------------------------------
    
    init(rotationItems:Array<RotationItem>)
    {
        self.rotationItems = rotationItems
    }
    
    //------------------------------------------------------------------------------
    
    func listBins () -> [String]
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
    
    func isInRotation(_ id:String?) -> Bool
    {
        if let _ = id
        {
            for i in 0..<self.rotationItems.count
            {
                if (rotationItems[i].song.id == id)
                {
                    return true
                }
            }
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    func getAllItemsInBin(_ binName:String) -> Array<RotationItem>
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
    
    func rotationItemIDFromSongID(_ songID:String) -> String?
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
    
    func getRotationItem(songID:String) -> RotationItem?
    {
        for item in self.rotationItems
        {
            if (item.song.id == songID)
            {
                return item
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    mutating func removeRotationItem(songID:String)
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
    
    mutating func refresh(_ rawRotationItems: Dictionary<String, Array<Dictionary<String,Any>>>)
    {
        for (_, bin) in rawRotationItems
        {
            for rawRotationItem in bin {
                rotationItems.append(RotationItem(rawDictionary: rawRotationItem))
            }
        }
    }
    
}
