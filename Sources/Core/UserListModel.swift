//
//  UserListModel.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit

class UserList
{
    var users:Array<User?>! = []
    var name:String!
    var refreshTimer:Timer?
    
    //------------------------------------------------------------------------------
    // dependency injections
    // cannot inject:
    //         AudioPlayerInstance
    // because of circular dependencies... these must be mocked globally
    //                                     in tests
    //------------------------------------------------------------------------------
    @objc var api:PlayolaAPI = PlayolaAPI.sharedInstance()
    @objc var DateHandler:DateHandlerService! = DateHandlerService.sharedInstance()
    
    //------------------------------------------------------------------------------
    
    init(users: Array<User?> = [], name:String="generic")
    {
        self.users = users
        self.name = name
        
//        self.startMonitoring()
//        
//        self.refreshTimer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(UserList.refreshProgramsFromServerObjc), userInfo: nil, repeats: true)
//        
//        self.setupListeners()
    }
//    
//    convenience init(DateHandler:DateHandlerService = DateHandlerService.sharedInstance(), users: Array<User?> = [], name:String="generic")
//    {
//        self.DateHandler = DateHandler
//        self.init(users: users, name: name)
//    }
    
    // -----------------------------------------------------------------------------
    //                           func setupListeners
    // -----------------------------------------------------------------------------
    /// sets up this list's listeners.
    ///
    /// - current Listeners are:
    ///     * clear the list on logout
    ///     * perform wakeFromSleep() functions
    ///     * execute prepareForIdle if entering background
    /// ----------------------------------------------------------------------------
    func setupListeners()
    {
        NotificationCenter.default.addObserver(forName: PlayolaEvents.signedOut, object: nil, queue: OperationQueue.main)
        {
            (notification) -> Void in
//            self.resetList([])
        }
        
//        NotificationCenter.default.addObserver(forName: kPlayolaWillWakeFromSleepEvent, object: nil, queue: OperationQueue.main)
//        {
//            (notification) in
//            if let userInfo = (notification as NSNotification).userInfo
//            {
//                if let timeInterval = userInfo["timeIntervalSinceSleep"] as? TimeInterval
//                {
//                    self.wakeFromSleep(timeInterval)
//                }
//            }
//        }
//        
//        NotificationCenter.default.addObserver(forName: kPlayolaDidEnterBackgroundEvent, object: nil, queue: OperationQueue.main)
//        {
//            (notification) in
//            if (!StationAudioPlayer.sharedInstance().isPlaying())
//            {
//                self.prepareForIdle()
//            }
//        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func deinit
    // -----------------------------------------------------------------------------
    /// cleans up when list is deleted
    ///
    /// ----------------------------------------------------------------------------
    deinit
    {
        print("deinitializing list!")
        self.refreshTimer?.invalidate()
    }
    
//    // -----------------------------------------------------------------------------
//    //                          func startMonitoring
//    // -----------------------------------------------------------------------------
//    /// schedule the next advance for each user
//    ///
//    /// ----------------------------------------------------------------------------
//    func startMonitoring ()
//    {
//        for i in 0..<self.users.count
//        {
//            self.scheduleNextAdvance(self.users[i]!)
//        }
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func refresh
//    // -----------------------------------------------------------------------------
//    /// replaces the current list with a new array of users & adjusts monitoring
//    /// accordingly
//    ///
//    /// - parameters:
//    ///     - newUsers: `(Array<User!>)` - an array of users
//    /// ----------------------------------------------------------------------------
//    func refresh(_ newUsers:Array<User?>)
//    {
////        var oldListDict:Dictionary<String,User?> = MiscHelperFunctions.generateUsersDictionary(self.users)
////        
////        for i in 0..<newUsers.count
////        {
////            // if it's already in list
////            if oldListDict[(newUsers[i]?.id!)!] != nil {
////                oldListDict[(newUsers[i]?.id!)!]!?.replaceProgram(newUsers[i]?.program)
////                oldListDict.removeValue(forKey: (newUsers[i]?.id!)!)
////            }
////            else
////            {
////                self.users.append(newUsers[i])
////                self.scheduleNextAdvance(newUsers[i]!)
////            }
////        }
////        
////        // whatever's left over has been removed
////        for (key, _) in oldListDict
////        {
////            self.removeUserWithID(key)
////        }
//        
////        NotificationCenter.default.post(name: kListUpdated, object: nil, userInfo: ["name": self.name,
////                                                                                    "userList": self ])
//    }
//    
    // -----------------------------------------------------------------------------
    //                          func addUsers
    // -----------------------------------------------------------------------------
    /// adds the users and begins tracking them
    ///
    /// - parameters:
    ///     - usersToAdd: `(Array<User>)` - an array of users to add
    ///
    /// ----------------------------------------------------------------------------
    func addUsers(_ usersToAdd:Array<User>)
    {
//        var changedFlag:Bool = false
//        for user in usersToAdd
//        {
//            // Make a copy so mods are not accidentally shared
//            let user = user.copy()
//            
//            if let userID = user.id
//            {
//                if (!self.isInList(userID))
//                {
//                    self.users.append(user)  // always uses a copy to avoid accidental multiple updates
//                    self.scheduleNextAdvance(user)
//                    changedFlag = true
//                }
//            }
//        }
//        
//        if (changedFlag)
//        {
//            NotificationCenter.default.post(name: kListUpdated, object: nil, userInfo: ["name": self.name])
//        }
    }
    
//    // -----------------------------------------------------------------------------
//    //                          func refresh
//    // -----------------------------------------------------------------------------
//    /// replaces the current list with a new array of users & adjusts monitoring
//    /// accordingly.
//    ///
//    /// - parameters:
//    ///     - rawUsers: `(Array<Sictionary<String,AnyObject>>)` - an array of raw
//    ///                                 user dictionaries -- raw server users
//    /// ----------------------------------------------------------------------------
//    func refresh(_ rawUsers:Array<Dictionary<String,AnyObject>>)
//    {
//        let usersPlaylist:Array<User?> = rawUsers.map
//        {
//            (userInfo) -> User! in
//            return User(userInfo: userInfo as NSDictionary)
//        }
//        return self.refresh(usersPlaylist)
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func resetList
//    // -----------------------------------------------------------------------------
//    /// clears all users from the list and replaces them with the newUsers
//    ///
//    /// - parameters:
//    ///     - newUsers: `(Array<User!>)` - the new users to put in the list
//    /// ----------------------------------------------------------------------------
//    func resetList(_ newUsers:Array<User?>)
//    {
//        self.users = []
//        self.refresh(newUsers)
//    }
//    
    // -----------------------------------------------------------------------------
    //                          func clear
    // -----------------------------------------------------------------------------
    /// cleanly resets the list to empty
    ///
    /// ----------------------------------------------------------------------------
    func clear()
    {
//        self.resetList([])
    }
    
//    // -----------------------------------------------------------------------------
//    //                          func refreshProgramsFromServerObjc
//    // -----------------------------------------------------------------------------
//    /// ObjectiveC wrapper for refreshProgramsFromServer
//    ///
//    /// ----------------------------------------------------------------------------
//    @objc func refreshProgramsFromServerObjc()
//    {
//        self.refreshProgramsFromServer()
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                      func refreshProgramsFromServer
//    // -----------------------------------------------------------------------------
//    /// requests updated playlists from the server for all users in the list and
//    /// and updates them when they come in.
//    ///
//    /// - returns:
//    ///    `Promise<Void>` - resolves on completion
//    /// ----------------------------------------------------------------------------
//    func refreshProgramsFromServer() -> Promise<Void>
//    {
////        return Promise
////            {
////                fulfill, reject in
////                let userIDs:Array<String> = self.users.map {
////                    (user) -> String in
////                    return user!.id!
////                }
////                
////                if (userIDs.count == 0)
////                {
////                    fulfill()
////                }
////                else
////                {
////                    self.authService.getMultipleUsers(userIDs)
////                        .then
////                        {
////                            newUsers -> Void in
////                            self.refresh(newUsers)
////                            fulfill()
////                    }
////                }
////        }
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func removeUserWithID
//    // -----------------------------------------------------------------------------
//    /// removes the user with the given id from the userList
//    ///
//    /// - parameters:
//    ///     - userID: `(String)` - the userID of the user to be removed
//    ///
//    /// - returns:
//    ///    `Bool` - true for success, false for not found
//    /// ----------------------------------------------------------------------------
//    func removeUserWithID(_ userID:String) -> Bool
//    {
//        let index = self.getIndex(userID)
//        if let _ = index
//        {
//            self.users[index!]?.advanceTimer?.invalidate()
//            self.users.remove(at: index!)
//        }
//        else
//        {
//            return false
//        }
//        return true
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func getUser
//    // -----------------------------------------------------------------------------
//    /// retrieves the user with the given ID
//    ///
//    /// - parameters:
//    ///     - userID: `(String)` - the id of the user to get
//    ///
//    /// - returns:
//    ///    `User?` - the user -- nil if not found
//    /// ----------------------------------------------------------------------------
//    
//    func getUser(_ userID:String) -> User?
//    {
//        for i in 0..<self.users.count
//        {
//            if self.users[i]?.id! == userID
//            {
//                return users[i]
//            }
//        }
//        return nil
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func isInList
//    // -----------------------------------------------------------------------------
//    /// checks the list for a user
//    ///
//    /// - parameters:
//    ///     - userID: `(String?)` - the id of the user to look for
//    ///
//    /// - returns:
//    ///    `Bool` - true if user is in the list
//    /// ----------------------------------------------------------------------------
//    func isInList(_ userID:String?) -> Bool
//    {
//        if let _ = userID
//        {
//            if let _ = self.getUser(userID!)
//            {
//                return true
//            }
//        }
//        return false
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func scheduleNextAdvance
//    // -----------------------------------------------------------------------------
//    /// schedules the next advance for the user.  The timer is stored in the user as
//    /// `user.advanceTimer`
//    ///
//    /// - parameters:
//    ///     - user: `(User)` - a user
//    /// ----------------------------------------------------------------------------
//    func scheduleNextAdvance(_ user:User)
//    {
//        // set next advance
//        if let program = user.program
//        {
//            if let playlist:Array<Spin> = program.playlist
//            {
//                if (playlist.count > 0)
//                {
//                    if let fireTime:Date = DateHandler.adjustedDate(playlist[0].airtime)
//                    {
//                        user.advanceTimer = Timer(fireAt: fireTime, interval: 0.0, target: self, selector: #selector(UserList.advanceNowPlaying(_:)), userInfo: ["userID": user.id!], repeats: false)
//                        RunLoop.main.add(user.advanceTimer!, forMode: RunLoopMode.defaultRunLoopMode)
//                    }
//                }
//            }
//        }
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func getIndex
//    // -----------------------------------------------------------------------------
//    /// gets the index of a user with the given userID
//    ///
//    /// - parameters:
//    ///     - userID: `(String)` - a user id
//    ///
//    /// - returns:
//    ///    `Int?` - the index of the user in the list. nil if not found
//    /// ----------------------------------------------------------------------------
//    func getIndex(_ userID:String) -> Int?
//    {
//        for i in 0..<self.users.count
//        {
//            if (self.users[i]?.id! == userID)
//            {
//                return i
//            }
//        }
//        return nil
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func advanceNowPlaying
//    // -----------------------------------------------------------------------------
//    /// advances the nowPlaying of a User when the timer fires.  Afterwards it:
//    ///        -- posts the kNowPlayingAdvanced notification
//    ///        -- calls self.scheduleNextAdvance on the user
//    ///
//    /// - parameters:
//    ///     - timer: `(NSTimer)` - the timer that fired
//    /// ----------------------------------------------------------------------------
//    @objc func advanceNowPlaying(_ timer:Timer)
//    {
////        let userID:String = (timer.userInfo as! Dictionary<String,AnyObject>)["userID"] as! String
////        
////        let index:Int? = self.getIndex(userID)
////        
////        if (index == nil)
////        {
////            return
////        }
////        
////        if let _ = self.users[index!]?.program
////        {
////            if let _ = self.users[index!]?.program!.playlist
////            {
////                if ((self.users[index!]?.program!.playlist!.count)! > 0)
////                {
////                    if let _ = self.users[index!]?.program!.nowPlaying
////                    {
////                        self.users[index!]?.program!.recentlyPlayed.insert((self.users[index!]?.program!.nowPlaying!)!, at: 0)
////                    }
////                    
////                    self.users[index!]?.program!.nowPlaying = self.users[index!]?.program!.playlist!.remove(at: 0)
////                    
////                    NotificationCenter.default.post(name: Notification.Name(rawValue: kNowPlayingAdvanced), object: nil, userInfo: ["userID":self.users[index!]?.id!, "listName": self.name])
////                    self.scheduleNextAdvance(self.users[index!]!)
////                }
////            }
////        }
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func refreshAdvanceTimers
//    // -----------------------------------------------------------------------------
//    /// refreshes all advanceTimers in the list
//    ///
//    /// ----------------------------------------------------------------------------
//    func refreshAdvanceTimers()
//    {
//        for i in 0..<self.users.count
//        {
//            self.users[i]?.advanceTimer?.invalidate()
//            self.scheduleNextAdvance(self.users[i]!)
//        }
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func invalidateAdvanceTimers
//    // -----------------------------------------------------------------------------
//    /// invalidates all advanceTimers in the list
//    ///
//    /// ----------------------------------------------------------------------------
//    func invalidateAdvanceTimers()
//    {
//        for i in 0..<self.users.count
//        {
//            self.users[i]?.advanceTimer?.invalidate()
//        }
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func prepareForIdle
//    // -----------------------------------------------------------------------------
//    /// prepares the list to go into idle mode
//    ///     -- calls:
//    ///         -- self.invalidateAdvanceTimers()
//    ///         -- self.refreshTimer?.invalidate()
//    ///
//    /// ----------------------------------------------------------------------------
//    func prepareForIdle()
//    {
//        print("prepareForIdle")
//        self.invalidateAdvanceTimers()
//        self.refreshTimer?.invalidate()
//    }
//    
//    // -----------------------------------------------------------------------------
//    //                          func wakeFromSleep
//    // -----------------------------------------------------------------------------
//    /// perform necessary refreshes when returning from sleep.
//    ///
//    ///     PSEUDOCODE:
//    ///     reset the refreshTimer
//    ///     IF > 30 secs:
//    ///         get new programs from the server
//    ///     IF < 180 secs
//    ///         FOR each user
//    ///             bring playlist current
//    ///             post kNowPlayingAdvanced
//    ///         ENDFOR
//    ///     ENDIF
//    ///     post kPlayolaListRefreshedAfterWake
//    ///
//    /// ----------------------------------------------------------------------------
//    func wakeFromSleep(_ timeIntervalSinceSleep:TimeInterval?)
//    {
////        // restart 3 minute playlist updates
////        self.refreshTimer?.invalidate()  // just in case
////        self.refreshTimer = Timer.scheduledTimer(timeInterval: 180, target: self, selector: #selector(UserList.refreshProgramsFromServerObjc), userInfo: nil, repeats: true)
////        
////        
////        if let intervalSince = timeIntervalSinceSleep
////        {
////            // if it's been more than 30 secs, set up a refresh from the server
////            if (intervalSince > 30.0)
////            {
////                self.refreshProgramsFromServer()
////            }
////            
////            // if it's been less than 3 min, advance all stations locally
////            //      -- (just makes returning more convenient... this will be taken care of by
////            //          refreshProgramsFromServer anyways...
////            if (intervalSince < 180.0)
////            {
////                for user in self.users
////                {
////                    let changed:Bool? = user?.program?.bringCurrent()
////                    
////                    if (changed == true)
////                    {
////                        NotificationCenter.default.post(name: Notification.Name(rawValue: kNowPlayingAdvanced), object: nil, userInfo: ["userID":user?.id!, "listName": self.name])
////                    }
////                }
////                
////                self.refreshAdvanceTimers()
////            }
////            
//////            NotificationCenter.default.post(name: kPlayolaListRefreshedAfterWake, object: nil, userInfo: ["listName": self.name])
////        }
//    }
}
