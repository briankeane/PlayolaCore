//
//  IOSAutoUpdatingLabel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import UIKit

public class AutoUpdatingLabel: UILabel
{    
    /// the String to display when the represented value is nil
    public var blankText:String = "---------"
    
    
    
    //------------------------------------------------------------------------------
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    //------------------------------------------------------------------------------
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    /// NOTE: SUBCLASSES SHOULD OVERRIDE THIS INITIALIZER IN ORDER TO CREATE AND ATTACH THE PROPER TYPE OF LABELUPDATER
    func commonInit()
    {
        /// NOTE: SUBCLASSES SHOULD OVERRIDE THIS INITIALIZER IN ORDER TO CREATE AND ATTACH THE PROPER TYPE OF LABELUPDATER
    }
    
    func changeText(text:String)
    {
        DispatchQueue.main.async
        {
            self.text = text
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
