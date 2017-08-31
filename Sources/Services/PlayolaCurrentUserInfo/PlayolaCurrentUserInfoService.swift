//
//  PlayolaCurrentUserInfoService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class PlayolaCurrentUserInfoService:NSObject
{
    override init() {
        super.init()
        self.setupListeners()
    }
    
    var user:User?
    
    func setupListeners()
    {
        // Listen for user-modifying updates
        NotificationCenter.default.addObserver(forName: PlayolaEvents.getCurrentUserReceived, object: nil, queue: .main)
        {
            (notification) -> Void in
            if let userInfo = notification.userInfo
            {
                if let user = userInfo["user"] as? User
                {
                    self.updateCurrentUser(user)
                }
            }
        }
    }
    
    // update current user if it is more recent than the currently stored version.
    func updateCurrentUser(_ newCurrentUser:User)
    {
        if let newUpdatedAt = newCurrentUser.updatedAt
        {
            if ((self.user?.updatedAt == nil) || (newUpdatedAt.isAfter(self.user!.updatedAt!)))
            {
                self.user = newCurrentUser
                NotificationCenter.default.post(name: PlayolaEvents.currentUserUpdated, object: nil, userInfo: ["currentUser": newCurrentUser as Any])
            }
        }
    }
    
    
    //------------------------------------------------------------------------------
    //                  Singleton
    //------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the AuthService for all to use
    ///
    /// - returns:
    ///    `AuthService` - the central Auth Service instance
    ///
    /// ----------------------------------------------------------------------------
    class func sharedInstance() -> PlayolaCurrentUserInfoService
    {
        if (self._instance == nil)
        {
            self._instance = PlayolaCurrentUserInfoService()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:PlayolaCurrentUserInfoService?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ authService:PlayolaCurrentUserInfoService)
    {
        self._instance = authService
    }
}