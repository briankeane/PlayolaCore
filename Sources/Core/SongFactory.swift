//
//  SongFactory.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 12/5/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

@objc open class SongFactory:NSObject
{
    var songRequests:[SongRequestInfo] = Array()
    var checkRequestsTimer:Timer?
    
    fileprivate var onCompletionBlocks:Array<((SongFactory)->Void)> = Array()
    fileprivate var onProgressBlocks:Array<((SongFactory, AudioBlock?)->Void)> = Array()
    fileprivate var onErrorBlocks:Array<((NSError)->Void)> = Array()
    
    // dependency injections
    @objc var api:PlayolaAPI! = PlayolaAPI.sharedInstance()
    
    public override init()
    {
        super.init()
    }
    
    //------------------------------------------------------------------------------
    
    open func requestSong(spotifyTrack:SpotifyTrack)
    {
        self.addRequest(spotifyTrack: spotifyTrack)
        self.startRequests()
    }
    
    //------------------------------------------------------------------------------
    
    private func addRequest(spotifyTrack:SpotifyTrack)
    {
        // do nothing if there is not a proper spotifyID
        guard let spotifyID = spotifyTrack.spotifyID else { return }
        
        // do nothing if the song is already in process
        guard (!self.songRequests.contains(where: {$0.spotifyTrack.spotifyID == spotifyID })) else { return }
        
        songRequests.append(SongRequestInfo(spotifyTrack: spotifyTrack, songStatus: nil, song: nil))
    }
    
    //------------------------------------------------------------------------------
    
    open func requestSongs(spotifyTracks:[SpotifyTrack]) -> SongFactory
    {
        for spotifyTrack in spotifyTracks
        {
            self.addRequest(spotifyTrack: spotifyTrack)
        }
        self.startRequests()
        return self
    }
    
    //------------------------------------------------------------------------------
    
    func makeSongRequest(songRequest:SongRequestInfo)
    {
        // do nothing if there is no spotifyID
        guard let spotifyID = songRequest.spotifyTrack.spotifyID else { return }
        
        self.api.requestSongBySpotifyID(spotifyID: spotifyID)
        .then
        {
            (songStatus, song) -> Void in
            if ((songStatus != songRequest.songStatus) || (song?.id != songRequest.song?.id))
            {
                songRequest.songStatus = songStatus
                songRequest.song = song
                self.executeOnProgressBlocks(song: song)
                
                if (self.completedCount() == self.totalCount())
                {
                    self.checkRequestsTimer?.invalidate()
                    self.executeOnCompletionBlocks()
                }
            }
        }
        .catch
        {
            (error) -> Void in
            puts("error")
        }
    }
    
    //------------------------------------------------------------------------------
    
    func sendAllSongRequests()
    {
        for songRequest in self.songRequests
        {
            if (!songRequest.hasCompleted())
            {
                self.makeSongRequest(songRequest: songRequest)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func startRequests()
    {
        if (self.checkRequestsTimer == nil) && (self.completedCount() < self.totalCount())
        {
            self.checkRequestsTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true)
            {
                (timer) -> Void in
                self.sendAllSongRequests()
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func completed() -> [SongRequestInfo]
    {
        return self.songRequests.filter({ $0.hasCompleted() == true })
    }
    
    //------------------------------------------------------------------------------
    
    public func completedCount() -> Int
    {
        return self.completed().count
    }
    
    //------------------------------------------------------------------------------
    
    public func successfulSongInfos() -> [(spotifyTrack:SpotifyTrack, songStatus:SongStatus?, song:AudioBlock?)]
    {
        return self.songRequests.map({$0.toTuple()})
    }
    
    //------------------------------------------------------------------------------
    
    func success() -> [SongRequestInfo]
    {
        return self.songRequests.filter({ $0.songStatus == SongStatus.songExists })
    }
    
    //------------------------------------------------------------------------------
    
    public func successCount() -> Int
    {
        return self.success().count
    }
    
    //------------------------------------------------------------------------------
    
    public func totalCount() -> Int
    {
        return self.songRequests.count
    }
    
    //------------------------------------------------------------------------------
    
    fileprivate func executeOnProgressBlocks(song:AudioBlock?=nil)
    {
        for block in self.onProgressBlocks
        {
            block(self, song)
        }
    }
    
    //------------------------------------------------------------------------------
    
    fileprivate func executeOnErrorBlocks(_ error:NSError)
    {
        for block in self.onErrorBlocks
        {
            block(error)
        }
    }
    
    //------------------------------------------------------------------------------
    
    fileprivate func executeOnCompletionBlocks()
    {
        for block in self.onCompletionBlocks
        {
            block(self)
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func onCompletion
    // -----------------------------------------------------------------------------
    /// stores a block to execute on completion.  If there is already a block, it
    /// the new completion block will be added in addition to it.  If the download
    /// has already been completed, the onCompletion block will be executed immediately.
    ///
    /// - parameters:
    ///     - onCompletionBlock: `(((SongFactory)->Void)!))` - a block to be
    ///                             executed upon completion of all songs.  The
    ///                             block is passed the AudioCacheObject that completed
    ///
    /// ----------------------------------------------------------------------------
    @discardableResult public func onCompletion(_ onCompletionBlock:((SongFactory)->Void)!) -> SongFactory
    {
        self.onCompletionBlocks.append(onCompletionBlock)
        
        // go ahead and execute this one immediately if it's already complete
        if (self.completedCount() == self.totalCount())
        {
            onCompletionBlock(self)
        }
        return self
    }
    
    // -----------------------------------------------------------------------------
    //                          func onProgress
    // -----------------------------------------------------------------------------
    /// stores a block to execute on progress.  If there is already a block, it
    /// the new completion block will be added in addition to it
    ///
    /// - parameters:
    ///     - onProgressBlock: `(((SongFactory)->Void)!))` - a block to be
    ///                          executed upon completion of the download.  The
    ///                          block is passed the SongFactory itself
    ///
    /// ----------------------------------------------------------------------------
    @discardableResult public func onProgress(_ onProgressBlock:((SongFactory, AudioBlock?)->Void)!) -> SongFactory
    {
        self.onProgressBlocks.append(onProgressBlock)
        return self
    }
}


class SongRequestInfo
{
    var spotifyTrack:SpotifyTrack!
    var songStatus:SongStatus?
    var song:AudioBlock?
    
    init(spotifyTrack:SpotifyTrack!, songStatus:SongStatus?=nil, song:AudioBlock?=nil)
    {
        self.spotifyTrack = spotifyTrack
        self.songStatus = songStatus
        self.song = song
    }
    
    func hasCompleted() -> Bool
    {
        if (self.songStatus == SongStatus.failedToAcquire) { return true }
        if (self.songStatus == SongStatus.notFound ) { return true }
        if (self.songStatus == SongStatus.songExists) { return true }
        return false
    }
    
    func toTuple() -> (spotifyTrack:SpotifyTrack, songStatus:SongStatus?, song:AudioBlock?)
    {
        return (spotifyTrack:self.spotifyTrack, songStatus:self.songStatus, song:self.song)
    }
}
