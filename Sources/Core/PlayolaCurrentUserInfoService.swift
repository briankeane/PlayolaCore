//
//  PlayolaCurrentUserInfoService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
#if os(OSX)
    import Cocoa
#elseif os(iOS)
    import UIKit
#endif

@objc open class PlayolaCurrentUserInfoService:NSObject
{
    public override init() {
        super.init()
        self.setupListeners()
        self.initializeInfo()
    }
    
    private var _user:User?
    open var user:User?
    {
        get
        {
            return self._user
        }
        set
        {
            self._user?.clearOnNowPlayingAdvanced()
            
            newValue?.startAutoUpdating()
            newValue?.startAutoAdvancing()
            self._user = newValue
            self._user?.onNowPlayingAdvanced()
            {
                (user) in
                self.nowPlayingAdvanced()
            }
        }
    }
    open var presets:[User]? = nil
    open var presetsRetrievalError:APIError? = nil
    fileprivate var observers:[NSObjectProtocol] = Array()
    
    
    // dependency injections
    @objc var api:PlayolaAPI = PlayolaAPI.sharedInstance()

    //------------------------------------------------------------------------------
    
    open func setupListeners()
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
        
        // Clear on sign out
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.signedOut, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.user = nil
            self.presets = nil
        })
        
        // get the presets on signedIn
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.signedIn, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.getPresets()
        })
        
        // update the presets when a new version is received
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserPresetsReceived, object: nil, queue: .main)
        {
            (notification) -> Void in
            if let presets = notification.userInfo?["presets"] as? [User]
            {
                self.updatePresets(presets: presets, error: nil)
            }
        })
    }
    
    //------------------------------------------------------------------------------
    
    open func initializeInfo()
    {
        if (self.api.isSignedIn())
        {
            self.api.getMe()
            .then
            {
                (user) -> Void in
                self.updateCurrentUser(user)
            }
            .catch
            {
                (error) -> Void in
                print(error)
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    // update current user if it is more recent than the currently stored version.
    func updateCurrentUser(_ newCurrentUser:User)
    {
        let oldUser = self.user
        
        if let newUpdatedAt = newCurrentUser.updatedAt
        {
            if ((self.user?.updatedAt == nil) || (newUpdatedAt.isAfter(self.user!.updatedAt!)))
            {
                self.user = newCurrentUser
                NotificationCenter.default.post(name: PlayolaEvents.currentUserUpdated, object: nil, userInfo: ["currentUser": newCurrentUser as Any])
                // if the oldUser is nil, we've just logged in
                if (oldUser == nil)
                {
                    NotificationCenter.default.post(name: PlayolaEvents.signedIn, object: nil, userInfo:["user": newCurrentUser as Any])
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func getPresets()
    {
        self.api.getPresets()
        .then
        {
            (presets) -> Void in
            self.updatePresets(presets: presets, error: nil)
        }
        .catch
        {
            (error) -> Void in
            self.updatePresets(presets: nil, error: (error as? APIError))
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func isInPresets(userID:String?) -> Bool
    {
        if let presets = self.presets, let userID = userID
        {
            for preset in presets
            {
                if let id = preset.id
                {
                    if (id == userID)
                    {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    private func updatePresets(presets:[User]?, error:APIError?)
    {
        if let error = error
        {
            self.presetsRetrievalError = error
        }
        else
        {
            self.presetsRetrievalError = nil
            self.presets = presets
            NotificationCenter.default.post(name: PlayolaEvents.presetsUpdated, object: nil, userInfo: ["presets": presets])
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func isSignedIn() -> Bool
    {
        return (self.user != nil)
    }
    
    //------------------------------------------------------------------------------
    
    public func getDeviceID() -> String?
    {
        return uniqueIdentifier()
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
    
    func nowPlayingAdvanced()
    {
        NotificationCenter.default.post(name: PlayolaEvents.currentUserPlaylistAdvanced, object: nil, userInfo: ["user": self.user as Any])
    }
}

#if os(OSX)
    func uniqueIdentifier() -> String?
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
    func uniqueIdentifier() -> String?
    {
        if let deviceID = UIDevice.current.identifierForVendor?.uuidString
        {
            return deviceID
        }
        return nil
    }
#endif
fileprivate let createInstance = PlayolaCurrentUserInfoService.sharedInstance()
