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
    fileprivate var onProgressBlocks:Array<((SongFactory)->Void)> = Array()
    fileprivate var onErrorBlocks:Array<((NSError)->Void)> = Array()
    
    // dependency injections
    @objc var api:PlayolaAPI! = PlayolaAPI.sharedInstance()
    
    public override init()
    {
        super.init()
    }
    
    //------------------------------------------------------------------------------
    
    func requestSong(spotifyID:String)
    {
        // do nothing if the song has already been added
        if (!self.songRequests.contains(where: {$0.spotifyID == spotifyID}))
        {
            songRequests.append(SongRequestInfo(spotifyID: spotifyID, songStatus: nil, song: nil))
        }
        self.startRequests()
    }
    
    //------------------------------------------------------------------------------
    
    func makeSongRequest(songRequest:SongRequestInfo)
    {
        self.api.requestSongBySpotifyID(spotifyID: songRequest.spotifyID)
        .then
        {
            (songStatus, song) -> Void in
            if ((songStatus != songRequest.songStatus) || (song?.id != songRequest.song?.id))
            {
                songRequest.songStatus = songStatus
                songRequest.song = song
                self.executeOnProgressBlocks()
                
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
    
    func completedCount() -> Int
    {
        return self.songRequests.filter({ $0.hasCompleted() == true }).count
    }
    
    //------------------------------------------------------------------------------
    
    func successCount() -> Int
    {
        return self.songRequests.filter({ $0.songStatus == SongStatus.songExists }).count
    }
    
    //------------------------------------------------------------------------------
    
    func totalCount() -> Int
    {
        return self.songRequests.count
    }
    
    //------------------------------------------------------------------------------
    
    fileprivate func executeOnProgressBlocks()
    {
        for block in self.onProgressBlocks
        {
            block(self)
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
    @discardableResult func onCompletion(_ onCompletionBlock:((SongFactory)->Void)!) -> SongFactory
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
    @discardableResult func onProgress(_ onProgressBlock:((SongFactory)->Void)!) -> SongFactory
    {
        self.onProgressBlocks.append(onProgressBlock)
        return self
    }
}


class SongRequestInfo
{
    var spotifyID:String!
    var songStatus:SongStatus?
    var song:AudioBlock?
    
    init(spotifyID:String!, songStatus:SongStatus?=nil, song:AudioBlock?=nil)
    {
        self.spotifyID = spotifyID
        self.songStatus = songStatus
        self.song = song
    }
    
    func hasCompleted() -> Bool
    {
        if (self.songStatus == SongStatus.failedToAcquire) { return true }
        if (self.songStatus == SongStatus.notFound) { return true }
        return false
    }
}
