//
//  PlayolaErrorType.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/21/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

enum PlayolaErrorType:Error, Equatable
{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: PlayolaErrorType, rhs: PlayolaErrorType) -> Bool {
        switch (lhs, rhs)
        {
        case (.playlistInitRequired, .playlistInitRequired):
            return true
        default:
            return false
        }
    }
    /// the playlist must be initialized before this function is performed
    case playlistInitRequired
}
