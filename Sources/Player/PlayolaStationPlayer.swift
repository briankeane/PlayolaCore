//
//  PlayolaStationPlayer.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import SwiftRemoteFileCache
import PromiseKit

@objc open class PlayolaStationPlayer: NSObject
{
    /// a listeningSessionReporter
    var reporter:PlayolaListeningSessionReporter!
    
    /// true if the station is in the process of loading a user
    open var isLoading:Bool = false
    
    /// the user whose station is currently playing
    open var userPlaying:User?
    
    var automaticQueueLoadingTimer:Timer?
    
    /// buffering progress
    open var loadingProgress:Double?
    
    open var cacheManager:RemoteFileCacheManager = RemoteFileCacheManager(subFolder: "PlayolaStationPlayer")
    
    public init(paPlayer:PlayolaAudioPlayer?=nil)
    {
        super.init()
        self.reporter = PlayolaListeningSessionReporter()
        if let paPlayer = paPlayer
        {
            self.PAPlayer = paPlayer
        }
        else
        {
            self.PAPlayer = PlayolaAVAudioPlayer.sharedInstance()
        }
    }
    
    // dependecy injections
    @objc var PAPlayer:PlayolaAudioPlayer!
    @objc var dateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    @objc var api:PlayolaAPI! = PlayolaAPI.sharedInstance()
    
    //------------------------------------------------------------------------------
    
    open func loadUserAndPlay(userID:String) -> Promise<Void>
    {
        return Promise
        {
            (seal) -> Void in
            self.api.getUser(userID: userID)
            .done
            {
                (user) -> Void in
                self.loadUserAndPlay(user: user)
                seal.fulfill(())
            }
            .catch
            {
                (error) -> Void in
                seal.reject(error)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func loadUserAndPlay(user:User)
    {
        if (self.PAPlayer.isPlaying() && self.userPlaying?.id == user.id)
        {
            return
        }
        self.stop()
        
        // populate userPlaying and broadcast that loading started
        self.userPlaying = user
        self.userPlaying?.startAutoUpdating()
        self.userPlaying?.startAutoAdvancing()
        let userID = user.id
        self.isLoading = true
        
        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.startedLoadingStation, object: nil, userInfo: ["user":self.userPlaying as Any])
        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stationChanged, object: nil, userInfo: ["user":self.userPlaying as Any])
        
        let spin = self.nowPlaying()
        
        self.refreshDoNotDeleteCacheList()
        
        self.cacheManager.pauseDownloads()
        
        // Download first song...
        self.cacheManager.downloadFile(spin!.audioBlock!.audioFileUrl!)
        .onProgress
        {
            (downloader) -> Void in
            self.loadingProgress = downloader.downloadProgress
            if (downloader.remoteURL == self.nowPlaying()?.audioBlock?.audioFileUrl)
            {
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.loadingStationProgress, object: nil, userInfo: ["downloadProgress": downloader.downloadProgress])
            }
        }
        .onCompletion
        {
            (downloader) -> Void in
            // IF the user has not been changed since the process started
            if (self.userPlaying?.id == userID)
            {
                self.isLoading = false
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.loadingStationProgress, object: nil, userInfo: ["downloadProgress":downloader.downloadProgress])
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.finishedLoadingStation, object: nil)
                self.broadcastNowPlayingChanged()
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.startedPlayingStation, object: nil)
                    
                // IF the audioBlock is the same (i.e. nowPlaying did not advance while song was being downloaded)
                if (downloader.remoteURL == self.nowPlaying()?.audioBlock?.audioFileUrl)
                {
                    self.PAPlayer.loadAudio(audioFileURL: downloader.localURL, startTime: self.nowPlaying()!.airtime!, beginFadeOutTime: self.nowPlaying()!.eomTime()!, spinInfo: self.nowPlaying()!.audioBlock!.toDictionary())
                }
                    
                self.loadingProgress = nil
                self.startAutomaticQueueLoading()
                self.downloadAndLoadQueueSpins()
                self.startNowPlayingMonitoring()
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func isPlaying() -> Bool
    {
        return (self.userPlaying != nil) && (self.isLoading != true)
    }
    
    //------------------------------------------------------------------------------
    
