//
//  AutoUpdatingPlayButtonWithImage.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/30/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
public class AutoUpdatingPlayButtonWithImage:AutoUpdatingButton
{
    var updater:PlayButtonUpdater?
    public var userID:String?
    
    public var isStoppedText:String?
    public var isPlayingText:String?
    
    override public func commonInit()
    {
        self.updater = PlayButtonUpdater(playButton: self)
    }
}
