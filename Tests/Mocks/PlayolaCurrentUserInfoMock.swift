//
//  PlayolaCurrentUserInfoMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/31/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PlayolaCurrentUserInfoMock:PlayolaCurrentUserInfoService
{
    var shouldSetupListeners:Bool = false
    
    // avoid listeners by default
    override func setupListeners()
    {
        if (self.shouldSetupListeners)
        {
            super.setupListeners()
        }
    }
    
    var deviceIDToProvide:String?
    override public func getDeviceID() -> String? {
        return deviceIDToProvide
    }
}
