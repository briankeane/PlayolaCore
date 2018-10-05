//
//  PlayolaCurrentUserInfoService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/24/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON

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
            self.setStationStatus()
        }
    }
    
    open var lastSeenAirtime:Date?
    open var shouldShowSchedule:Bool = false
    
    open var favorites:[User]? = nil
    open var rotationItemsCollection:RotationItemsCollection? = nil
    open var favoritesRetrievalError:APIError? = nil
    fileprivate var observers:[NSObjectProtocol] = Array()
    
    // stationStatus monitoring
    open var minimumSongsNeeded:Int = 90
    var addedSongs:[String:AudioBlock] = Dictionary() {
        didSet {
            self.broadcastSongsAcquired()
        }
    }
    var songIDsAlreadyBroadcast:Set<String> = Set()
    var counts:JSON?
    var _previousStationStatus:StationStatus?
    open var stationStatus:StationStatus {
        get {
            return self.calculateStationStatus()
        }
    }
    open var completedSongCount:Int {
        get {
            return self.songIDsAlreadyBroadcast.count
        }
    }
    
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
            self._user = nil
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
            .done
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
            (seal) -> Void in
            if let oldRotationItem = self.rotationItemsCollection?.getRotationItem(rotationItemID: rotationItemID)
            {
                oldRotationItem.removalInProgress = true
                self.updateRotationItemsCollection(rotationItemsCollection: self.rotationItemsCollection!)
                self.api.removeRotationItemsAndReset(rotationItemIDs: [rotationItemID])
                .done
                {
                    (rotationItemsCollection) -> Void in
                    self.updateRotationItemsCollection(rotationItemsCollection: rotationItemsCollection)
                    return seal.fulfill(rotationItemsCollection)
                }
                .catch
                {
                    (error) -> Void in
                    oldRotationItem.removalInProgress = false
                    self.updateRotationItemsCollection(rotationItemsCollection: self.rotationItemsCollection!)
                    seal.reject(error)
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
            (seal) -> Void in
            self.api.addSongsToBin(songIDs: songIDs, bin: "light")
            .done
            {
                (rotationItemsCollection) -> Void in
                self.updateRotationItemsCollection(rotationItemsCollection: rotationItemsCollection)
                seal.fulfill(rotationItemsCollection)
            }
            .catch
            {
                (error) -> Void in
                seal.reject(error)
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
        .done
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
    @discardableResult
    func getRotationItemsCollection() -> Promise<Void>
    {
        return Promise
        {
            (seal) -> Void in
            self.api.getRotationItems()
            .done
            {
                (rotationItemsCollection) -> Void in
                self.updateRotationItemsCollection(rotationItemsCollection: rotationItemsCollection)
                seal.fulfill(())
            }
            .catch
            {
                (error) -> Void in
                seal.reject(error)
            }
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
        // update addedSongs
        self.addedSongs = rotationItemsCollection.rotationItems.reduce(into: [String:AudioBlock]()) { $0[$1.song.id!] = $1.song }
        self.rotationItemsCollection = rotationItemsCollection
        NotificationCenter.default.post(name: PlayolaEvents.rotationItemsCollectionUpdated, object: nil, userInfo: ["rotationItemsCollection": rotationItemsCollection])
        self.setStationStatus()
    }
    
    //------------------------------------------------------------------------------
    
    public func setStationStatus() {
        let _ = self.stationStatus
    }
    
    //------------------------------------------------------------------------------
    
    open func hasRunningStation() -> Bool
    {
        return ((self.user?.program?.playlist != nil) && (self.user!.program!.playlist!.count > 0))
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
    //
    // station Status stuff
    //
    open func monitorStationStatus() {
        switch self.stationStatus {
        case .findingSongs:
            self.api.getRotationItemsCount()
            .done
            {
                (newCounts) -> Void in
                if (newCounts["stationMinimum"].int != nil && newCounts["stationMinimum"].int! != self.minimumSongsNeeded) {
                    self.minimumSongsNeeded = newCounts["stationMinimum"].int!
                }
                
                if (self.countsAreDifferent(count1: self.counts, count2: newCounts)) {
                    self.getRotationItemsCollection()
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
                {
                    self.monitorStationStatus()
                }
            }
            .catch
            {
                (err) -> Void in
            }
        case .generatingSchedule:
            self.api.getMe()
            .done
            {
                (user) -> Void in
                var shouldContinueMonitoring = true
                if let playlist = user.program?.playlist {
                    if (playlist.count > 0) {
                        self.setStationStatus()
                        self.getRotationItemsCollection()
                        shouldContinueMonitoring = false
                    }
                }
                if (shouldContinueMonitoring) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
                    {
                        self.monitorStationStatus()
                    }
                }
            }
            .catch
            {
                (error) -> Void in
                print(error)
            }
        default:
            break
        }
    }
    
    //------------------------------------------------------------------------------
    
    private func countsAreDifferent(count1:JSON?, count2:JSON) -> Bool {
        if (count1 == nil) {
            return true
        }
        
        if (count1?["inactive"].int != count2["inactive"].int) {
            return true
        }
        if (count1?["active"].int != count2["active"].int) {
            return true
        }
        return false
    }
    
    //------------------------------------------------------------------------------
    
    private func calculateStationStatus() -> StationStatus
    {
        var newValue:StationStatus = .generatingSchedule
        if (self.user?.program?.playlist != nil) {
            newValue = .completed
        } else if (self.completedSongCount <= self.minimumSongsNeeded) {
            newValue = .findingSongs
        }
        if (newValue != self._previousStationStatus) {
            self._previousStationStatus = newValue
            NotificationCenter.default.post(name: PlayolaEvents.usersStationStatusChanged, object: nil)
        }
        return newValue
    }
    
    private func percentageSongsCompleted() -> Float {
        let percentageComplete = Float(self.completedSongCount)/Float(self.minimumSongsNeeded)
        return min(percentageComplete, 1.0)
    }
    
    open func stationCompletionPercentage() -> Float
    {
        switch self.stationStatus {
        case .completed:
            return 1.0
        case .findingSongs:
            return 0.9 * self.percentageSongsCompleted()
        default:
            return 0.95
        }
    }
    
    //------------------------------------------------------------------------------
    
    func broadcastSongsAcquired(spacingInterval:TimeInterval = 0.1)
    {
        let idsLeftToBeBroadcast:Set<String> = Set(self.addedSongs.keys).subtracting(self.songIDsAlreadyBroadcast)
        if (idsLeftToBeBroadcast.count > 0) {
            let songToBroadcast:AudioBlock = self.addedSongs[idsLeftToBeBroadcast.first!]!
            
            NotificationCenter.default.post(name: PlayolaEvents.usersStationAcquiredSong, object: nil, userInfo: ["song": songToBroadcast])
            self.songIDsAlreadyBroadcast.insert(songToBroadcast.id!)
            if (idsLeftToBeBroadcast.count > 1) {
                DispatchQueue.main.asyncAfter(deadline: .now() + spacingInterval)
                {
                    self.broadcastSongsAcquired(spacingInterval: spacingInterval)
                }
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


public enum StationStatus:String
{
    case findingSongs = "Finding those songs in Playola"
    case generatingSchedule = "Generating schedule and starting station..."
    case completed = "Finished! Your new radio station has started."
}

