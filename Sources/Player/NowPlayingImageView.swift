//
//  NowPlayingImageView.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class NowPlayingImageView:AutoUpdatingImageView
{
    var imageViewUpdater:NowPlayingImageViewUpdater?
    
    override func commonInit()
    {
        super.commonInit()
        self.imageViewUpdater = NowPlayingImageViewUpdater(imageView: self)
    }
}
