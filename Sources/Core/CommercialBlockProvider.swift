//
//  CommercialBlockProvider.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/23/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

// -----------------------------------------------------------------------------
//                    class CommercialBlockProviderService
// -----------------------------------------------------------------------------
/// a service that provides commercialBlocks to be injected into the playlists.
/// Used as a Singleton with the name CommercialBlockProviderInstance
/// ----------------------------------------------------------------------------
public class CommercialBlockProviderService:NSObject
{
    @objc var currentUserInfo:PlayolaCurrentUserInfoService! = PlayolaCurrentUserInfoService.sharedInstance()
    
    
    // -----------------------------------------------------------------------------
    //                          func getCommercialBlocks
    // -----------------------------------------------------------------------------
    /// gets an array of commercialBlocks to be injected into a playlist
    ///
    /// - parameters:
    ///     - count: `(Int)` - the number of commercialBlocks required
    ///
    /// - returns:
    ///    `[AudioBlock]` - an array of commercialBlocks
    /// ----------------------------------------------------------------------------
    func getCommercialBlocks (_ count:Int) -> [AudioBlock]
    {
        var commercialBlocks:Array<AudioBlock> = []
        var nextID:Int! = 1
        var duration:Int! = 180000   // default duration
        
        if let secsOfCommercialPerHour = self.currentUserInfo.user?.secsOfCommercialPerHour
        {
            duration = secsOfCommercialPerHour/2*1000
        }
        
        if let userNextID = self.currentUserInfo.user?.lastCommercial?["audioFileID"] as? Int
        {
            nextID = self.getNextAudioFileID(userNextID)
        }
        
        for _ in 0..<count
        {
            let audioBlock = AudioBlock(audioBlockInfo: ["__t":"CommercialBlock" as AnyObject,
                                                         "audioFileUrl":"https://commercialblocks.playola.fm/\(String(format: "%04d", arguments: [nextID]))_commercial_block.mp3" as AnyObject,
                                                         "duration": duration as AnyObject,
                                                         "eoi": 0 as AnyObject,
                                                         "boo": (duration - 1000) as AnyObject,
                                                         "eom": (duration - 1000) as AnyObject,
                                                         "title":"Commercial Block" as AnyObject,
                                                         "id":"commercialBlock\(nextID ?? 1)" as AnyObject,
                                                         "key":"\(String(format: "%04d", arguments: [nextID]))_commercial_block.mp3" as AnyObject,
                                                         "isCommercialBlock":true as AnyObject])
            commercialBlocks.append(audioBlock)
            nextID = self.getNextAudioFileID(nextID)
        }
        return commercialBlocks
    }
    
    // -----------------------------------------------------------------------------
    //                          func getNextAudioFileID
    // -----------------------------------------------------------------------------
    /// /// - parameters:
    ///     - previousAudioFileID: `(Int)` - the previous commercialBlock's id
    ///
    /// - returns:
    ///    `Int` - the next audioFileID
    /// ----------------------------------------------------------------------------
    func getNextAudioFileID (_ previousAudioFileID:Int!) -> Int!
    {
        if (previousAudioFileID >= 27)
        {
            return 1
        }
        else
        {
            return previousAudioFileID + 1
        }
    }
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the CommmercialBlockProviderService for all to use
    ///
    /// - returns:
    ///    `CommercialBlockProviderService` - the central CommercialBlockProviderService
    ///
    /// ----------------------------------------------------------------------------
    public class func sharedInstance() -> CommercialBlockProviderService
    {
        if (self._instance == nil)
        {
            self._instance = CommercialBlockProviderService()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:CommercialBlockProviderService?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ commercialBlockProviderService:CommercialBlockProviderService)
    {
        self._instance = commercialBlockProviderService
    }
}
