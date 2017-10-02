//
//  RemoteFilePriorityLevel.swift
//  SwiftRemoteFileCache
//
//  Created by Brian D Keane on 8/21/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public enum RemoteFilePriorityLevel:Int
{
    case doNotDelete = 10
    case high = 8
    case medium = 5
    case low = 1
    case unspecified = 0
}
