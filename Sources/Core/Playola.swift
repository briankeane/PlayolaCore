//
//  Playola.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 11/3/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class Playola:NSObject
{
    
    // -----------------------------------------------------------------------------
    //                          func initialize
    // -----------------------------------------------------------------------------
    /**
     Initializes the Playola library.  for now that means:
        * initialize PlayolaAPI  (which loads accessToken if it exists)
     */
    public static func initializeLibrary()
    {
        _ = Playola.sharedInstance()
        _ = PlayolaAPI.sharedInstance()
        _ = PlayolaCurrentUserInfoService.sharedInstance()
    }
    
    //------------------------------------------------------------------------------
    // Singleton
    //------------------------------------------------------------------------------
    
    public static var _instance:Playola?
    public static func sharedInstance() -> Playola
    {
        if let instance = self._instance
        {
            return instance
        }
        self._instance = Playola()
        return self._instance!
    }
}
