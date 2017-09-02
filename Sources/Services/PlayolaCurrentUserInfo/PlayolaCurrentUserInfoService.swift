//
//  PlayolaCurrentUserInfoService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Locksmith

// Unique Identifier
#if os(OSX)
    import Cocoa

    func uniqueIdentifier() ->String?
    {
        // Get the platform expert
        let platformExpert: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    
        // Get the serial number as a CFString ( actually as Unmanaged<AnyObject>! )
        let serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0);
    
        // Release the platform expert (we're responsible)
        IOObjectRelease(platformExpert);
    
        // Take the unretained value of the unmanaged-any-object
        // (so we're not responsible for releasing it)
        // and pass it back as a String or, if it fails, an empty string
        return (serialNumberAsCFString?.takeUnretainedValue() as? String)
    }
    
#elseif os(iOS)
    import UIKit
    func uniqueIdentifier() -> String?
    {
        
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString
        {
            return deviceID
        }
        return nil
    }
    
#endif

public class PlayolaCurrentUserInfoService:NSObject
{
    override init() {
        super.init()
        self.setupListeners()
        self.checkForStoredAccessToken()
    }
    
    var user:User?
    var accessToken:String?
    fileprivate var observers:[NSObjectProtocol] = Array()
    
    //------------------------------------------------------------------------------
    
    func setupListeners()
    {
        // Listen for user-modifying updates
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.getCurrentUserReceived, object: nil, queue: .main)
        {
            (notification) -> Void in
            if let userInfo = notification.userInfo
            {
                if let user = userInfo["user"] as? User
                {
                    self.updateCurrentUser(user)
                }
            }
        })
    }
    
    //------------------------------------------------------------------------------
    
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
    
    public func isSignedIn() -> Bool
    {
        return (self.user != nil)
    }
    
    //------------------------------------------------------------------------------
    
    public func getDeviceID() -> String?
    {
        return uniqueIdentifier()
    }
    
    //------------------------------------------------------------------------------
    
    public func getPlayolaAuthorizationToken() -> String?
    {
        return self.accessToken
    }
    
    //------------------------------------------------------------------------------
    
    public func setPlayolaAuthorizationToken(accessToken:String?)
    {
        self.accessToken = accessToken
        try! Locksmith.updateData(data: ["accessToken":accessToken as Any], forUserAccount: "fm.playola")
    }
    
    //------------------------------------------------------------------------------
    
    func checkForStoredAccessToken()
    {
        let dictionary = Locksmith.loadDataForUserAccount(userAccount: "fm.playola")
        if let dictionary = dictionary
        {
            if let accessToken = dictionary["accessToken"] as? String
            {
                self.accessToken = accessToken
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func deleteObservers()
    {
        for observer in self.observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    deinit
    {
        self.deleteObservers()
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
    public class func sharedInstance() -> PlayolaCurrentUserInfoService
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
