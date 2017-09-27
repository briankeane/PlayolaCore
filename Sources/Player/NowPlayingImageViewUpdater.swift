//
//  NowPlayingImageViewUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Kingfisher

class NowPlayingImageViewUpdater:NSObject
{
    weak var imageView:NowPlayingImageView?
    
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
    
    init(imageView:NowPlayingImageView)
    {
        super.init()
        self.imageView = imageView
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
        func setupListeners()
        {
            self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, queue: .main)
            {
                (notification) -> Void in
                self.setValue()
            })
        }
    }
    
    //------------------------------------------------------------------------------
    
    func setValue()
    {
        if let imageURL = self.stationPlayer.nowPlaying()?.audioBlock?.albumArtworkUrl
        {
            self.imageView?.kf.setImage(with: imageURL)
        }
        
    }
}
