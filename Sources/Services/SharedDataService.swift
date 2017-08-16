//
//  SharedDataService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

// -----------------------------------------------------------------------------
//                          func SharedDataService
// -----------------------------------------------------------------------------
/// Holds all data that is shared across the app.  Used as a Singleton initialized
/// with SharedDataInstance
/// ----------------------------------------------------------------------------
class SharedDataService:NSObject, SWRevealViewControllerDelegate
{
    var currentUser:User?
    var rotationItemsCollection:RotationItemsCollection?
    
    /// true if the currentUser has already been loaded
    var currentUserLoaded:Bool! = false
    
    var presets:UserList! = UserList()
    
    /// true if SharedData initialization has been completed
    var initialized:Bool! = false
    
    var imageCache:Dictionary<String, UIImage> = Dictionary()
    
    /// a UserList that handles updating and monitoring for the currentUser
    var currentUserList:UserList! = UserList(users: [], name: kCurrentUserListName)
    
    var topUsersList:UserList! = UserList()
    var topUsersListInitialized:Bool! = false
    
    var friendsList:UserList! = UserList()
    var friendsListInitialized:Bool! = false
    
    var presetsInitialized:Bool! = false
    
    var voiceTrackDirectoryURL:URL!
    var recordedVoiceTracks:Array<AudioBlock?> = []
    var voiceTrackCount:Int = 0
    
    /// stores the time the app last went to sleep
    var sleepTime:Date?
    
    var lastViewedAirtime:Date?
    
    //------------------------------------------------------------------------------
    
    // dependencies
    var authService:AuthService! = AuthService.sharedInstance()
    var displayHelper:DisplayHelper! = DisplayHelper()
    var DateHandler:DateHandlerService!
    var friendGetter:FriendGetterService! = FriendGetterService.sharedInstance()
    
    func injectDependencies(_ authService:AuthService=AuthService.sharedInstance(), displayHelper:DisplayHelper?=nil, DateHandler:DateHandlerService=DateHandlerService.sharedInstance(), friendGetter:FriendGetterService = FriendGetterService.sharedInstance())
    {
        self.authService = authService
        self.DateHandler = DateHandler
        self.friendGetter = friendGetter
        if let displayHelper = displayHelper
        {
            self.displayHelper = displayHelper
        }
    }
    
    init(authService:AuthService=AuthService.sharedInstance(), displayHelper:DisplayHelper?=nil, DateHandler:DateHandlerService=DateHandlerService.sharedInstance())
    {
        self.authService = authService
        self.DateHandler = DateHandler
        if let displayHelper = displayHelper
        {
            self.displayHelper = displayHelper
        }
    }
    
