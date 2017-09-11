//
//  PlayolaScheduler.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/10/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PlayolaScheduler:NSObject
{
    var user:User!
    var onPlaylistChangedBlocks:Array<((Array<Spin>)->Void)> = Array()
    
    // dependency injections:
    var DateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    var api:PlayolaAPI! = PlayolaAPI()
    
    func injectDependencies(DateHandler:DateHandlerService=DateHandlerService.sharedInstance(), api:PlayolaAPI=PlayolaAPI())
    {
        self.DateHandler = DateHandler
        self.api = api
    }
    
    //------------------------------------------------------------------------------
    
    override init() {
        super.init()
    }
    
    public init(user:User) {
        super.init()
        self.setupUser(user: user)
    }
    
    //------------------------------------------------------------------------------
    
    public func playlist() -> Array<Spin>?
    {
        return self.playlist()
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
    
    func moveSpin(_ spin:Spin , desiredPlaylistPosition:Int)
    {
        
    }
    
    
    
}
