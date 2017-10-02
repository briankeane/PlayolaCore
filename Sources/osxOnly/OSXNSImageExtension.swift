//
//  OSXNSImageExtension.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/28/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Cocoa

public extension NSImage
{
    static func makePlayolaImage(name: String) -> NSImage?
    {
        let bundle = Bundle(for: NowPlayingImageViewUpdater.self)
        let imagePath:String = bundle.pathForImageResource(name)!
        return NSImage(contentsOfFile: imagePath)
    }
}
