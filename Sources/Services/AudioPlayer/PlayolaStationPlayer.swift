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

public class PlayolaStationPlayer: NSObject
{
    var isLoading:Bool = false
    var userPlaying:User?
    var automaticQueueLoadingTimer:Timer?
    var loadingProgress:Double?
    var cacheManager:RemoteFileCacheManager = RemoteFileCacheManager(subFolder: "PlayolaStationPlayer")
    
    // dependecy injections
    var PAPlayer:PlayolaAudioPlayer! = PlayolaAudioPlayer()
    var dateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    var api:PlayolaAPI! = PlayolaAPI.sharedInstance()
    func injectDependencies(
                                PAPlayer:PlayolaAudioPlayer!=PlayolaAudioPlayer(),
                                dateHandler:DateHandlerService! = DateHandlerService.sharedInstance(),
                                api:PlayolaAPI! = PlayolaAPI.sharedInstance()
                            )
    {
        self.PAPlayer = PAPlayer
        self.dateHandler = dateHandler
        self.api = api
    }
    
    public func loadUserAndPlay(userID:String) -> Promise<Void>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
            self.api.getUser(userID: userID)
            .then
            {
                (user) -> Void in
                self.loadUserAndPlay(user: user)
                fulfill()
            }
            .catch
            {
                (error) -> Void in
                reject(error)
            }
        }
    }
    
    public func loadUserAndPlay(user:User)
    {
        user.startAutoUpdating()
        
        if (self.PAPlayer.isPlaying() && self.userPlaying?.id == user.id)
        {
            return
        }
        self.stop()
        
        // populate userPlaying and broadcast that loading started
        self.userPlaying = user.copy()
        let userID = user.id
        
        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.startedLoadingStation, object: nil, userInfo: ["user":self.userPlaying as Any])
        
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
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.loadingStationProgress, object: nil, userInfo: ["downloadProgress": "\(downloader.downloadProgress)"])
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
                
                // IF the audioBlock is the same (i.e. nowPlaying did not advance while song was being downloaded)
                if (downloader.remoteURL == self.nowPlaying()?.audioBlock?.audioFileUrl)
                {
                    self.PAPlayer.loadAudio(audioFileURL: downloader.localURL, startTime: self.nowPlaying()!.airtime!, beginFadeOutTime: self.nowPlaying()!.eomTime()!, spinInfo: self.nowPlaying()!.audioBlock!.toDictionary())
                }
                
                self.loadingProgress = nil
                self.startAutomaticQueueLoading()
                self.downloadAndLoadQueueSpins()
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    public func stop()
    {
        PAPlayer.stop()
        let previousUserPlaying = userPlaying
        self.userPlaying = nil
        NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stoppedPlayingStation, object: nil, userInfo: ["user":previousUserPlaying as Any])
        
    }
    
    //------------------------------------------------------------------------------
    
    func refreshDoNotDeleteCacheList()
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
    }
    
    //------------------------------------------------------------------------------
    
    public func nowPlaying() -> Spin?
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
    
    func downloadAndLoadQueueSpins()
    {
        print("downloadAndQueueSpins")
        // always runs on the background queue... all these spins are in the future
//        DispatchQueue.global(qos: .background).async
//        {
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
//        }
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
}
