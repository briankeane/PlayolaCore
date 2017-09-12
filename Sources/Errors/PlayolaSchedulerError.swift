//
//  PlayolaSchedulerError.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/11/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class SchedulerError:NSObject, Error
{
    /// message if provided
    var message:String?
    
    var type:SchedulerErrorType
    
    init(type:SchedulerErrorType, message:String?=nil)
    {
        self.type = type
        self.message = message
    }
}
