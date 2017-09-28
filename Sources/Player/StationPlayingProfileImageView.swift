//
//  StationPlayingProfileImageView.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/28/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class StationPlayingProfileImageView:AutoUpdatingImageView
{
    var imageUpdater:StationPlayingImageViewUpdater?
    
    override func commonInit()
    {
        super.commonInit()
        self.imageUpdater = StationPlayingImageViewUpdater(imageView: self)
        self.image = self.getPlaceholderImage()
    }
}
