//
//  IOSUIImageExtension.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/28/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage
{
    static func make(name: String) -> UIImage?
    {
        let bundle = Bundle(for: NowPlayingImageViewUpdater.self)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
