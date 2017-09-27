//
//  LabelUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class NowPlayingLabelUpdater:NSObject
{
    weak var label:NowPlayingLabel?
   
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
    
    init(label:NowPlayingLabel)
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
            else if let _ = self.label as? NowPlayingTitleAndArtistLabel
            {
                self.changeTitleAndArtistLabel(spin: self.stationPlayer.nowPlaying())
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
            if let blankText = self.label?.blankText
            {
                self.label?.changeText(text: blankText)
            }
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
            if let blankText = self.label?.blankText
            {
                self.label?.changeText(text: blankText)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func changeTitleAndArtistLabel(spin:Spin?)
    {
        if let audioBlock = spin?.audioBlock
        {
            if (audioBlock.isCommercialBlock)
            {
                self.label?.changeText(text: "Commercials")
            }
            else if (audioBlock.__t == "Commentary")
            {
                self.label?.changeText(text: "VoiceTrack")
            }
            else if ((audioBlock.title != nil) && (audioBlock.artist != nil))
            {
                self.label?.changeText(text: "\(audioBlock.title!) - \(audioBlock.artist!)")
            }
            else if (audioBlock.title != nil)
            {
                self.label?.changeText(text: "\(audioBlock.title!)")
            }
            else if (audioBlock.artist != nil)
            {
                self.label?.changeText(text: "\(audioBlock.artist!)")
            }
            else
            {
               self.label?.changeText(text: "")
            }
        }
        else
        {
            self.label?.changeText(text: "-----")
        }
    }
}
