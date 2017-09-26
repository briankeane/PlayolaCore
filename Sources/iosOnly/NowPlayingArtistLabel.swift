//
//  NowPlayingArtistLabel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

class NowPlayingArtistLabel: UILabel {
    var labelUpdater:LabelUpdater?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit()
    {
        self.labelUpdater = LabelUpdater(label: self)
    }
}
