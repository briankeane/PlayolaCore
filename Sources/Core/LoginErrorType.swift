//
//  LoginErrorType.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/18/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public enum LoginErrorType:Error, Equatable
{
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: LoginErrorType, rhs: LoginErrorType) -> Bool {
        switch (lhs, rhs)
        {
        case (.emailNotRegistered, .emailNotRegistered):
            return true
        case (.passwordIncorrect, .passwordIncorrect):
            return true
        case (.passcodeIncorrect, .passcodeIncorrect):
            return true
        default:
            return false
        }
    }
    
    /// the email was not found -- corresponds to loginRejectionCode 1 on the server
    case emailNotRegistered
    
    /// the password was incorrect -- corresponds to loginRejectionCode 2 on the server
    case passwordIncorrect
    
    /// the passcode was incorrect and the user could not be created.
    case passcodeIncorrect
}
