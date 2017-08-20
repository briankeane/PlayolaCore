//
//  PAPStationPlayer.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/20/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PlayolaStationPlayer: NSObject
{
    var isLoading:Bool = false
    var userPlaying:User?
    var automaticQueueLoadingTimer:Timer?
    var loadingProgress:Double?
    
    
    
    // dependecy injections
    var PAPlayer:PlayolaAudioPlayer!
    var dateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    func injectDependencies(
                                PAPlayer:PlayolaAudioPlayer!=PlayolaAudioPlayer(),
                                dateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
                            )
    {
        self.PAPlayer = PAPlayer
        self.dateHandler = dateHandler
    }
    
    func loadUserAndPlay(_ user:User)
    {
        if (self.PAPlayer.isPlaying() && self.userPlaying?.id == user.id)
        {
            return
        }
        
        
    }
}
