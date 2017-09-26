//
//  LabelUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

class LabelUpdater:NSObject
{
    weak var label:UILabel?

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
    
    init(label:UILabel)
    {
        super.init()
        self.label = label
        self.setInitialValue()
        self.setupListeners()
    }
    
    deinit
    {
        self.removeObservers()
    }
    
    //------------------------------------------------------------------------------
    
    func setInitialValue()
    {
        if let artistLabel = self.label as? NowPlayingArtistLabel
        {
            self.changeArtistLabel(spin: self.stationPlayer.nowPlaying())
        }
    }
    
    //------------------------------------------------------------------------------
    
    func setupListeners()
    {
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.processNowPlayingChanged(notification:notification)
        })
    }
    
    //------------------------------------------------------------------------------
    
    func processNowPlayingChanged(notification:Notification)
    {
        if let userInfo = notification.userInfo
        {
            if let _ = self.label as? NowPlayingArtistLabel
            {
                if let spin = userInfo["spin"] as? Spin
                {
                    self.changeArtistLabel(spin: spin)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func changeArtistLabel(spin:Spin?)
    {
        if let artistName = spin?.audioBlock?.artist
        {
            self.changeLabelText(text: artistName)
        }
        else
        {
            self.changeLabelText(text: self.blankText)
        }
    }
    
    //------------------------------------------------------------------------------
    
    func changeLabelText(text:String)
    {
        DispatchQueue.main.async
        {
            self.label?.text = text
        }
    }
}
