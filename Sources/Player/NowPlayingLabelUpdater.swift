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
        if let text = self.label?.autoUpdatingDelegate?.alternateDisplayText?(self.label!, audioBlockDict: self.stationPlayer.nowPlaying()?.audioBlock?.toDictionary(), defaultText:self.defaultText())
        {
            self.label?.changeText(text: text)
        }
        else
        {
            self.label?.changeText(text: self.defaultText())
        }
    }
    
    //------------------------------------------------------------------------------
    
    func defaultText() -> String
    {
        if let _ = self.label as? NowPlayingArtistLabel
        {
            return self.artistDefaultText(spin: self.stationPlayer.nowPlaying())
        }
        else if let _ = self.label as? NowPlayingTitleLabel
        {
            return self.titleDefaultText(spin: self.stationPlayer.nowPlaying())
        }
        else if let _ = self.label as? NowPlayingTitleAndArtistLabel
        {
            return self.titleAndArtistDefaultText(spin: self.stationPlayer.nowPlaying())
        }
        return ""
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
    
    func artistDefaultText(spin:Spin?) -> String
    {
        if let artistName = spin?.audioBlock?.artist
        {
            return artistName
        }
        else
        {
            if let blankText = self.label?.blankText
            {
                return blankText
            }
        }
        return ""
    }
    
    //------------------------------------------------------------------------------
    
    func titleDefaultText(spin:Spin?) -> String
    {
        if let title = spin?.audioBlock?.title
        {
            return title
        }
        else
        {
            if let blankText = self.label?.blankText
            {
                return blankText
            }
        }
        return ""
    }
    
    //------------------------------------------------------------------------------
    
    func titleAndArtistDefaultText(spin:Spin?) -> String
    {
        if let audioBlock = spin?.audioBlock
        {
            if (audioBlock.isCommercialBlock)
            {
                return "Commercials"
            }
            else if (audioBlock.__t == .voiceTrack)
            {
                return "VoiceTrack"
            }
            else if ((audioBlock.title != nil) && (audioBlock.artist != nil))
            {
                return "\(audioBlock.title!) - \(audioBlock.artist!)"
            }
            else if (audioBlock.title != nil)
            {
                return "\(audioBlock.title!)"
            }
            else if (audioBlock.artist != nil)
            {
                return "\(audioBlock.artist!)"
            }
            else
            {
               return ""
            }
        }
        else
        {
            return self.label!.blankText
        }
    }
}
