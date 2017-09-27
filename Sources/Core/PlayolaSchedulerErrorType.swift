//
//  PlayolaSchedulerErrorType.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

enum SchedulerErrorType:Error, Equatable
{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: SchedulerErrorType, rhs: SchedulerErrorType) -> Bool {
        switch (lhs, rhs)
        {
        case (.spinNotFound, .spinNotFound):
            return true
        case (.invalidPlaylistPosition, .invalidPlaylistPosition):
            return true
        default:
            return false
        }
    }
    
    /// the spin was not found in the playlist
    case spinNotFound
    
    /// the desired playlistPosition is invalid (too early or too late)
    case invalidPlaylistPosition
}
