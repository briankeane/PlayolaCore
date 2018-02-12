//
//  SongStatus.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 12/5/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public enum SongStatus:Int
{
    case songExists = 9001
    case processing = 9203
    case failedToAcquire = 9400
    case notFound = 9404
    
    // not backend related
    case addingToCollection = 20000
    case removingFromCollection = 20001
}
