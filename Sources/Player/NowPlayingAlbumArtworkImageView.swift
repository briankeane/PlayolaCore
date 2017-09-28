//
//  NowPlayingAlbumArtworkImageView.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

public class NowPlayingAlbumArtworkImageView: NowPlayingImageView
{
    override func commonInit()
    {
        super.commonInit()
        self.image = self.getPlaceholderImage()
    }
}
