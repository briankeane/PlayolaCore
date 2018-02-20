//
//  PlayolaCurrentUserInfoService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit

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
    
    open var lastSeenAirtime:Date?
    open var shouldShowSchedule:Bool = false
    
    open var favorites:[User]? = nil
    open var rotationItemsCollection:RotationItemsCollection? = nil
    open var favoritesRetrievalError:APIError? = nil
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
        
        // change lastSeenAirtime on shuffle
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.playlistShuffled, object: nil, queue: .main)
        {
            (notification) -> Void in
            if let firstDifferentSpin = notification.userInfo?["firstDifferentSpin"] as? Spin
            {
                if let airtime = firstDifferentSpin.airtime
                {
                    self.lastSeenAirtime = airtime
                    self.shouldShowSchedule = false
                }
            }
        })
        
        // Clear on sign out
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.signedOut, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.user = nil
            self.favorites = nil
            self.lastSeenAirtime = nil
        })
        
        // get the presets and rotationItems on signedIn
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.signedIn, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.getPresets()
            self.getRotationItemsCollection()
        })
        
        // get rotationItems on .stationStarted
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.stationStarted, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.getRotationItemsCollection()
        })
        
        // update the favorites when a new version is received
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.currentUserPresetsReceived, object: nil, queue: .main)
        {
            (notification) -> Void in
            if let favorites = notification.userInfo?["favorites"] as? [User]
            {
                self.updatePresets(favorites: favorites, error: nil)
            }
        })
        
        // store last viewed airtime if it's latest
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaEvents.playlistViewedAtAirtime, object: nil, queue: .main)
        {
            (notification) in
            if let airtime = notification.userInfo?["airtime"] as? Date
            {
                self.lastSeenAirtimeReported(airtime: airtime)
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
    
    open func deactivateRotationItem(rotationItemID:String) -> Promise<RotationItemsCollection>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
            if let oldRotationItem = self.rotationItemsCollection?.getRotationItem(rotationItemID: rotationItemID)
            {
                oldRotationItem.removalInProgress = true
                self.updateRotationItemsCollection(rotationItemsCollection: self.rotationItemsCollection!)
                self.api.removeRotationItemsAndReset(rotationItemIDs: [rotationItemID])
                .then
                {
                    (rotationItemsCollection) -> Void in
                    self.updateRotationItemsCollection(rotationItemsCollection: rotationItemsCollection)
                    return fulfill(rotationItemsCollection)
                }
                .catch
                {
                    (error) -> Void in
                    oldRotationItem.removalInProgress = false
                    self.updateRotationItemsCollection(rotationItemsCollection: self.rotationItemsCollection!)
                    reject(error)
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func lastSeenAirtimeReported(airtime:Date)
    {
        // if an airtime exists and it is later than the provided one,
        // just exit
        if let oldAirtime = self.lastSeenAirtime
        {
            if (oldAirtime > airtime)
            {
                return
            }
        }
        self.shouldShowSchedule = true
        self.lastSeenAirtime = airtime
    }
    
    //------------------------------------------------------------------------------
    
    open func createRotationItems(songIDs:[String]) -> Promise<RotationItemsCollection>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
            self.api.addSongsToBin(songIDs: songIDs, bin: "light")
            .then
            {
                (rotationItemsCollection) -> Void in
                self.updateRotationItemsCollection(rotationItemsCollection: rotationItemsCollection)
                fulfill(rotationItemsCollection)
            }
            .catch
            {
                (error) -> Void in
                reject(error)
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
                else if ((oldUser?.program == nil) && (oldUser?.program != nil))
                {
                    NotificationCenter.default.post(name: PlayolaEvents.stationStarted, object: nil)
                    self.getRotationItemsCollection()
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
            (favorites) -> Void in
            self.updatePresets(favorites: favorites, error: nil)
        }
        .catch
        {
            (error) -> Void in
            self.updatePresets(favorites: nil, error: (error as? APIError))
        }
    }
    
    //------------------------------------------------------------------------------
    
    func getRotationItemsCollection()
    {
        self.api.getRotationItems()
        .then
        {
            (rotationItemsCollection) -> Void in
            self.updateRotationItemsCollection(rotationItemsCollection: rotationItemsCollection)
        }
    }
    
    //------------------------------------------------------------------------------
    
    open func isInPresets(userID:String?) -> Bool
    {
        if let favorites = self.favorites, let userID = userID
        {
            for preset in favorites
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
    
    private func updatePresets(favorites:[User]?, error:APIError?)
    {
        if let error = error
        {
            self.favoritesRetrievalError = error
        }
        else
        {
            self.favoritesRetrievalError = nil
            self.favorites = favorites
            NotificationCenter.default.post(name: PlayolaEvents.favoritesUpdated, object: nil, userInfo: ["favorites": favorites as Any])
        }
    }
    
    //------------------------------------------------------------------------------
    
    private func updateRotationItemsCollection(rotationItemsCollection:RotationItemsCollection)
    {
        self.rotationItemsCollection = rotationItemsCollection
        NotificationCenter.default.post(name: PlayolaEvents.rotationItemsCollectionUpdated, object: nil, userInfo: ["rotationItemsCollection": rotationItemsCollection])
    }
    
    //------------------------------------------------------------------------------
    
    open func hasRunningStation() -> Bool
    {
        return (self.user?.program?.playlist != nil)    
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
    
    //------------------------------------------------------------------------------
    
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
    ///    `PlayolaCurrentUserInfoService` - the central PlayolaCurrentUserInfoService instance
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
    /// replaces the Singleton shared instance of the PlayolaCurrentUserInfoService class
    ///
    /// - parameters:
    ///     - DateHandler: `(PlayolaCurrentUserInfoService)` - the new PlayolaCurrentUserInfoService
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
