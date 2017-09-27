//
//  StationPlayingLabel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

public class StationPlayingLabel:AutoUpdatingLabel
{
    var labelUpdater:StationPlayingLabelUpdater?
    var autoUpdatingDelegate:StationPlayingLabelDelegate?
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
        self.labelUpdater = StationPlayingLabelUpdater(label: self)
    }
}
