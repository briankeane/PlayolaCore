//
//  PlayolaModelRefreshHandler.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class PlayolaModelRefreshHandler:NSObject
{
    // dependency injections:
    @objc var api:PlayolaAPI = PlayolaAPI.sharedInstance()

    override init()
    {
        super.init()
        self.setupListeners()
    }
    
    func setupListeners()
    {
        NotificationCenter.default.addObserver(forName: PlayolaEvents.userUpdateRequested, object: nil, queue: OperationQueue.main)
        {
            (notification) -> Void in
            if let userID = notification.userInfo?["userID"] as? String
            {
                self.updateUser(userID: userID)
            }
        }
    }
    
    func updateUser(userID:String)
    {
        self.api.getUser(userID: userID)
        .then
        {
            (user) -> Void in
            NotificationCenter.default.post(name: PlayolaEvents.userUpdated, object: nil, userInfo: ["user": user])
        }
        .catch
        {
            (err) -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0)
            {
                // in case of server error... wait 5 secs and try again
                self.updateUser(userID: userID)
            }
        }
    }
    
    
    //------------------------------------------------------------------------------
    //                  Singleton
    //------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the PlayolaModelRefreshHandler for all to use
    ///
    /// - returns:
    ///    `PlayolaModelRefreshHandler` - the PlayolaModelRefreshHandler
    ///
    /// ----------------------------------------------------------------------------
    class func sharedInstance() -> PlayolaModelRefreshHandler
    {
        if (self._instance == nil)
        {
            self._instance = PlayolaModelRefreshHandler()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:PlayolaModelRefreshHandler?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ refeshHandler:PlayolaModelRefreshHandler)
    {
        self._instance = refeshHandler
    }
}
