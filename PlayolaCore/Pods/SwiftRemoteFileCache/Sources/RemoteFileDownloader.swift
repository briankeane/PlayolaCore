//
//  File.swift
//  SwiftRemoteFileCache
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

import Foundation
import Alamofire


// notification constants
let kAudioFileFinishedLoading:String = "audioFileFinishedLoading"

class RemoteFileDownloader
{
    var request:Alamofire.Request?
    var downloadProgress:Double = 0.0
    var remoteURL:URL
    var localURL:URL
    var suspended:Bool! = false
    var updatedAt:Date!
    
    fileprivate var onCompletionBlocks:Array<((RemoteFileDownloader)->Void)> = Array()
    fileprivate var onProgressBlocks:Array<((RemoteFileDownloader)->Void)> = Array()
    fileprivate var onErrorBlocks:Array<((NSError)->Void)> = Array()
    
    //------------------------------------------------------------------------------
    
    init(remoteURL:URL, localURL:URL)
    {
        self.remoteURL = remoteURL
        self.localURL = localURL
        self.updatedAt = Date()
        
        self.checkForFileExistence()
    }
    
    //------------------------------------------------------------------------------
    func checkForFileExistence()
    {
        if (self.completeFileExists())
        {
            self.downloadProgress = 1.0
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func isCached
    // -----------------------------------------------------------------------------
    /// returns true if the referenced file already exists
    ///
    /// - parameters:
    ///     - remoteURL: `(URL)` - the remoteURL of the downloaded file
    ///
    /// - returns:
    ///    `Bool` - returns true if the file exists
    /// ----------------------------------------------------------------------------
    func completeFileExists() -> Bool
    {
        return FileManager.default.fileExists(atPath: self.localURL.path)
    }
    
    // -----------------------------------------------------------------------------
    //                          func onCompletion
    // -----------------------------------------------------------------------------
    /// stores a block to execute on completion.  If there is already a block, it
    /// the new completion block will be added in addition to it.  If the download
    /// has already been completed, the onCompletion block will be executed immediately.
    ///
    /// - parameters:
    ///     - onCompletionBlock: `(((AudioCacheObject)->Void)!))` - a block to be
    ///                             executed upon completion of the download.  The
    ///                             block is passed the AudioCacheObject that completed
    ///
    /// ----------------------------------------------------------------------------
    func onCompletion(_ onCompletionBlock:((RemoteFileDownloader)->Void)!) -> RemoteFileDownloader
    {
        self.onCompletionBlocks.append(onCompletionBlock)
        
        // go ahead and execute this one immediately if it's already complete
        if (self.downloadProgress == 1.0)
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
    ///     - onProgressBlock: `(((AudioCacheObject)->Void)!))` - a block to be
    ///                          executed upon completion of the download.  The
    ///                          block is passed the AudioCacheObject that progressed
    ///
    /// ----------------------------------------------------------------------------
    func onProgress(_ onProgressBlock:((RemoteFileDownloader)->Void)!) -> RemoteFileDownloader
    {
        self.onProgressBlocks.append(onProgressBlock)
        return self
    }
    
    // -----------------------------------------------------------------------------
    //                          func onError
    // -----------------------------------------------------------------------------
    /// stores a block to execute if a download error occurs.  If there is already
    /// a block, the onErrorBlock will be added in addition to it.
    ///
    /// - parameters:
    ///     - onErrorBlock: `(((AudioCacheObject)->Void)!))` - a block to be
    ///                             executed owhen a download error occurs.  The
    ///                             block is passed the AudioCacheObject that errored
    ///
    /// ----------------------------------------------------------------------------
    
    func onError(_ onErrorBlock:((NSError)->Void)!) -> RemoteFileDownloader
    {
        self.onErrorBlocks.append(onErrorBlock)
        return self
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
    
    //------------------------------------------------------------------------------
    
    func beginDownload()
    {
        let destination:DownloadRequest.DownloadFileDestination = { _, _ in return (self.localURL, []) }
        
        self.request = Alamofire.download(self.remoteURL, method: .get, to: destination)
            .downloadProgress
            {
                (progress) -> Void in
                self.downloadProgress = progress.fractionCompleted
                self.updatedAt = Date()
                self.executeOnProgressBlocks()
            }
            .response
            {
                (response) -> Void in
                if let error = response.error
                {
                    print("download error")
                    print(error)
                    self.request?.cancel()
                    self.request = nil
                    self.executeOnErrorBlocks(error as NSError)
                }
                else
                {
                    self.executeOnCompletionBlocks()
                }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func pauseDownload()
    {
        if let _ = self.request
        {
            if (self.downloadProgress < 1.0) && !self.suspended
            {
                self.request?.suspend()
                self.suspended = true
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func resumeDownload()
    {
        // IF there's already a request
        if let _ = self.request
        {
            self.suspended = false
            self.request?.resume()
        }
        else if (self.downloadProgress < 1.0)
        {
            self.beginDownload()
        }
    }
    
    //------------------------------------------------------------------------------
    
    func cancelDownload()
    {
        self.request?.cancel()
    }
}
