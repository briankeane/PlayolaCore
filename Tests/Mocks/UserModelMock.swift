//
//  UserModelMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class UserMock:User
{
    var autoUpdatingStarted:Bool = false
    override func startAutoUpdating()
    {
        self.autoUpdatingStarted = true
    }
    
    var autoAdvancingStarted:Bool = false
    override func startAutoAdvancing()
    {
        self.autoAdvancingStarted = true
    }
    
    override func copy() -> User {
        let userCopy = super.copy()
        return UserMock(original: userCopy)
    }
}
