//
//  StationPlayingLabelUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//
import Foundation

class StationPlayingLabelUpdater: NSObject
{
    weak var label:StationPlayingLabel?
    
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
    
    init(label:StationPlayingLabel)
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
    
    func setupListeners()
    {
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.stationChanged, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.setValue()
        })
    }
    
    //------------------------------------------------------------------------------
    
    func setValue()
    {
        // IF there's a delegate representation
       if let text = self.label?.autoUpdatingDelegate?.alternateDisplayText?(self.label!, userPlayingDict: self.stationPlayer.userPlaying?.toDictionary())
        {
            self.label?.changeText(text: text)
        }
        else
        {
            if let _ = self.label as? StationPlayingLabel
            {
                self.changeStationPlayingLabel(user: self.stationPlayer.userPlaying)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func changeStationPlayingLabel(user:User?)
    {
        if let label = self.label
        {
            if let user = user
            {
                if let displayName = user.displayName
                {
                    self.label?.changeText(text: displayName)
                }
                else
                {
                    self.label?.changeText(text: "")
                }
            }
            else
            {
                self.label?.changeText(text: self.label!.blankText)
            }
        }
    }
}
