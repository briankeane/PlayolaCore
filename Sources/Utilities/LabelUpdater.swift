//
//  LabelUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class LabelUpdater:NSObject
{
    weak var label:AutoUpdatingLabel?

    /// the String to display when the represented value is nil
    var blankText:String = "---------"
   
    // dependency injections
    var stationPlayer:PlayolaStationPlayer = PlayolaStationPlayer.sharedInstance()
    
    // observer storage and removal
    var observers:[NSObjectProtocol] = Array()
    func removeObservers()
    {
        for observer in self.observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    init(label:AutoUpdatingLabel)
    {
        super.init()
        self.label = label
        self.setValue()
        self.setupListeners()
    }
    
    deinit
    {
        self.removeObservers()
    }
    
    //------------------------------------------------------------------------------
    
    func setValue()
    {
        // IF there's a delegate representation...
        if let text = self.label?.autoUpdatingDelegate?.alternateDisplayText?(self.label!, audioBlockDict: self.stationPlayer.nowPlaying()?.audioBlock?.toDictionary())
        {
            self.label?.changeText(text: text)
        }
        else
        {
            if let _ = self.label as? NowPlayingArtistLabel
            {
                self.changeArtistLabel(spin: self.stationPlayer.nowPlaying())
            }
            else if let _ = self.label as? NowPlayingTitleLabel
            {
                self.changeTitleLabel(spin: self.stationPlayer.nowPlaying())
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func setupListeners()
    {
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.setValue()
        })
    }
    
    //------------------------------------------------------------------------------
    
    func changeArtistLabel(spin:Spin?)
    {
        if let artistName = spin?.audioBlock?.artist
        {
            self.label?.changeText(text: artistName)
        }
        else
        {
            self.label?.changeText(text: self.blankText)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func changeTitleLabel(spin:Spin?)
    {
        if let title = spin?.audioBlock?.title
        {
            self.label?.changeText(text: title)
        }
        else
        {
            self.label?.changeText(text: self.blankText)
        }
    }
}
