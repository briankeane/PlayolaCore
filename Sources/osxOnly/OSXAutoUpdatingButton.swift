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
    
    public required convenience init?(coder: NSCoder) {
        self.init(coder: coder)
        self.commonInit()
    }
    
    public func commonInit()
    {
        
    }
    
    public func setImage(image:NSImage?)
    {
        if let image = image
        {
            self.image = image
        }
    }
    
    public func setTitle(title:String?)
    {
        if let title = title
        {
            self.title = title
        }
    }
    
    public func getTitle() -> String?
    {
        return self.title
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    public func getIsPlayingImage() -> NSImage
    {
        return NSImage()
    }
    
    public func getIsStoppedImage() -> NSImage
    {
        return NSImage()
    }
    
}
