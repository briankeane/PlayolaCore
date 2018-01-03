//
//  PlaylistRefreshInstructions.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 12/25/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

open class PlaylistRefreshInstructions: NSObject
{
    open var fullReload:Bool! = false
    open var reloadIndexes:[Int]! = Array()
    open var removeItemAtIndex:Int? = nil
    
    public convenience init(oldPlaylist:[Spin]?, newPlaylist:[Spin]?)
    {
        // if both playlists are nil
        if ((oldPlaylist == nil) && (newPlaylist == nil))
        {
            self.init(fullReload: false)
        }
        
            
        // One playlist is nil
        else if ((oldPlaylist == nil) || (newPlaylist == nil))
        {
            self.init(fullReload: true)
        }
            
        // playlists are identical
        else if (PlaylistRefreshInstructions.areSame(playlist1: oldPlaylist!, playlist2: newPlaylist!) == true)
        {
            //if reload =
            self.init(fullReload: false)
        }
            
        // either playlist is empty
        else if ((newPlaylist!.count == 0) || (oldPlaylist!.count == 0))
        {
            self.init(fullReload: true)
        }
            
        // newPlaylist is one shorter than old playlist
        else if (newPlaylist!.count == (oldPlaylist!.count - 1))
        {
            // find the removed spin
            var missingSpinIndex:Int?
            for (i, spin) in newPlaylist!.enumerated()
            {
                if ((spin.id != oldPlaylist![i].id)  && (spin.id == oldPlaylist![i+1].id))
                {
                    missingSpinIndex = i
                    break
                }
            }
            
            if let missingSpinIndex = missingSpinIndex
            {
                var adjustedOldPlaylist = oldPlaylist!.map({$0.copy()})
                
                var reloadIndexes = PlaylistRefreshInstructions.differentIndexes(playlist1: newPlaylist!, playlist2: adjustedOldPlaylist)
                self.init(fullReload: false, removeItemAtIndex: missingSpinIndex, reloadIndexes: reloadIndexes)
            }
            else
            {
                self.init(fullReload:true)
            }
        }
        
        // ELSE playlists are same length
        else if (newPlaylist!.count == oldPlaylist!.count)
        {
            let reloadIndexes = PlaylistRefreshInstructions.differentIndexes(playlist1: newPlaylist!, playlist2: oldPlaylist!)
            
            if (reloadIndexes.count == newPlaylist!.count)
            {
                self.init(fullReload: true)
            }
            else
            {
                self.init(fullReload: false, reloadIndexes: reloadIndexes)
            }
        }
            
        // ELSE who the fuck knows so just say full reload
        else
        {
            self.init(fullReload: true)
        }
    }
    
    init(fullReload:Bool!, removeItemAtIndex:Int?=nil, reloadIndexes:[Int]=Array())
    {
        self.fullReload = fullReload
        self.reloadIndexes = reloadIndexes
        self.removeItemAtIndex = removeItemAtIndex
    }
    
    static func areSame(playlist1:[Spin], playlist2:[Spin]) -> Bool
    {
        if (playlist1.count != playlist2.count) {
            return false
        }
        
        for (i, spin) in playlist1.enumerated()
        {
            if (spin.airtime != playlist2[i].airtime)
            {
                return false
            }
            
            if (spin.id != playlist2[i].id)
            {
                return false
            }
        }
        return true
    }
    
    static func differentIndexes(playlist1:[Spin], playlist2:[Spin]) -> [Int]
    {
        var differentIndexes:[Int] = Array()
        for (i, spin) in playlist1.enumerated()
        {
            if (spin.airtime != playlist2[i].airtime)
            {
                differentIndexes.append(i)
            }
            // ELSE if the ids are different and they are not both commercialBlocks
            else if (spin.id != playlist2[i].id)
            {
                if ((spin.audioBlock?.__t == "CommercialBlock") && (playlist2[i].audioBlock?.__t != "CommercialBlock"))
                {
                   differentIndexes.append(i)
                }
            }
        }
        return differentIndexes
    }
}

enum PlaylistReloadType:Int
{
    case full = 1
    case partial = 2
    case noReload = 3
}
