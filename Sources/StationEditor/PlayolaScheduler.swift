//
//  PlayolaScheduler.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/10/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit

public class PlayolaScheduler:NSObject
{
    var user:User!
    var onPlaylistChangedBlocks:Array<((Array<Spin>)->Void)> = Array()
    
    var previousPlaylist:[Spin]?
    var observers:[NSObjectProtocol] = Array()
    
    // dependency injections:
    var DateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    var api:PlayolaAPI! = PlayolaAPI.sharedInstance()
    
    func injectDependencies(DateHandler:DateHandlerService=DateHandlerService.sharedInstance(), api:PlayolaAPI=PlayolaAPI.sharedInstance())
    {
        self.DateHandler = DateHandler
        self.api = api
    }
    
    //------------------------------------------------------------------------------
    
    override init()
    {
        super.init()
        self.setupListeners()
        if let user = PlayolaCurrentUserInfoService.sharedInstance().user
        {
            self.setupUser(user: user)
        }
    }
    
    func setupListeners()
    {
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.signedIn, object: nil, queue: .main)
        {
            (notification) -> Void in
            if let user = notification.userInfo?["user"] as? User
            {
                self.setupUser(user: user)
            }
        })
    }
    //------------------------------------------------------------------------------
    
    deinit
    {
        self.removeObservers()
    }
    
    //------------------------------------------------------------------------------
    
    func removeObservers()
    {
        for observer in self.observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    //------------------------------------------------------------------------------
    
    public func playlist() -> Array<Spin>?
    {
        return self.user?.program?.playlist
    }
    
    //------------------------------------------------------------------------------
    
    public func nowPlaying() -> Spin?
    {
        return self.user?.program?.nowPlaying
    }
    
    //------------------------------------------------------------------------------
    
    func setupUser(user:User)
    {
        self.user = user
        self.user.startAutoUpdating()
        self.user.startAutoAdvancing()
        self.user.onNowPlayingAdvanced
        {
            (user) -> Void in
            self.executeOnPlaylistChanged()
        }
        NotificationCenter.default.post(name: PlayolaEvents.schedulerRefreshedPlaylist, object: nil, userInfo: ["playlist": self.playlist() as Any])
    }
    
    //------------------------------------------------------------------------------
    
    public func onPlaylistChanged(_ block:((Array<Spin>)->Void)!) -> PlayolaScheduler
    {
        self.onPlaylistChangedBlocks.append(block)
        return self
    }
    
    //------------------------------------------------------------------------------
    
    func executeOnPlaylistChanged()
    {
        for block in onPlaylistChangedBlocks
        {
            if let playlist = self.playlist()
            {
                block(playlist)
            }
            else
            {
                block(Array())
            }
        }
    }
    // -----------------------------------------------------------------------------
    //                          func moveSpin
    // -----------------------------------------------------------------------------
    /**
     Moves a spin from one playlistPosition to another
     
     - parameters:
        - fromPlaylistPosition: `(Int)` - the playlistPosition of the spin to be moved
        - toPlaylistPosition: `(Int)` - the desired playlistPosition of the spin after the move
     
     ### NOTE: ###
     If moving forward,remember to account for the reordering of spins when the
     moved spin will be removed.  For example, given:
     ```
     (id: a, playlistPosition: 23)
     (id: b, playlistPosition: 24)
     (id: c, playlistPosition: 25)
     (id: d, playlistPosition: 26)
     (id: e, playlistPosition: 27)
     (id: f, playlistPosition: 28)
     ```
     moveSpin(fromPlaylistPosition:24, toPlaylistPosition: 26) will result in:
     ```
     (id: a, playlistPosition: 23)
     (id: c, playlistPosition: 24)
     (id: d, playlistPosition: 25)
     (id: b, playlistPosition: 26)
     (id: e, playlistPosition: 27)
     (id: f, playlistPosition: 28)
     ```
     
     ### Usage Example ###
     ```
     scheduler.moveSpin(fromPlaylistPosition: 23, toPlaylistPosition:26)
     .then
     {
        (playlist) -> Void in
        print(playlist)
     }
     .catch
     {
        (error) -> Void in
        print(error)
     }
     ```
     
     - returns:
     `Promise<Array<Spin>>` - a promise that resolves to an array of Spins
     * resolves to: the updated playlist
     * rejects: an AuthError or a SchedulerError
     */
    public func moveSpin(fromPlaylistPosition:Int, toPlaylistPosition:Int) -> Promise<User>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
            
            // check that playlistInit has already occured
            if (self.user.program == nil)
            {
                return reject(PlayolaErrorType.playlistInitRequired)
            }
            
            if let spinID = self.getSpin(playlistPosition: fromPlaylistPosition)?.id
            {
                if (self.playlistPositionIsValid(playlistPosition: toPlaylistPosition))
                {
                    self.storePlaylist(playlist: self.playlist())
                    self.performTemporaryMoveSpin(fromPlaylistPosition: fromPlaylistPosition, toPlaylistPosition: toPlaylistPosition)
                    
                    api.moveSpin(spinID:spinID, newPlaylistPosition:toPlaylistPosition)
                    .then
                    {
                        (user) -> Void in
                        if let playlist = user.program?.playlist
                        {
                            self.updatePlaylist(playlist: playlist)
                        }
                        fulfill(user)
                    }
                    .catch
                    {
                        (error) -> Void in
                        reject(error)
                    }
                }
                else
                {
                    reject(SchedulerError(type: .invalidPlaylistPosition))
                }
            }
            else
            {
                reject(SchedulerError(type: .spinNotFound))
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func storePlaylist(playlist:[Spin]?)
    {
        if let playlist = playlist
        {
            self.previousPlaylist = playlist.map { $0.copy() }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func restorePlaylist()
    {
        if let playlist = self.previousPlaylist
        {
            self.updatePlaylist(playlist: playlist)
            self.previousPlaylist = nil
        }
    }
    
    //------------------------------------------------------------------------------
    
    func performTemporaryMoveSpin(fromPlaylistPosition:Int, toPlaylistPosition:Int)
    {
        if var playlist = self.playlist()
        {
            let maxPlaylistPosition:Int = max(fromPlaylistPosition, toPlaylistPosition)
            let minPlaylistPosition:Int = min(fromPlaylistPosition, toPlaylistPosition)
            
            var minIndex:Int?
            var maxIndex:Int?
            
            for (index, spin) in playlist.enumerated()
            {
                if ((spin.playlistPosition! >= minPlaylistPosition) && (spin.playlistPosition! <= maxPlaylistPosition))
                {
                    if (spin.playlistPosition == minPlaylistPosition)
                    {
                        minIndex = index
                    }
                    else if (spin.playlistPosition == maxPlaylistPosition)
                    {
                        maxIndex = index
                    }
                    spin.airtime = nil
                }
            }
            
            // IF moving towards the future
            if (fromPlaylistPosition == minPlaylistPosition)
            {
                playlist.insert(playlist.remove(at: minIndex!), at: maxIndex!)
            }
            else
            {
                playlist.insert(playlist.remove(at: maxIndex!), at: minIndex!)
            }
            self.updatePlaylist(playlist: playlist)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func updatePlaylist(playlist:[Spin])
    {
        var fullReload:Bool = true
        var differentIndexes:[Int]?
        
        if let getIndexes = self.differentIndexes(oldPlaylist: self.playlist(), newPlaylist: playlist)
        {
            fullReload = false
            differentIndexes = getIndexes
        }
        
        self.user?.program?.playlist = playlist
        
        NotificationCenter.default.post(name: PlayolaEvents.schedulerRefreshedPlaylist, object: nil, userInfo: ["fullReload": fullReload,
                            "changedIndexes": differentIndexes as Any
                                    ])
    }
    
    //------------------------------------------------------------------------------
    
    
    func differentIndexes(oldPlaylist:[Spin]?, newPlaylist:[Spin]?) -> [Int]?
    {
        if let oldPlaylist = oldPlaylist
        {
            if let newPlaylist = newPlaylist
            {
                if (oldPlaylist.count != newPlaylist.count)
                {
                    return nil
                }
                var differentIndexes:[Int] = Array()
                for (index, spin) in newPlaylist.enumerated()
                {
                    if (spin.airtime != oldPlaylist[index].airtime)
                    {
                        differentIndexes.append(index)
                        continue
                    }
                    
                    if (spin.id != oldPlaylist[index].id)
                    {
                        differentIndexes.append(index)
                        continue
                    }
                    if (spin.audioBlock?.id != oldPlaylist[index].audioBlock?.id)
                    {
                        differentIndexes.append(index)
                        continue
                    }
                }
                return differentIndexes
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    func playlistPositionIsValid(playlistPosition:Int) -> Bool
    {
        if let firstOKPosition = self.firstChangeablePlaylistPosition()
        {
            if let lastPlaylistPosition = self.lastPlaylistPosition()
            {
                // it's ok to place something right after the current schedule
                let lastOKPosition = lastPlaylistPosition + 1
                    
                if ((playlistPosition >= firstOKPosition) && (playlistPosition <= lastOKPosition))
                {
                    return true
                }
            }
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    func getSpin(playlistPosition:Int) -> Spin?
    {
        if let playlist = self.playlist()
        {
            for spin in playlist
            {
                if (spin.playlistPosition == playlistPosition)
                {
                    return spin
                }
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    func lastPlaylistPosition() -> Int?
    {
        if let playlist = self.playlist()
        {
            if let lastSpin = playlist.last
            {
                return lastSpin.playlistPosition
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    func firstChangeablePlaylistPosition() -> Int?
    {
        if let playlist = self.playlist()
        {
            for spin in playlist
            {
                if let airtime = spin.airtime
                {
                    if (airtime.isAfter(DateHandler.now().addSeconds(PlayolaConstants.LOCKED_SECONDS_OF_PRELOAD)))
                    {
                        return spin.playlistPosition
                    }
                }
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    // Singleton
    //------------------------------------------------------------------------------
    
    public static var _instance:PlayolaScheduler?
    public static func sharedInstance() -> PlayolaScheduler
    {
        if let instance = self._instance
        {
            return instance
        }
        self._instance = PlayolaScheduler()
        return self._instance!
    }
}

fileprivate let createInstance = PlayolaScheduler.sharedInstance()
