//
//  PlayolaScheduler.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/10/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit

open class PlayolaScheduler:NSObject
{
    var user:User!
    var onPlaylistChangedBlocks:Array<((Array<Spin>)->Void)> = Array()
    
    var previousPlaylist:[Spin]?
    var observers:[NSObjectProtocol] = Array()
    
    // dependency injections:
    @objc var DateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    @objc var api:PlayolaAPI! = PlayolaAPI.sharedInstance()
    
    //------------------------------------------------------------------------------
    
    public override init()
    {
        super.init()
        self.setupListeners()
        if let user = PlayolaCurrentUserInfoService.sharedInstance().user
        {
            self.setupUser(user: user)
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func setupListeners()
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
    
    open func playlist() -> Array<Spin>?
    {
        return self.user?.program?.playlist
    }
    
    //------------------------------------------------------------------------------
    
    open func nowPlaying() -> Spin?
    {
        return self.user?.program?.nowPlaying
    }
    
    //------------------------------------------------------------------------------
    
    func setupUser(user:User)
    {
        self.user = user.copy()
        self.user.startAutoUpdating()
        self.user.startAutoAdvancing()
        self.user.onNowPlayingAdvanced
        {
            (user) -> Void in
            self.executeOnPlaylistChanged()
            NotificationCenter.default.post(name: PlayolaEvents.schedulerNowPlayingAdvanced, object: nil, userInfo: ["nowPlaying": self.nowPlaying() as Any])
            NotificationCenter.default.post(name: PlayolaEvents.schedulerRefreshedPlaylist, object: nil, userInfo:
                ["refreshInstructions": PlaylistRefreshInstructions(fullReload: false, removeFirstItem: true)]
            )
        
        }
        NotificationCenter.default.post(name: PlayolaEvents.schedulerRefreshedPlaylist, object: nil, userInfo: ["refreshInstructions": PlaylistRefreshInstructions(fullReload: true) as Any])
    }
    
    //------------------------------------------------------------------------------
    
    open func onPlaylistChanged(_ block:((Array<Spin>)->Void)!) -> PlayolaScheduler
    {
        self.onPlaylistChangedBlocks.append(block)
        return self
    }
    
    //------------------------------------------------------------------------------
    
    open func executeOnPlaylistChanged()
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
    open func moveSpin(fromPlaylistPosition:Int, toPlaylistPosition:Int) -> Promise<User>
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
    
    // -----------------------------------------------------------------------------
    //                          func removeSpin
    // -----------------------------------------------------------------------------
    /**
     Removes a spin from the provided playlistPosition
     
     - parameters:
     - atPlaylistPosition: `(Int)` - the playlistPosition of the spin to be removed
     
     ### Usage Example ###
     ```
     scheduler.removeSpin(atPlaylistPosition: 24)
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
    open func removeSpin(atPlaylistPosition:Int) -> Promise<User>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
           
            // check that playlist init has already occured
            if (self.user.program == nil)
            {
                return reject(PlayolaErrorType.playlistInitRequired)
            }
            
            if let spinID = self.getSpin(playlistPosition: atPlaylistPosition)?.id
            {
                if (self.playlistPositionIsValid(playlistPosition: atPlaylistPosition))
                {
                    self.storePlaylist(playlist: self.playlist())
                    self.performTemporaryRemoveSpin(atPlaylistPosition: atPlaylistPosition)
                    
                    api.removeSpin(spinID: spinID)
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
                        self.restorePlaylist()
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
    
    // -----------------------------------------------------------------------------
    //                          func insertAudioBlock
    // -----------------------------------------------------------------------------
    /**
     Inserts an AudioBlock at the provided playlistPosition
     
     - parameters:
     - audioBlock: `(String)` - the audioBlock to insert
     - atPlaylistPosition: `(Int)` - the desired playlistPosition
     
     ### Usage Example ###
     ```
     scheduler.insertAudioBlock(audioBlock:song, atPlaylistPosition: 24)
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
    open func insertAudioBlock(audioBlock:AudioBlock, atPlaylistPosition:Int) -> Promise<User>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
                
            // check that playlist init has already occured
            if (self.user.program == nil)
            {
                return reject(PlayolaErrorType.playlistInitRequired)
            }
            
            self.storePlaylist(playlist: self.playlist())
            self.performTemporaryInsertAudioBlock(audioBlock:audioBlock, playlistPosition:atPlaylistPosition)
            
            api.insertSpin(audioBlockID: audioBlock.id!, playlistPosition: atPlaylistPosition)
            .then
            {
                (updatedUser) -> Void in
                if let playlist = updatedUser.program?.playlist
                {
                    self.updatePlaylist(playlist:playlist)
                }
            }
            .catch
            {
                (error) -> Void in
                self.restorePlaylist()
                reject(error)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func storePlaylist(playlist:[Spin]?)
    {
        if let playlist = playlist
        {
            self.previousPlaylist = playlist.map { $0.copy() }
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func restorePlaylist()
    {
        if let playlist = self.previousPlaylist
        {
            self.updatePlaylist(playlist: playlist)
            self.previousPlaylist = nil
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func performTemporaryMoveSpin(fromPlaylistPosition:Int, toPlaylistPosition:Int)
    {
        if (fromPlaylistPosition == toPlaylistPosition)
        {
            return
        }
        
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
                let movingSpin = playlist.remove(at: minIndex!)
                playlist.insert(movingSpin, at: maxIndex!)
            }
            else
            {
                let movingSpin = playlist.remove(at: maxIndex!)
                playlist.insert(movingSpin, at: minIndex!)
            }
            self.updatePlaylist(playlist: playlist)
        }
    }
    
    open func performTemporaryInsertAudioBlock(audioBlock:AudioBlock, playlistPosition:Int)
    {
        if var playlist = self.playlist()
        {
            for (index, spin) in playlist.enumerated()
            {
                if (spin.playlistPosition == playlistPosition)
                {
                    playlist.insert(Spin(audioBlock:audioBlock), at: index)
                }
                else if (spin.playlistPosition != nil) && (spin.playlistPosition! > playlistPosition)
                {
                    spin.airtime = nil
                }
            }
            self.updatePlaylist(playlist: playlist)
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func performTemporaryRemoveSpin(atPlaylistPosition:Int)
    {
        if var playlist = self.playlist()
        {
            for index in (0..<playlist.count).reversed()
            {
                let spin = playlist[index]
                if (spin.playlistPosition! > atPlaylistPosition)
                {
                    spin.airtime = nil
                }
                else if (atPlaylistPosition == spin.playlistPosition!)
                {
                    playlist.remove(at: index)
                    self.updatePlaylist(playlist: playlist)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func updatePlaylist(playlist:[Spin])
    {
        let oldPlaylist = self.playlist()
        
        self.user?.program?.playlist = playlist
        
        NotificationCenter.default.post(name: PlayolaEvents.schedulerRefreshedPlaylist, object: nil, userInfo: [
            "refreshInstructions" : PlaylistRefreshInstructions(oldPlaylist: oldPlaylist, newPlaylist: playlist)
                    ])
    }
    
    //------------------------------------------------------------------------------
    
    open func differentIndexes(oldPlaylist:[Spin]?, newPlaylist:[Spin]?) -> [Int]?
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
    
    open func playlistPositionIsValid(playlistPosition:Int) -> Bool
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
    
    open func getSpin(playlistPosition:Int) -> Spin?
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
    
    open func getSpinIndex(playlistPosition:Int) -> Int?
    {
        if let playlist = self.playlist()
        {
            for (index, spin) in playlist.enumerated()
            {
                if (spin.playlistPosition == playlistPosition)
                {
                    return index
                }
            }
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    open func lastPlaylistPosition() -> Int?
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
    
    open func firstChangeablePlaylistPosition() -> Int?
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
    
    private static var _instance:PlayolaScheduler?
    open static func sharedInstance() -> PlayolaScheduler
    {
        if let instance = self._instance
        {
            return instance
        }
        self._instance = PlayolaScheduler()
        return self._instance!
    }
    
    open static func replaceSharedInstance(instance:PlayolaScheduler)
    {
        self._instance = instance
    }
}

fileprivate let createInstance = PlayolaScheduler.sharedInstance()
