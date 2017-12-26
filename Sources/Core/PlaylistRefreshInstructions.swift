//
//  PlaylistRefreshInstructions.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 12/25/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

class PlaylistRefreshInstructions: NSObject
{
    var fullReload:Bool! = false
    var reloadIndexes:[Int]! = Array()
    var removeFirstItem:Bool! = false
    
    convenience init(oldPlaylist:[Spin]?, newPlaylist:[Spin]?)
    {
        var removeFirstItem:Bool = false
        
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
        else if (newPlaylist!.count == (oldPlaylist!.count - 1)) &&
                (newPlaylist![0].id == oldPlaylist![1].id)
        {
            let reloadIndexes = PlaylistRefreshInstructions.differentIndexes(playlist1: newPlaylist!, playlist2: Array(oldPlaylist![1...]))
            self.init(fullReload: false, removeFirstItem: true, reloadIndexes: reloadIndexes)
        
        // ELSE playlists are same length
        }
        else if (newPlaylist!.count == oldPlaylist!.count)
        {
            let reloadIndexes = PlaylistRefreshInstructions.differentIndexes(playlist1: newPlaylist!, playlist2: oldPlaylist!)
            if (reloadIndexes.count == newPlaylist!.count)
            {
                self.init(fullReload: true)
            }
            else
            {
                self.init(fullReload: false, removeFirstItem: false, reloadIndexes: reloadIndexes)
            }
        }
            
        // ELSE who the fuck knows so just say full reload
        else
        {
            self.init(fullReload: true)
        }
    }
    
    init(fullReload:Bool!, removeFirstItem:Bool!=false, reloadIndexes:[Int]=Array())
    {
        self.fullReload = fullReload
        self.reloadIndexes = reloadIndexes
        self.removeFirstItem = removeFirstItem
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
            else if (spin.id != playlist2[i].id)
            {
                differentIndexes.append(i)
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
