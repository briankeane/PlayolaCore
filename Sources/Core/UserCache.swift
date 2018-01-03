//
//  UserCache.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 1/1/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation

class UserCache:NSObject
{
    var users:[String:User] = Dictionary()
    
    public func refresh(user:User) -> User
    {
        guard let userID = user.id else {
            return user          // someday this should probably throw an error
        }
        
        if users[userID] == nil
        {
            users[userID] = user
            users[userID]?.startAutoAdvancing()
            user.onNowPlayingAdvanced()
            {
                (user) in
                guard let user = user, let userID = user.id else {
                    return
                }
                puts("----------------------  nowPlaying advanced userID: \(userID) --------------")
                NotificationCenter.default.post(name: PlayolaEvents.nowPlayingAdvanced, object: nil, userInfo: ["userID": userID,
                                                                                                                "user": user ])
            }
        }
        else
        {
            users[userID]?.refresh(updatedUser:user)
        }
        return users[userID]!
    }
    
    public func refresh(users:[User]) -> [User]
    {
        return users.map({self.refresh(user: $0) })
    }
    
    //------------------------------------------------------------------------------
    //                  Singleton
    //------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the UserCache for all to use
    ///
    /// - returns:
    ///    `PlayolaStationPlayer` - the central UserCache instance
    ///
    /// ----------------------------------------------------------------------------
    open static func sharedInstance() -> UserCache
    {
        if (self._instance == nil)
        {
            self._instance = UserCache()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:UserCache?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the UserCache class
    ///
    /// - parameters:
    ///     - userCache: `(UserCache)` - the new UserCache
    ///
    /// ----------------------------------------------------------------------------
    open class func replaceSharedInstance(_ userCache:UserCache)
    {
        self._instance = userCache
    }
}


/// -- TODO: make user storage weak so that it is automatically removed when it loses references.

//class WeakUser<T: User>: Equatable, Hashable {
//    weak var user: User?
//    init(user: User) {
//        self.user = user
//    }
//
//    var hashValue: Int {
//        if var user = user { return UnsafeMutablePointer<User>(&user).hashValue }
//        return 0
//    }
//
//    static func == (lhs: WeakUser<T>, rhs: WeakUser<T>) -> Bool {
//        guard let lhsUserID = lhs.user?.id, let rhsUserID = rhs.user?.id else
//        {
//            return false
//        }
//        return lhsUserID == rhsUserID
//    }
//}
//
//class WeakUserSet<T: User> {
//    var users: Set<WeakUser<User>>
//
//    init() {
//        self.users = Set<WeakUser<User>>([])
//    }
//
//    init(users: [User]) {
//        self.users = Set<WeakUser<User>>(users.map { WeakUser(user: $0) })
//    }
//
//    var allUsers: [User] {
//        return users.flatMap { $0.user }
//    }
//
//    func contains(_ user: User) -> Bool {
//        return self.users.contains(WeakUser(user: user))
//    }
//
//    func addUser(_ user: User) {
//        self.users.formUnion([WeakUser(user: user)])
//    }
//
//    func addUsers(_ users: [User]) {
//        self.users.formUnion(users.map { WeakUser(user: $0) })
//    }
//}

