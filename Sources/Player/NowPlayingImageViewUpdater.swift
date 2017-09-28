//
//  NowPlayingImageViewUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Kingfisher

#if os(iOS)
import UIKit
#elseif os(OSX)
import AVKit
#endif

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
        self.imageView?.kf.indicatorType = .activity
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
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.setValue()
        })
    }
    
    //------------------------------------------------------------------------------
    
    func setValue()
    {
        if let imageURL = self.stationPlayer.nowPlaying()?.audioBlock?.albumArtworkUrl
        {
            self.imageView?.kf.setImage(with: imageURL, options: [.transition(.fade(0.2))])
            {
                (image, error, cacheType, imageUrl) -> Void in
                // IF there was an error getting the image, go back to the placeholder
                if (image == nil)
                {
                    self.imageView?.image = self.getPlaceholderImage()
                }
            }
            
        }
        else
        {
            self.imageView?.image = self.getPlaceholderImage()
        }
    }
    
    //------------------------------------------------------------------------------
    #if os(iOS)
    func getPlaceholderImage() -> UIImage
    {
        if let userSuppliedPlaceholderImage = self.imageView?.placeholderImage
        {
            return userSuppliedPlaceholderImage
        }
        return UIImage.make(name: "missingAlbumIcon.png")!
    }
    #endif
    
    #if os(OSX)
    func getPlaceholderImage() -> NSImage
    {
        if let userSuppliedPlaceholderImage = self.imageView?.placeholderImage
        {
            return userSuppliedPlaceholderImage
        }
        return NSImage(named: "missingAlbumIcon.png")!
    }
    #endif
    
    //------------------------------------------------------------------------------
    
    
  
    
}

#if os(iOS)
public extension UIImage {
    static func make(name: String) -> UIImage? {
            
        let bundle = Bundle(for: NowPlayingImageViewUpdater.self)
        return UIImage(named: "PlayolaImages.bundle/\(name)", in: bundle, compatibleWith: nil)
    }
}
#endif
