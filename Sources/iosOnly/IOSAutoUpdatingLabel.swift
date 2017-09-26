//
//  AutoUpdatingLabel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

class AutoUpdatingLabel: UILabel
{
    var labelUpdater:LabelUpdater?
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
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
