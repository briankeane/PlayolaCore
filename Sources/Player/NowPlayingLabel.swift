//
//  NowPlayingLabel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class NowPlayingLabel:AutoUpdatingLabel
{
    override public var blankText:String
    {
        didSet {
            self.labelUpdater?.setValue()
        }
    }
    
    var labelUpdater:NowPlayingLabelUpdater?
    var autoUpdatingDelegate:NowPlayingLabelDelegate?
    {
        // ensure the label text is set anytime the delegate is initiated or changed
        didSet
        {
            self.labelUpdater?.setValue()
        }
    }
    
    override func commonInit()
    {
        super.commonInit()
        self.labelUpdater = NowPlayingLabelUpdater(label: self)
    }
}
