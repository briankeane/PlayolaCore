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
    static func make(name: String) -> UIImage?
    {
        let bundle = Bundle(for: NowPlayingImageViewUpdater.self)
        return NSImage(named: "PlayolaImages.bundle/\(name)", in: bundle, compatibleWith: nil)
    }
}
