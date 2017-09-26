//
//  AutoUpdatingLabel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

class AutoUpdatingLabel: NSTextView {
    var labelUpdater:labelUpdater?
    var delegate:PlayolaAutoUpdatingLabelDelegate?
    {
        didSet
        {
            self.labelUpdater?.setValue()
        }
    }
    
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
    
    //    override func draw(_ dirtyRect: NSRect) {
    //        super.draw(dirtyRect)
    //
    //        // Drawing code here.
    //    }
    //    
}
