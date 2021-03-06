//
//  PlayolaProgramAutoAdvancer.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/29/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class PlayolaProgramAutoAdvancer:NSObject
{
    weak var user:User?
    var advanceTimer:Timer?
    var dateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    
    
    init(user:User, dateHandler:DateHandlerService=DateHandlerService.sharedInstance())
    {
        self.user = user
        self.dateHandler = dateHandler
    }
    
    // -----------------------------------------------------------------------------
    //                          func scheduleNextAdvance
    // -----------------------------------------------------------------------------
    /// schedules the next advance for the user.
    ///
    /// ----------------------------------------------------------------------------
    func scheduleNextAdvance()
    {
        // set next advance
        if let program = self.user?.program
        {
            if let playlist:Array<Spin> = program.playlist
            {
                if (playlist.count > 0)
                {
                    if let fireTime:Date = self.dateHandler.adjustedDate(playlist[0].airtime)
                    {
                        self.advanceTimer?.invalidate()
                        self.advanceTimer = Timer(fire: fireTime, interval: 0.0, repeats: false)
                        {
                            (timer) -> Void in
                            self.handleAdvanceFired()
                        }
                        RunLoop.main.add(self.advanceTimer!, forMode: RunLoop.Mode.default)
                    }
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    public func startAutoAdvancing()
    {
        self.scheduleNextAdvance()
    }
    
    //------------------------------------------------------------------------------
    
    func handleAdvanceFired()
    {
        self.advanceProgram()
        self.scheduleNextAdvance()
    }
    
    //------------------------------------------------------------------------------
    
    func advanceProgram()
    {
        if let playlist = self.user?.program?.playlist
        {
            if (playlist.count > 0)
            {
                if let newNowPlaying = self.user?.program?.playlist?.remove(at: 0)
                {
                    self.user?.program?.nowPlaying =  newNowPlaying
                }
                self.user?.handleNowPlayingAdvanced()
            }
        }
    }
}
