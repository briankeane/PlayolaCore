//
//  ProgramModel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public struct Program
{
    public var nowPlaying:Spin?
    public var playlist:Array<Spin>?
    public var recentlyPlayed:Array<Spin> = []
    
    // dependencies
    var DateHandler:DateHandlerService = DateHandlerService.sharedInstance()
    var commercialBlockProvider:CommercialBlockProviderService = CommercialBlockProviderService.sharedInstance()
    
    //------------------------------------------------------------------------------
    
    public init (rawPlaylist:Array<Dictionary<String,Any>>, DateHandler:DateHandlerService = DateHandlerService.sharedInstance(), commercialBlockProvider:CommercialBlockProviderService = CommercialBlockProviderService.sharedInstance())
    {
        
        // inject dependencies
        self.DateHandler = DateHandler
        self.commercialBlockProvider = commercialBlockProvider
        
        self.playlist = rawPlaylist.map(
        {
            (rawSpin) -> Spin in
            return Spin(spinInfo: rawSpin)
        })
        self.commonInit()
    }
    
    //------------------------------------------------------------------------------
    
    public init (playlist:[Spin], DateHandler:DateHandlerService = DateHandlerService.sharedInstance(), commercialBlockProvider:CommercialBlockProviderService = CommercialBlockProviderService.sharedInstance())
    {
        // inject dependencies
        self.DateHandler = DateHandler
//        self.commercialBlockProvider = commercialBlockProvider
        
        self.commonInit()
    }
    
    //------------------------------------------------------------------------------
    
    public init(original:Program)
    {
        self.DateHandler = original.DateHandler
        self.commercialBlockProvider = original.commercialBlockProvider
        self.nowPlaying = original.nowPlaying?.copy()
        self.recentlyPlayed = original.recentlyPlayed.map { $0.copy() }
        if let _ = original.playlist
        {
            self.playlist = []
            
            for i in 0..<original.playlist!.count
            {
                self.playlist!.append(original.playlist![i].copy())
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    mutating func commonInit()
    {
        self.insertCommercials()
        self.nowPlaying = self.playlist!.remove(at: 0)
        self.bringCurrent()
    }
    
    //------------------------------------------------------------------------------
    // bringCurrent() -- returns a Bool indicating whether it was advanced or not
    //------------------------------------------------------------------------------
    @discardableResult public mutating func bringCurrent() -> Bool
    {
        var changedFlag:Bool = false
        if let playlist = self.playlist
        {
            if playlist.count > 0
            {
                while (self.playlist!.count > 0) && (self.playlist![0].airtime!.isBefore(self.DateHandler.now()))
                {
                    // store nowPlaying in recentlyPlayed if necessary
                    if let _ = nowPlaying
                    {
                        self.recentlyPlayed.insert(nowPlaying!, at: 0)
                    }
                    nowPlaying = self.playlist!.remove(at: 0)
                    changedFlag = true
                }
            }
        }
        return changedFlag
    }
    
    //------------------------------------------------------------------------------
    
    func insertCommercials()
    {
        var commercials:[AudioBlock] = self.commercialBlockProvider.getCommercialBlocks(20)
        var commercialIndex:Int = 0
        
        if let _ = self.playlist
        {
            for i in 0..<self.playlist!.count
            {
                if (self.playlist![i].audioBlock?.__t == nil) {
                    puts("nil!")
                }
                if (self.playlist![i].isCommercialBlock() == true)
                {
                    self.playlist![i].audioBlock = commercials[commercialIndex]
                    commercialIndex += 1
                    
                    // if we're at the end, start over
                    if (commercialIndex >= commercials.count)
                    {
                        commercialIndex = 0
                    }
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    public mutating func getNowPlaying() -> Spin?
    {
        self.bringCurrent()
        return nowPlaying
    }
    
    //------------------------------------------------------------------------------
    
    public func copy() -> Program
    {
        return Program(original: self)
    }
    
    //------------------------------------------------------------------------------
    
    public func playlistContainsNilAirtimes() -> Bool
    {
        if let playlist = self.playlist
        {
            for spin in playlist
            {
                if (spin.airtime == nil)
                {
                    return true
                }
            }
        }
        return false
    }
    
    // -----------------------------------------------------------------------------
    //                          func isSameAs()
    // -----------------------------------------------------------------------------
    /// compares two programs.  This works by comparing arrays all spinIDs
    ///
    /// ----------------------------------------------------------------------------
    public func isSameAs(_ program:Program) -> Bool
    {
        if let myPlaylist = self.playlist
        {
            if let otherPlaylist = program.playlist
            {
                if (myPlaylist.count != otherPlaylist.count)
                {
                    return false
                }
                
                for i in 0..<myPlaylist.count
                {
                    // compare ids
                    if (myPlaylist[i].id != otherPlaylist[i].id)
                    {
                        return false
                    }
                    
                    // compare airtimes
                    if (myPlaylist[i].airtime != otherPlaylist[i].airtime)
                    {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    // -----------------------------------------------------------------------------
    //                      func firstDifferentSpin()
    // -----------------------------------------------------------------------------
    /// returns the first spin that is different from the compared Program
    ///
    /// - parameters:
    ///     - compareTo: `(Program)` - the program to compare to
    ///
    /// - returns:
    ///    `Spin?` - the first different spin... nil if programs are the same
    ///
    /// ----------------------------------------------------------------------------
    public func firstDifferentSpin(compareTo:Program) -> Spin?
    {
        if let thisPlaylist = self.playlist
        {
            if let compareToPlaylist = compareTo.playlist
            {
                for i in 0..<thisPlaylist.count
                {
                    if (thisPlaylist[i].id != compareToPlaylist[i].id)
                    {
                        return thisPlaylist[i]
                    }
                }
            }
        }
        return nil
    }
}
