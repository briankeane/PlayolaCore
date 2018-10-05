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
    
    override func getUser(userID: String, priority: Operation.QueuePriority) -> Promise<User>
    {
        self.getUserCallCount += 1
        self.getUserArgs.append(userID)
        
        return Promise
        {
            (seal) -> Void in
            if (self.getUserShouldSucceed)
            {
                seal.fulfill(self.getUserSuccessUser!)
            }
            else
            {
                seal.reject(self.getUserFailureError!)
            }
        }
    }
    
    var reportListeningSessionCallCount:Int = 0
    var reportListeningSessionArgs:Array<String> = Array()
    var reportListeningSessionShouldSucceed:Bool = true
    var reportListeningSessionSuccessDict = ["message": "success"]
    var reportListeningSessionFailureError:APIError?
    
    override func reportListeningSession(broadcasterID: String, priority: Operation.QueuePriority) -> Promise<[String : Any]>
    {
        self.reportListeningSessionCallCount += 1
        self.reportListeningSessionArgs.append(broadcasterID)
        
        return Promise
        {
            (seal) -> Void in
            if (self.reportListeningSessionShouldSucceed)
            {
                seal.fulfill(self.reportListeningSessionSuccessDict)
            }
            else
            {
                seal.reject(self.reportListeningSessionFailureError!)
            }
        }
    }
    
    var reportEndOfListeningSessionCallCount:Int = 0
    var reportEndOfListeningSessionShouldSucceed:Bool = true
    var reportEndOfListeningSessionSuccessDict = ["message": "success"]
    var reportEndOfListeningSessionFailureError:APIError?
    
    override func reportEndOfListeningSession(priority: Operation.QueuePriority) -> Promise<[String : Any]>
    {
        self.reportEndOfListeningSessionCallCount += 1
        
        return Promise
        {
            (seal) -> Void in
            if (self.reportEndOfListeningSessionShouldSucceed)
            {
                seal.fulfill(self.reportEndOfListeningSessionSuccessDict)
            }
            else
            {
                seal.reject(self.reportEndOfListeningSessionFailureError!)
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
            (seal) -> Void in
            if (self.reportAnonymousListeningSessionShouldSucceed)
            {
                seal.fulfill(self.reportListeningSessionSuccessDict)
            }
            else
            {
                seal.reject(self.reportAnonymousListeningSessionFailureError!)
            }
        }
    }
    
    var reportEndOfAnonymousListeningSessionCallCount:Int = 0
    var reportEndOfAnonymousListeningSessionArgs:Array<String> = Array()
    var reportEndOfAnonymousListeningSessionShouldSucceed:Bool = true
    var reportEndOfAnonymousListeningSessionSuccessDict = ["message": "success"]
    var reportEndOfAnonymousListeningSessionFailureError:APIError?
    
    override func reportEndOfAnonymousListeningSession(deviceID: String, priority: Operation.QueuePriority) -> Promise<[String : Any]>
    {
        self.reportEndOfAnonymousListeningSessionCallCount += 1
        self.reportEndOfAnonymousListeningSessionArgs.append(deviceID)
        return Promise
        {
            (seal) -> Void in
            if (self.reportEndOfAnonymousListeningSessionShouldSucceed)
            {
                seal.fulfill(self.reportEndOfListeningSessionSuccessDict)
            }
            else
            {
                seal.reject(self.reportEndOfAnonymousListeningSessionFailureError!)
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
            (seal) -> Void in
            if (self.moveSpinShouldPause)
            {
                return
            }
            else if (self.moveSpinShouldSucceed)
            {
                seal.fulfill(moveSpinSuccessUser!)
            }
            else if (!self.moveSpinShouldPause)
            {
                seal.reject(moveSpinFailureError!)
            }
        }
    }
    
    var getPresetsCallCount:Int = 0
    var getPresetsShouldSucceed:Bool = true
    var getPresetsArgs:[[String:Any?]] = Array()
    var getPresetsPresets:[User]?
    var getPresetsError:APIError?
    override func getPresets(userID: String, priority: Operation.QueuePriority) -> Promise<[User]>
    {
        self.getPresetsCallCount += 1
        self.getPresetsArgs.append(["userID": userID])
        return Promise
        {
            (seal) -> Void in
            if (self.getPresetsShouldSucceed)
            {
                return seal.fulfill(self.getPresetsPresets!)
            }
            return seal.reject(self.getPresetsError!)
        }
    }
    
    var requestSongBySpotifyIDShouldSucceed:Bool = true
    var requestSongBySpotifyIDCount:Int = 0
    var requestSongBySpotifyIDResponses:[(songStatus:SongStatus, song:AudioBlock?)]? = nil
    var requestSongBySpotifyIDSongStatus:SongStatus? = nil
    var requestSongBySpotifyIDError:APIError?
    var requestSongBySpotifyIDArgs:[[String:Any]] = Array()
    override func requestSongBySpotifyID(spotifyID: String, priority: Operation.QueuePriority) -> Promise<(songStatus: SongStatus, song: AudioBlock?)>
    {
        self.requestSongBySpotifyIDCount += 1
        self.requestSongBySpotifyIDArgs.append(["spotifyID": spotifyID])
        return Promise
        {
            (seal) -> Void in
            if (self.requestSongBySpotifyIDShouldSucceed)
            {
                return seal.fulfill(self.requestSongBySpotifyIDResponses!.removeFirst())
            }
            return seal.reject(self.requestSongBySpotifyIDError!)
        }
    }
    
    var getRotationItemsShouldSucceed:Bool = true
    var getRotationItemsCount:Int = 0
    var getRotationItemsResponse:RotationItemsCollection?
    var getRotationItemsError:APIError?
    var getRotationItemsShouldNeverReturn:Bool = false
    override func getRotationItems(priority: Operation.QueuePriority) -> Promise<RotationItemsCollection>
    {
        self.getRotationItemsCount += 1
        return Promise
        {
            (seal) -> Void in
            if (!self.getRotationItemsShouldNeverReturn)
            {
                if (self.getRotationItemsShouldSucceed)
                {
                    return seal.fulfill(self.getRotationItemsResponse!)
                }
                return seal.reject(self.getRotationItemsError!)
            }
        }
    }
    
    var deactivateRotationItemShouldSucceed:Bool = true
    var deactivateRotationItemCount:Int = 0
    var deactivateRotationItemArgs:[[String:Any]] = Array()
    var deactivateRotationItemResponse:RotationItemsCollection?
    var deactivateRotationItemError:APIError?
    var deactivateRotationItemShouldNeverReturn:Bool = false

    override func deactivateRotationItem(rotationItemID: String, priority: Operation.QueuePriority = .normal) -> Promise<RotationItemsCollection>
    {
        self.deactivateRotationItemCount += 1
        self.deactivateRotationItemArgs.append(["rotationItemID": rotationItemID])
        return Promise
        {
            (seal) -> Void in
            if (!self.deactivateRotationItemShouldNeverReturn)
            {
                if (self.deactivateRotationItemShouldSucceed)
                {
                    return seal.fulfill(self.deactivateRotationItemResponse!)
                }
                return seal.reject(self.deactivateRotationItemError!)
            }
        }
    }
    
    var removeRotationItemsAndResetShouldSucceed:Bool = true
    var removeRotationItemsAndResetCount:Int = 0
    var removeRotationItemsAndResetArgs:[[String:Any]] = Array()
    var removeRotationItemsAndResetResponse:RotationItemsCollection?
    var removeRotationItemsAndResetError:APIError?
    var removeRotationItemsAndResetShouldNeverReturn:Bool = false
    override func removeRotationItemsAndReset(rotationItemIDs: [String], priority: Operation.QueuePriority) -> Promise<RotationItemsCollection>
    {
        self.removeRotationItemsAndResetCount += 1
        self.removeRotationItemsAndResetArgs.append(["rotationItemIDs": rotationItemIDs])
        return Promise
        {
            (seal) -> Void in
            if (!self.removeRotationItemsAndResetShouldNeverReturn)
            {
                if (self.removeRotationItemsAndResetShouldSucceed)
                {
                    return seal.fulfill(self.removeRotationItemsAndResetResponse!)
                }
                return seal.reject(self.removeRotationItemsAndResetError!)
            }
        }
    }
}
