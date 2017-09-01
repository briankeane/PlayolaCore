//
//  PlayolaListeningSessionReporter.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/31/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PlayolaListeningSessionReporter:NSObject
{
    // dependency injections
    var api:PlayolaAPI! = PlayolaAPI()
    var currentUserInfo:PlayolaCurrentUserInfoService! = PlayolaCurrentUserInfoService.sharedInstance()
    
    func injectDependencies(api:PlayolaAPI=PlayolaAPI(), currentUserInfo:PlayolaCurrentUserInfoService=PlayolaCurrentUserInfoService.sharedInstance())
    {
        self.api = api
        self.currentUserInfo = currentUserInfo
    }
    
    
    
    
}
