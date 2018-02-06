//
//  PlayolaAPIMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit

class PlayolaAPIMock:PlayolaAPI {
    var getUserCallCount:Int = 0
    var getUserArgs:Array<String> = Array()
    var getUserShouldSucceed:Bool = true
    var getUserSuccessUser:User?
    var getUserFailureError:APIError?
    
    override public func getUser(userID: String) -> Promise<User>
    {
        self.getUserCallCount += 1
        self.getUserArgs.append(userID)
        
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.getUserShouldSucceed)
            {
                fulfill(self.getUserSuccessUser!)
            }
            else
            {
                reject(self.getUserFailureError!)
            }
        }
    }
    
    var reportListeningSessionCallCount:Int = 0
    var reportListeningSessionArgs:Array<String> = Array()
    var reportListeningSessionShouldSucceed:Bool = true
    var reportListeningSessionSuccessDict = ["message": "success"]
    var reportListeningSessionFailureError:APIError?
    
    override public func reportListeningSession(broadcasterID: String) -> Promise<Dictionary<String,Any>>
    {
        self.reportListeningSessionCallCount += 1
        self.reportListeningSessionArgs.append(broadcasterID)
        
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.reportListeningSessionShouldSucceed)
            {
                fulfill(self.reportListeningSessionSuccessDict)
            }
            else
            {
                reject(self.reportListeningSessionFailureError!)
            }
        }
    }
    
    var reportEndOfListeningSessionCallCount:Int = 0
    var reportEndOfListeningSessionShouldSucceed:Bool = true
    var reportEndOfListeningSessionSuccessDict = ["message": "success"]
    var reportEndOfListeningSessionFailureError:APIError?
    
    override public func reportEndOfListeningSession() -> Promise<Dictionary<String,Any>>
    {
        self.reportEndOfListeningSessionCallCount += 1
        
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.reportEndOfListeningSessionShouldSucceed)
            {
                fulfill(self.reportEndOfListeningSessionSuccessDict)
            }
            else
            {
                reject(self.reportEndOfListeningSessionFailureError!)
            }
        }
    }
    
    var reportAnonymousListeningSessionCallCount:Int = 0
    var reportAnonymousListeningSessionArgs:Array<[String:Any]> = Array()
    var reportAnonymousListeningSessionShouldSucceed:Bool = true
    var reportAnonymousListeningSessionSuccessDict = ["message": "success"]
    var reportAnonymousListeningSessionFailureError:APIError?
    
    override public func reportAnonymousListeningSession(broadcasterID: String, deviceID: String) -> Promise<Dictionary<String,Any>>
    {
        self.reportAnonymousListeningSessionCallCount += 1
        self.reportAnonymousListeningSessionArgs.append(["broadcasterID":broadcasterID,
                                                "deviceID": deviceID])
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.reportAnonymousListeningSessionShouldSucceed)
            {
                fulfill(self.reportListeningSessionSuccessDict)
            }
            else
            {
                reject(self.reportAnonymousListeningSessionFailureError!)
            }
        }
    }
    
    var reportEndOfAnonymousListeningSessionCallCount:Int = 0
    var reportEndOfAnonymousListeningSessionArgs:Array<String> = Array()
    var reportEndOfAnonymousListeningSessionShouldSucceed:Bool = true
    var reportEndOfAnonymousListeningSessionSuccessDict = ["message": "success"]
    var reportEndOfAnonymousListeningSessionFailureError:APIError?
    
    override public func reportEndOfAnonymousListeningSession(deviceID: String) -> Promise<Dictionary<String,Any>>
    {
        self.reportEndOfAnonymousListeningSessionCallCount += 1
        self.reportEndOfAnonymousListeningSessionArgs.append(deviceID)
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.reportEndOfAnonymousListeningSessionShouldSucceed)
            {
                fulfill(self.reportEndOfListeningSessionSuccessDict)
            }
            else
            {
                reject(self.reportEndOfAnonymousListeningSessionFailureError!)
            }
        }
    }
    
    var moveSpinCallCount:Int = 0
    var moveSpinArgs:Array<[String:Any]> = Array()
    var moveSpinShouldSucceed:Bool = true
    var moveSpinSuccessUser:User?
    var moveSpinFailureError:APIError?
    var moveSpinShouldPause:Bool = false
    
    override public func moveSpin(spinID: String, newPlaylistPosition: Int) -> Promise<User>
    {
        self.moveSpinCallCount += 1
        self.moveSpinArgs.append(["spinID": spinID, "newPlaylistPosition": newPlaylistPosition])
        
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.moveSpinShouldPause)
            {
                return
            }
            else if (self.moveSpinShouldSucceed)
            {
                fulfill(moveSpinSuccessUser!)
            }
            else if (!self.moveSpinShouldPause)
            {
                reject(moveSpinFailureError!)
            }
        }
    }
    
    var getPresetsCallCount:Int = 0
    var getPresetsShouldSucceed:Bool = true
    var getPresetsArgs:[[String:Any?]] = Array()
    var getPresetsPresets:[User]?
    var getPresetsError:APIError?
    override func getPresets(userID: String) -> Promise<[User]>
    {
        self.getPresetsCallCount += 1
        self.getPresetsArgs.append(["userID": userID])
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.getPresetsShouldSucceed)
            {
                return fulfill(self.getPresetsPresets!)
            }
            return reject(self.getPresetsError!)
        }
    }
    
    var requestSongBySpotifyIDShouldSucceed:Bool = true
    var requestSongBySpotifyIDCount:Int = 0
    var requestSongBySpotifyIDResponses:[(songStatus:SongStatus, song:AudioBlock?)]? = nil
    var requestSongBySpotifyIDSongStatus:SongStatus? = nil
    var requestSongBySpotifyIDError:APIError?
    var requestSongBySpotifyIDArgs:[[String:Any]] = Array()
    override func requestSongBySpotifyID(spotifyID: String) -> Promise<(songStatus: SongStatus, song: AudioBlock?)>
    {
        self.requestSongBySpotifyIDCount += 1
        self.requestSongBySpotifyIDArgs.append(["spotifyID": spotifyID])
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.requestSongBySpotifyIDShouldSucceed)
            {
                return fulfill(self.requestSongBySpotifyIDResponses!.removeFirst())
            }
            return reject(self.requestSongBySpotifyIDError!)
        }
    }
    
    var getRotationItemsShouldSucceed:Bool = true
    var getRotationItemsCount:Int = 0
    var getRotationItemsResponse:RotationItemsCollection?
    var getRotationItemsError:APIError?
    override func getRotationItems() -> Promise<RotationItemsCollection> {
        self.getRotationItemsCount += 1
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.getRotationItemsShouldSucceed)
            {
                return fulfill(self.getRotationItemsResponse!)
            }
            return reject(self.getRotationItemsError!)
        }
    }
    
    var deactivateRotationItemShouldSucceed:Bool = true
    var deactivateRotationItemCount:Int = 0
    var deactivateRotationItemArgs:[[String:Any]] = Array()
    var deactivateRotationItemResponse:RotationItemsCollection?
    var deactivateRotationItemError:APIError?
    var deactivateRotationItemShouldNeverReturn:Bool = false
    override func deactivateRotationItem(rotationItemID: String) -> Promise<RotationItemsCollection> {
        self.deactivateRotationItemCount += 1
        self.deactivateRotationItemArgs.append(["rotationItemID": rotationItemID])
        return Promise
        {
            (fulfill, reject) -> Void in
            if (!self.deactivateRotationItemShouldNeverReturn)
            {
                if (self.deactivateRotationItemShouldSucceed)
                {
                    return fulfill(self.deactivateRotationItemResponse!)
                }
                return reject(self.deactivateRotationItemError!)
            }
        }
    }
    
    var removeRotationItemsAndResetShouldSucceed:Bool = true
    var removeRotationItemsAndResetCount:Int = 0
    var removeRotationItemsAndResetArgs:[[String:Any]] = Array()
    var removeRotationItemsAndResetResponse:RotationItemsCollection?
    var removeRotationItemsAndResetError:APIError?
    var removeRotationItemsAndResetShouldNeverReturn:Bool = false
    override func removeRotationItemsAndReset(rotationItemIDs: [String]) -> Promise<RotationItemsCollection> {
        self.removeRotationItemsAndResetCount += 1
        self.removeRotationItemsAndResetArgs.append(["rotationItemIDs": rotationItemIDs])
        return Promise
        {
            (fulfill, reject) -> Void in
            if (!self.removeRotationItemsAndResetShouldNeverReturn)
            {
                if (self.removeRotationItemsAndResetShouldSucceed)
                {
                    return fulfill(self.removeRotationItemsAndResetResponse!)
                }
                return reject(self.removeRotationItemsAndResetError!)
            }
        }
    }
}