    // -----------------------------------------------------------------------------
    //                           func setupListeners
    // -----------------------------------------------------------------------------
    /// sets up SharedData's listeners.
    ///
    /// - current Listeners are:
    ///     * set up audio when app returns from sleep
    ///     * store info when app is about to sleep
    ///
    /// ----------------------------------------------------------------------------
    func setupListeners()
    {
        NotificationCenter.default.addObserver(forName: kPlayolaWillResignActiveEvent, object: nil, queue: OperationQueue.main) { (notification) in
            self.storeIdleInfo()
        }
        
        NotificationCenter.default.addObserver(forName: kLoggedIntoFacebookEvent , object: nil, queue: OperationQueue.main)
        {
            (notification) -> Void in
            self.loadFriends()
        }
        
        NotificationCenter.default.addObserver(forName: kLoggedIntoGoogleEvent , object: nil, queue: OperationQueue.main)
        {
            (notification) -> Void in
            self.loadFriends()
        }
        
        NotificationCenter.default.addObserver(forName: kStationShuffled , object: nil, queue: OperationQueue.main)
        {
            (notification) -> Void in
            if let userInfo = notification.userInfo
            {
                if let firstDifferentAirtime = userInfo["firstDifferentAirtime"] as? Date
                {
                    self.lastViewedAirtime = firstDifferentAirtime
                }
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func storeIdleInfo
    // -----------------------------------------------------------------------------
    /// stores information about when the app when to sleep
    /// ----------------------------------------------------------------------------
    func storeIdleInfo()
    {
        self.sleepTime = DateHandler.now() as Date?
    }
    
    // -----------------------------------------------------------------------------
    //                   func getIntervalSinceSleepInitiation
    // -----------------------------------------------------------------------------
    /// calculates the NSTimeInterval since sleep was initiated
    ///
    /// - returns:
    ///    `NSTimeInterval?` - interval since the app when to sleep
    /// ----------------------------------------------------------------------------
    func getIntervalSinceSleepInitiation() -> TimeInterval?
    {
        if let sleepTime = self.sleepTime
        {
            return DateHandler.now().timeIntervalSince(sleepTime)
        }
        else
        {
            return nil
        }
    }
    
    
    // -----------------------------------------------------------------------------
    //                func broadcastWillWakeFromSleepEvent
    // -----------------------------------------------------------------------------
    /// Broadcasts the willWakeFromSleep event with information about how long the
    /// app has been sleeping.
    ///
    /// ----------------------------------------------------------------------------
    func broadcastWillWakeFromSleepEvent()
    {
        var userInfo:[AnyHashable: Any] = Dictionary()
        if let interval = self.getIntervalSinceSleepInitiation()
        {
            userInfo["timeIntervalSinceSleep"] = interval
        }
        
        NotificationCenter.default.post(name: kPlayolaWillWakeFromSleepEvent, object: nil, userInfo: userInfo)
    }
    
    // -----------------------------------------------------------------------------
    //                          func initialize
    // -----------------------------------------------------------------------------
    /// initializes all SharedData info
    ///
    ///
    ///
    /// - returns:
    ///    `Promise` - resolves upon completion
    /// ----------------------------------------------------------------------------
    func initialize(user:User) -> Promise<Void>
    {
        return Promise
            {
                fulfill, reject in
                self.clear()
                self.setupUserLists()
                print("setupUserLists done")
                self.setupListeners()
                self.currentUser = user
                self.currentUserLoaded = true
                NotificationCenter.default.post(name: kCurrentUserInitialized, object: nil)
                Instabug.setUserEmail(self.currentUser!.email!)
                when(fulfilled: self.getUserInfoIfNecessary())
                    .then
                    {
                        _ -> Void in
                        // create a list to update "me"
                        self.currentUserList.refresh([self.currentUser])
                        
                        
                        // finish initializing all essential values
                        when(fulfilled: self.loadRotationItemsCollection(),
                             self.loadPresets())
                            .then
                            {
                                _ -> Void in
                                self.initialized = true
                                NotificationCenter.default.post(name: kSharedDataInitialized, object: nil)
                                
                                // then trigger loading of non-essential values
                                self.loadFriends()
                                self.loadTopUsers()
                                
                                fulfill()
                        }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func setupUserLists
    // -----------------------------------------------------------------------------
    /// creates brand new userLists
    ///
    /// ----------------------------------------------------------------------------
    func setupUserLists()
    {
        self.presets = UserList(name: kPresetsListName)
        self.currentUserList = UserList(name: kCurrentUserListName)
        self.topUsersList = UserList(name: kTopUsersListName)
        self.friendsList = UserList(name: kFriendsListName)
    }
    
    // -----------------------------------------------------------------------------
    //                          func getUserInfoIfNecessary
    // -----------------------------------------------------------------------------
    /// checks to see if the user has started a station.  If not, it starts the
    /// station creation process
    ///
    /// ----------------------------------------------------------------------------
    func getUserInfoIfNecessary() -> Promise<Void>
    {
        return Promise
            {
                fulfill, reject in
                if (self.currentUser?.zipcode == nil)
                {
                    self.displayViewController(kGetUserInfoNavigationController)
                        .then
                        {
                            void -> Void in
                            if (self.currentUser?.program == nil)
                            {
                                self.displayViewController(kArtistSearchNavigationController)
                                    .then
                                    {
                                        void -> Void in
                                        fulfill()
                                    }
                                    .catch
                                    {
                                        (error) -> Void in
                                        print("error displayingArtistSearchNavigationController")
                                        print(error.localizedDescription)
                                        
                                }
                            }
                        }
                        .catch
                        {
                            (error) -> Void in
                            print("error displaying GetUserInfoNavigationController")
                            print(error.localizedDescription)
                    }
                }
                else if (self.currentUser?.program == nil)
                {
                    self.displayViewController(kArtistSearchNavigationController)
                        .then
                        {
                            void -> Void in
                            fulfill()
                        }
                        .catch
                        {
                            (error) -> Void in
                            print("error displaying ArtistSearchNavigationController")
                            print(error.localizedDescription)
                    }
                }
                else
                {
                    fulfill()
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                     func displayViewController()
    // -----------------------------------------------------------------------------
    /// displays a view controller
    ///
    /// - parameters:
    ///     - viewControllerClass: `(Class)` - the desired viewController's class
    ///
    /// ----------------------------------------------------------------------------
    func displayViewController(_ identifier:String) -> Promise<Void>
    {
        return Promise
            {
                fulfill, reject in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    () -> () in
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let getInfoViewController = storyboard.instantiateViewController(withIdentifier: identifier)
                    
                    switch identifier
                    {
                    case kGetUserInfoNavigationController,
                         kArtistSearchNavigationController:
                        (getInfoViewController as! GetUserInfoNavigationController).onDismissalBlock = { () -> Void in fulfill() }
                    default: break
                    }
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(getInfoViewController, animated: true, completion: nil)
                }
        }
    }
    
    
    // -----------------------------------------------------------------------------
    //                          func clear
    // -----------------------------------------------------------------------------
    /// clears SharedData info
    /// ----------------------------------------------------------------------------
    func clear() -> Promise<Void>
    {
        return Promise
            {
                (fulfill, reject) in
                self.currentUserLoaded = false
                self.presets.resetList([])
                self.topUsersList.resetList([])
                self.initialized = false
                self.currentUser = nil
                self.rotationItemsCollection = nil
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func loadPresets
    // -----------------------------------------------------------------------------
    /// populates the self.presets UserList
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    /// ----------------------------------------------------------------------------
    func loadPresets() -> Promise<Void>
    {
        return Promise
            {
                fulfill, reject in
                self.authService.getPresets()
                    .then
                    {
                        (presets) -> Void in
                        print("load presets call answered")
                        self.presets = UserList(users: presets, name: kPresetsListName)
                        self.presetsInitialized = true
                        NotificationCenter.default.post(name: kPresetsInitializedEvent, object: nil)
                        print("fulfilling load presets")
                        fulfill()
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                      func loadRotationItemsCollection
    // -----------------------------------------------------------------------------
    /// populates self.rotationItemsCollection
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    /// ----------------------------------------------------------------------------
    func loadRotationItemsCollection() -> Promise<Void>
    {
        return Promise
            {
                fulfill, reject in
                self.authService.getRotationItems()
                    .then
                    {
                        (rotationItemsCollection) -> Void in
                        self.rotationItemsCollection = rotationItemsCollection
                        print("rotationItemsCollection fulfilling")
                        fulfill()
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func loadTopUsers
    // -----------------------------------------------------------------------------
    /// populates self.topUsers UserList
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    ///
    /// ----------------------------------------------------------------------------
    func loadTopUsers() -> Promise<Void>
    {
        return Promise
            {
                fulfill, reject in
                self.authService.getTopUsers()
                    .then
                    {
                        topUsers -> Void in
                        self.topUsersList = UserList(users: topUsers, name: kTopUsersListName)
                        self.topUsersListInitialized = true
                        NotificationCenter.default.post(name: kTopUsersInitializedEvent, object: nil)
                        print("topUsers fulfilling")
                        fulfill()
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func loadFriends
    // -----------------------------------------------------------------------------
    /// populates self.friends UserList
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    ///
    /// ----------------------------------------------------------------------------
    func loadFriends() -> Promise<Void>
    {
        return Promise
            {
                (fulfill, reject) -> Void in
                let getGoogleFriendsPromise = self.friendGetter.getGooglePlayolaFriends()
                    .then
                    {
                        (friends) -> Void in
                        if (friends.count > 0)
                        {
                            self.friendsList.addUsers(friends)
                            self.markFriendsListInitialized()
                        }
                }
                
                let getFacebookFriendsPromise = self.friendGetter.getFacebookPlayolaFriends()
                    .then
                    {
                        (friends) -> Void in
                        if (friends.count > 0)
                        {
                            self.friendsList.addUsers(friends as! Array<User>)
                            self.markFriendsListInitialized()
                        }
                }
                
                when(resolved: getGoogleFriendsPromise, getFacebookFriendsPromise)
                    .then
                    {
                        _ -> Void in
                        self.markFriendsListInitialized()
                        fulfill()
                    }
                    .catch
                    {
                        (err) -> Void in
                        print("error getting google or facebook friends: \(err.localizedDescription)")
                        
                }
        }
    }
    
    fileprivate func markFriendsListInitialized()
    {
        if (!self.friendsListInitialized)
        {
            self.friendsListInitialized = true
            NotificationCenter.default.post(name: kFriendsListInitialized, object: nil)
        }
    }
    
    
    // -----------------------------------------------------------------------------
    //                          func getImage
    // -----------------------------------------------------------------------------
    /// gets an image from the cache
    ///
    /// - parameters:
    ///     - imageURL: `(String)` - the web URL of the image needed
    ///
    /// - returns:
    ///    `Promise<(UIImage?, NSError?)>` - resolves to a tuple
    /// ----------------------------------------------------------------------------
    func getImage(_ imageURL:String, forceReload:Bool=false) -> Promise<(UIImage?, NSError?)>
    {
        return Promise
            {
                fulfill, reject in
                if ((self.imageCache[imageURL] != nil) && (forceReload == false))
                {
                    fulfill((self.imageCache[imageURL]!, nil))
                }
                else
                {
                    Alamofire.request(imageURL, method: .get)
                        .response
                        {
                            responce-> Void in
                            if let data = responce.data
                            {
                                let image = UIImage(data: (data as NSData) as Data)
                                self.imageCache[imageURL] = image
                                fulfill((image, nil))
                            }
                            
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func imageExists
    // -----------------------------------------------------------------------------
    /// returns true if the image with the provided web url exists in the cache
    ///
    /// - parameters:
    ///     - imageURL: `(String)` - the web URL of the image needed
    ///
    /// - returns:
    ///    `Bool` - true if the image already exists in the cache
    /// ----------------------------------------------------------------------------
    func imageExists(_ imageURL:String) -> Bool
    {
        if let _ = self.imageCache[imageURL]
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func resetStation
    // -----------------------------------------------------------------------------
    /// adds a song to a bin and posts kRotationItemsCollectionUpdated upon completion
    ///
    /// - parameters:
    ///     - song: `(AudioBlock)` - the audioBlock to add
    ///     - bin: `(String)` - the name of the bin to add it to
    ///     - callingViewController: `(UIViewController)` - the calling UIViewController
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    /// ----------------------------------------------------------------------------
    func resetStation(spotifyTrackIDs:Array<String>?=nil, spotifyArtistIDs:Array<String>?=nil) -> Promise<Void>
    {
        return Promise
            {
                (fulfill, reject) -> Void in
                self.authService.initializePlaylist(spotifyTrackIDs: spotifyTrackIDs, spotifyArtistIDs: spotifyArtistIDs)
                    .then
                    {
                        (user) -> Void in
                        self.initialize(user: user)
                            .then
                            {
                                fulfill()
                            }
                            .catch
                            {
                                (err) -> Void in
                                reject(err)
                        }
                    }
                    .catch
                    {
                        (err) -> Void in
                        NotificationCenter.default.post(name: kPlaylistInitializationFailed, object: nil, userInfo: ["error":err])
                        reject(err)
                }
        }
        
    }
    
    
    // -----------------------------------------------------------------------------
    //                          func addSongToBin
    // -----------------------------------------------------------------------------
    /// adds a song to a bin and posts kRotationItemsCollectionUpdated upon completion
    ///
    /// - parameters:
    ///     - song: `(AudioBlock)` - the audioBlock to add
    ///     - bin: `(String)` - the name of the bin to add it to
    ///     - callingViewController: `(UIViewController)` - the calling UIViewController
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    /// ----------------------------------------------------------------------------
    func addSongToBin(_ song:AudioBlock, bin:String, callingViewController:UIViewController) -> Promise<Void>
    {
        return Promise
            {
                fulfill2, reject in    // not sure why fulfill2 settles confusion for compiler, but it does
                self.authService.addSongToBin(song.id!, bin: bin)
                    .then
                    {
                        (rotationItemsCollection) -> Void in
                        self.rotationItemsCollection = rotationItemsCollection
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRotationItemsCollectionUpdated), object: nil)
                        fulfill2()
                    }
                    .catch
                    {
                        (error) in
                        self.displayHelper.displayAlert("Error", message: "Error Adding Song")
                        reject(AuthError.zipcodeNotFound)
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                         func addMultipleSongsToBin
    // -----------------------------------------------------------------------------
    /// adds an array of songs to a bin and posts kRotationItemsCollectionUpdated
    /// upon completion
    ///
    /// - parameters:
    ///     - song: `(AudioBlock)` - the audioBlock to add
    ///     - bin: `(String)` - the name of the bin to add it to
    ///     - callingViewController: `(UIViewController)` - the calling UIViewController
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    /// ----------------------------------------------------------------------------
    func addMultipleSongsToBin(_ songIDs:Array<String>, bin:String, callingViewController:UIViewController) -> Promise<Void>
    {
        return Promise
            {
                fulfill2, reject in    // not sure why fulfill2 settles confusion for compiler, but it does
                self.authService.addMultipleSongsToBin(songIDs, bin: bin)
                    .then
                    {
                        (rotationItemsCollection) -> Void in
                        self.rotationItemsCollection = rotationItemsCollection
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRotationItemsCollectionUpdated), object: nil)
                        fulfill2()
                    }
                    .catch
                    {
                        (error) in
                        self.displayHelper.displayAlert("Error", message: "Error Updating Collection")
                        reject(AuthError.zipcodeNotFound)
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func removeSongFromRotation
    // -----------------------------------------------------------------------------
    /// removes a song from rotation and posts the kRotationItemsCollectionUpdated event
    /// upon completion
    ///
    /// - parameters:
    ///     - song: `(AudioBlock)` - the song to be removed
    ///     - callingViewController: `(UIViewController)` - the calling UIViewController
    ///
    /// - returns:
    ///    `Promise<Void>` - resolves upon completion
    /// ----------------------------------------------------------------------------
    func removeSongFromRotation(_ song:AudioBlock, callingViewController:UIViewController) -> Promise<Void>
    {
        return Promise
            {
                fulfill2, reject in    // not sure why fulfill2 settles confusion for compiler, but it does
                if let rotationItemID = self.rotationItemsCollection?.rotationItemIDFromSongID(song.id!)
                {
                    self.authService.deactivateRotationItem(rotationItemID)
                        .then
                        {
                            rotationItemsCollection -> Void in
                            self.rotationItemsCollection = rotationItemsCollection
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRotationItemsCollectionUpdated), object: nil)
                            fulfill2()
                        }
                        .catch
                        {
                            (error) in
                            self.displayHelper.displayAlert("Error", message: "Error Adding Song")
                            reject(AuthError.zipcodeNotFound)
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func addVoicetrack
    // -----------------------------------------------------------------------------
    /// deletes the voicetrack at the given NSURL from the cache
    ///
    /// - parameters:
    ///     - url: `(NSURL)` - the NSURL of the voicetrack to delete
    ///
    /// ----------------------------------------------------------------------------
    func addVoicetrack(_ audioBlock:AudioBlock)
    {
        self.recordedVoiceTracks.append(audioBlock)
        NotificationCenter.default.post(name: kLocalVoicetracksArrayModified, object: nil)
    }
    
    // -----------------------------------------------------------------------------
    //                          func deleteVoicetrack
    // -----------------------------------------------------------------------------
    /// deletes the voicetrack at the given NSURL from the cache
    ///
    /// - parameters:
    ///     - url: `(NSURL)` - the NSURL of the voicetrack to delete
    ///
    /// ----------------------------------------------------------------------------
    func deleteVoicetrack(_ url:URL)
    {
        // Create a FileManager instance
        let fileManager = FileManager.default
        
        // remove it from the list if it's there
        for i in 0..<self.recordedVoiceTracks.count
        {
            if (self.recordedVoiceTracks[i]?.voiceTrackLocalUrl == url)
            {
                self.recordedVoiceTracks.remove(at: i)
                NotificationCenter.default.post(name: kLocalVoicetracksArrayModified, object: nil)
                break
            }
        }
        
        do
        {
            try fileManager.removeItem(atPath: url.path)
        }
        catch let error as NSError
        {
            print("Error trying to delete file from audioCache: \(error)")
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func timeRemainingInMyStationBlackout
    // -----------------------------------------------------------------------------
    /// checks for station block time and amount.
    ///
    /// - returns:
    ///    `TimeInterval?` - seconds until block can be lifted... nil if station is
    ///                        not currently blocked.
    ///
    /// ----------------------------------------------------------------------------
    func timeRemainingInMyStationBlackout() -> TimeInterval?
    {
        if let airtime = self.lastViewedAirtime
        {
            if airtime.isAfter(self.DateHandler.now())
            {
                return airtime.timeIntervalSinceNow
            }
        }
        return nil
    }
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the DateHandlerClass for all to use
    ///
    /// - returns:
    ///    `DateHandlerClass` - the central SharedData instance
    ///
    /// ----------------------------------------------------------------------------
    class func sharedInstance() -> SharedDataService
    {
        if (self._instance == nil)
        {
            self._instance = SharedDataService()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:SharedDataService?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ sharedDataService:SharedDataService)
    {
        self._instance = sharedDataService
    }
}   
