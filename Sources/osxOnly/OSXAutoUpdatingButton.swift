//
//  AutoUpdatingButton.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/29/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

public class AutoUpdatingButton: NSButton {
    
    var isPlayingImage:NSImage?
    var isStoppedImage:NSImage?
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.commonInit()
    }
    
    public required init?(coder: NSCoder) {
        self.init(coder: coder)
        self.commonInit()
    }
    
    public func commonInit()
    {
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
