//
//  OSXAutoUpdatingImageView.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa
import Kingfisher

public class AutoUpdatingImageView: NSImageView {

    public var placeholderImage:NSImage?
    public var notPlayingImage:NSImage?
    public var withGradient:Bool = true
    
    private var _gradient:CAGradientLayer?
    
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
        if (self.withGradient)
        {
            self.addGradientLayer()
        }
    }
    
    func getPlaceholderImage() -> NSImage
    {
        if let userSuppliedPlaceholderImage = self.placeholderImage
        {
            return userSuppliedPlaceholderImage
        }
        return NSImage.makePlayolaImage(name: "emptyAlbum")!
    }
    
    func getNotPlayingImage() -> NSImage
    {
        if let userSuppliedNotPlayingImage = self.notPlayingImage
        {
            return userSuppliedNotPlayingImage
        }
        return NSImage.makePlayolaImage(name: "emptyStation")!
    }
    
    func addGradientLayer()
    {
        if (self._gradient == nil)
        {
            let gradient = CAGradientLayer()
            gradient.frame = self.frame
            gradient.colors = [NSColor.black.cgColor, NSColor.clear.cgColor]
            gradient.locations = [0.0, 0.5]
            self.layer?.addSublayer(gradient)
            self._gradient = gradient
        }
    }
    
//    override func draw(_ dirtyRect: NSRect) {
//        super.draw(dirtyRect)
//    }
    
}
