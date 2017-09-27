//
//  AutoUpdatingLabel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

public class AutoUpdatingLabel: NSTextView
{
    /// same as the 'string' property -- provided to preserve common api for osx and ios
    public var text:String?
    {
        get
        {
            return self.string
        }
    }
    
    /// the String to display when the represented value is nil
    public var blankText:String = "---------"
    
    //------------------------------------------------------------------------------
    
    override init(frame frameRect: NSRect, textContainer aTextContainer: NSTextContainer!)
    {
        super.init(frame: frameRect, textContainer: aTextContainer)
        self.commonInit()
    }
    
    //------------------------------------------------------------------------------
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    //------------------------------------------------------------------------------
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.commonInit()
    }
    
    //------------------------------------------------------------------------------
    
    /// NOTE: SUBCLASSES SHOULD OVERRIDE THIS INITIALIZER IN ORDER TO CREATE AND ATTACH THE PROPER TYPE OF LABELUPDATER
    func commonInit()
    {
        /// NOTE: SUBCLASSES SHOULD OVERRIDE THIS INITIALIZER IN ORDER TO CREATE AND ATTACH THE PROPER TYPE OF LABELUPDATER
    }
    
    //------------------------------------------------------------------------------
    
    func changeText(text:String)
    {
        DispatchQueue.main.async
        {
            self.string = text
        }
    }
    
    //------------------------------------------------------------------------------
    
    //    override func draw(_ dirtyRect: NSRect) {
    //        super.draw(dirtyRect)
    //
    //        // Drawing code here.
    //    }
    //    
}