    open func startNowPlayingMonitoring()
    {
        self.userPlaying?.onNowPlayingAdvanced()
        {
            (user) -> Void in
            if (user?.id == self.userPlaying?.id)
            {
                self.broadcastNowPlayingChanged()
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func broadcastNowPlayingChanged()
    {
        var userInfo:[String:Any] = [:]
        
        if let spin = self.userPlaying?.program?.nowPlaying
        {
            if let audioBlock = spin.audioBlock
            {
                userInfo["audioBlockInfo"] = audioBlock.toDictionary()
            }
            
            if let broadcasterID = self.userPlaying?.id
            {
                userInfo["broadasterID"] = broadcasterID
            }
            
            userInfo["spin"] = spin
        }
        
        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: userInfo)
    }
    
    //------------------------------------------------------------------------------
    
    open func stop()
    {
        PAPlayer.stop()
        let previousUserPlaying = userPlaying
        self.userPlaying = nil
        self.stopAutomaticQueueDownloading()
        
        if (previousUserPlaying != nil)
        {
            NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stationChanged, object: nil, userInfo: ["user":self.userPlaying as Any])
            NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo: ["spin":self.nowPlaying() as Any])
            NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stoppedPlayingStation, object  : nil, userInfo: ["user":previousUserPlaying as Any])
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func refreshDoNotDeleteCacheList()
    {
        let audioBlocksToLoad = self.spinsToLoad().map({$0.audioBlock!})
        var doNotDeleteDict:Dictionary<URL, RemoteFilePriorityLevel> = Dictionary()
        
        for audioBlock in audioBlocksToLoad
        {
            if let url = audioBlock.audioFileUrl
            {
                doNotDeleteDict[url] = RemoteFilePriorityLevel.doNotDelete
            }
        }
        self.cacheManager.filePriorities = doNotDeleteDict
    }
    
    //------------------------------------------------------------------------------
    
    open func nowPlaying() -> Spin?
    {
        if let spin = self.userPlaying?.program?.nowPlaying
        {
            return spin
        }
        return nil
    }
    
    //------------------------------------------------------------------------------
    
    func startAutomaticQueueLoading()
    {
        DispatchQueue.main.async
        {
            self.automaticQueueLoadingTimer?.invalidate()
            self.automaticQueueLoadingTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(PlayolaStationPlayer.downloadAndLoadQueueSpins), userInfo: nil, repeats: true)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func stopAutomaticQueueDownloading()
    {
        DispatchQueue.main.async
        {
            self.automaticQueueLoadingTimer?.invalidate()
            self.automaticQueueLoadingTimer = nil
        }
    }
    
    //------------------------------------------------------------------------------
    
    @objc func downloadAndLoadQueueSpins()
    {
        self.refreshDoNotDeleteCacheList()
        let spins = self.spinsToLoad()
            
        // store nowPlayingUserID so you can make sure it's still the same user when
        // the downloads complete.
        let nowPlayingUserID = self.userPlaying?.id
            
        for spin in spins
        {
            let localURL = self.cacheManager.localURLFromRemoteURL(spin.audioBlock!.audioFileUrl!)
            if (!self.PAPlayer.isQueued(localFileURL: localURL))
            {
                self.cacheManager.downloadFile(spin.audioBlock!.audioFileUrl!)
                .onCompletion
                {
                    (downloader) -> Void in
                    // IF the same user is still playing as when download started:
                    if (self.userPlaying?.id == nowPlayingUserID)
                    {
                        print("loading Audio: \(spin.audioBlock!.title!)")
                        self.PAPlayer.loadAudio(audioFileURL: downloader.localURL, startTime: spin.airtime!, beginFadeOutTime: spin.eomTime()!, spinInfo: spin.audioBlock!.toDictionary())
                    }
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func spinsToLoad() -> Array<Spin>
    {
        var spins:Array<Spin> = Array()
        
        if let nowPlaying = self.userPlaying?.program?.nowPlaying
        {
            spins.append(nowPlaying)
        }
        
        if let playlist = self.userPlaying?.program?.playlist
        {
            for spin in playlist
            {
                if (dateHandler.adjustedDate(spin.airtime)?.isBefore(Date().addSeconds(PlayolaConstants.LOCKED_SECONDS_OF_PRELOAD)) == true)
                {
                    spins.append(spin)
                }
                else
                {
                    break
                }
            }
        }
        let spinMap = spins.map({spin in return spin.audioBlock!.title!})
        print(spinMap)
        return spins
    }
    
    //------------------------------------------------------------------------------
    //                  Singleton
    //------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the PlayolaStationPlayer for all to use
    ///
    /// - returns:
    ///    `PlayolaStationPlayer` - the central PlayolaStationPlayer instance
    ///
    /// ----------------------------------------------------------------------------
    public static func sharedInstance() -> PlayolaStationPlayer
    {
        if (self._instance == nil)
        {
            self._instance = PlayolaStationPlayer()
        }
        return self._instance!
    }

    /// internally shared singleton instance
    fileprivate static var _instance:PlayolaStationPlayer?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    open class func replaceSharedInstance(_ stationPlayer:PlayolaStationPlayer)
    {
        self._instance = stationPlayer
    }
}
