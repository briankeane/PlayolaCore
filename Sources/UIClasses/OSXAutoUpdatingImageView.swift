//
//  AutoUpdatingImageView.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa
import Kingfisher

public class AutoUpdatingImageView: NSImageView {

    public var emptyImage:NSImage?
    
    override public init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
    
    //------------------------------------------------------------------------------
    
    func commonInit()
    {
        
    }
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//    }
    
}
