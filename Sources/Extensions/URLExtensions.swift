//
//  URLExtensions.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/2/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation


extension URL
{
    init?(stringOptional:String?)
    {
        if (stringOptional != nil)
        {
            self.init(string: stringOptional!)
        }
        return nil
    }
}
