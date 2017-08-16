//
//  DataMocker.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//
import Foundation
import PromiseKit

class MockerOfData
{
    var defaultRules = [
        "artistMinimumRest": [ "minutesOfRest": 70 ],
        "songMinimumRest": [ "minutesOfRest": 180 ],
        "dayOffset": [ "windowSizeMinutes": 60 ]
    ]
    var key:String = generateRandomKey(5) as String
    
    var users:Array<User?> = []
    var rawUsers: Array<Dictionary<String,Any>> = []
    var rotationItemsCollection:RotationItemsCollection = RotationItemsCollection(rawRotationItems: Dictionary())
    var rawRotationItemsCollection:Dictionary<String,Array<Dictionary<String,Any>>> = Dictionary()
    
    var DateHandler:DateHandlerService!
    
    init(DateHandler:DateHandlerService = DateHandlerService.sharedInstance())
    {
        self.DateHandler = DateHandler
        self.loadMocks()
    }
    
    func loadMocks()
    {
        self.rawUsers = self.getRawServerUsers(10)
        self.users = rawUsers.map
            {
                (rawUser) -> User! in
                return User(userInfo: rawUser as NSDictionary)
        }
        self.rawRotationItemsCollection = self.generateRawRotationItemsObject()
        self.rotationItemsCollection = RotationItemsCollection(rawRotationItems: rawRotationItemsCollection)
    }
    
    func getRawServerUsers (_ count:Int) -> Array<Dictionary<String, Any>>
    {
        var rawUsers:Array<Dictionary<String,Any>> = []
        for _ in 0..<count
        {
            let key = generateRandomKey(5)
            let rawUserInfo:Dictionary<String,Any> = [
                "displayName": "Bob\(key)",
                "twitterUID": "BobsTwitterUID\(key)",
                "facebookUID": "BobsFacebookUID\(key)",
                "googleUID": "BobsGoogleUID\(key)",
                "instagramUID": "BobsInstagramUID\(key)",
                "email": "bob@bob.com\(key)",
                "birthYear": "1903\(key)",
                "gender": "male\(key)",
                "zipcode": "78748\(key)",
                "role": "user\(key)",
                "lastCommercial": [ "audioFileID": 24,
                                    "commercialBlockNumber": 799240 ],
                "profileImageUrl": "http://bob.com/bigPic.jpg\(key)",
                "profileImageUrlSmall": "http://bob.com/smallPic.jpg\(key)",
                "id": "ThisIsBobsID\(key)",
                "secsOfCommercialPerHour": 360,
                "dailyListenTimeMS": 20000,
                "timezone": "America/Chicago",
                "playlist": self.generateRawPlaylist("ThisIsBobsID\(key)")
            ]
            rawUsers.append(rawUserInfo)
        }
        return rawUsers
    }
    
    func generateUsers (_ count:Int) -> [User?] {
        let rawUsers = self.getRawServerUsers(count)
        return rawUsers.map({ (rawUser) -> User! in
            return User(userInfo: rawUser as NSDictionary)
        })
    }
    
    func generateRawPlaylist (_ userID : String?) -> Array<Dictionary<String,Any>>
    {
        var userID = userID
        if userID == nil
        {
            userID = generateRandomKey(6)
        }
        
        let key = generateRandomKey(7)
        var playlistPositionTracker = Int(arc4random_uniform(6)+1)
        var timeTracker = Date().addMinutes(-6)
        
        var rawSpins:Array<Dictionary<String,Any>> = []
        for _ in 0..<10
        {
            let spinInfo: Dictionary<String,Any> = [   "id": "\(generateRandomKey(5))\(key)" as AnyObject,
                                                       "isCommercialBlock": false,
                                                       "playlistPosition": playlistPositionTracker,
                                                       "audioBlock": [ "__t":"Song",
                                                                       "duration": 180000,
                                                                       "echonestID":"echonestID\(key)",
                                                        "boo":2000,
                                                        "eoi":2200,
                                                        "eom":2100,
                                                        "title":"title\(key)",
                                                        "id":"\(generateRandomKey(5))",
                                                        "audioFileUrl": "url\(key)",
                                                        "key":"key"
                ],
                                                       "audioBlockID":"audioBlockIID\(key)",
                "userID":userID!,
                "airtime":timeTracker.toISOString(),
                "endTime":timeTracker.addSeconds(180).toISOString()
            ]
            rawSpins.append(spinInfo)
            timeTracker = timeTracker.addSeconds(180)
            playlistPositionTracker = playlistPositionTracker + 1
        }
        
        return rawSpins
    }
    
    func generateProgram (_ userID : String?) -> Program
    {
        return Program(rawPlaylist: self.generateRawPlaylist(userID))
    }
    
    func generateSongs (_ count : Int) -> [AudioBlock]
    {
        var rawSongs:[NSDictionary] = self.generateRawSongs(count) as [NSDictionary]
        var songs = [AudioBlock]()
        for i in 0..<rawSongs.count
        {
            songs.append(AudioBlock(audioBlockInfo: rawSongs[i] as! Dictionary<String, AnyObject>))
        }
        return songs
    }
    
    func generateRawSongs (_ count:Int) -> Array<Dictionary<String,Any>>
    {
        let key = generateRandomKey(6)
        var songs:Array<Dictionary<String,Any>> = []
        for _ in 0..<count
        {
            songs.append([ "artist":"artist\(key)",
                "title":"title\(key)",
                "id":"id\(key)",
                "album":"album\(key)",
                "echonestID":"echonestID\(key)",
                "albumArtworkUrl":"albumArtworkUrl\(key)",
                "albumArtworkUrlSmall":"albumArtworkUrlSmall\(key)",
                "trackViewUrl":"trackViewUrl\(key)",
                "eoi":1000,
                "eom":179000,
                "boo":175000,
                "audioFileUrl":"audioFileUrl\(key)",
                "key":"key\(key)",
                "duration": 180000,
                "__t": "Song"])
        }
        return songs
    }
    
    // determineBin (for rotationItem generation)
    func determineBin(_ totalSongs:Int, index:Int) -> String
    {
        if (Double(index) <= floor(Double(totalSongs)/4.0))
        {
            return "heavy"
        }
        else if (Double(index) <= floor((Double(totalSongs))/2.0))
        {
            return "medium"
        }
        else
        {
            return "light"
        }
    }
    
    func generateRotationItemsObject(_ count:Int=12) -> RotationItemsCollection
    {
        let rawRotationItemsObject = self.generateRawRotationItemsObject(count)
        return RotationItemsCollection(rawRotationItems: rawRotationItemsObject)
    }
    
    func generateRawRotationItemsObject(_ count:Int=12) -> Dictionary<String, Array<Dictionary<String, AnyObject>>>
    {
        
        
        var rawSongs = generateRawSongs(count)
        var riObjects:  Dictionary<String, Array<Dictionary<String, AnyObject>>> = ["heavy": [[String:AnyObject]](), "medium": [[String:AnyObject]](), "light": [[String:AnyObject]]()]
        
        for i in 0..<rawSongs.count
        {
            let key:String = generateRandomKey(5)
            var item = [ "id": "id\(key)",
                "song": rawSongs[i],
                "songID": rawSongs[i]["id"]!,
                "userID": "userID\(key)",
                "history": [],
                "boo": 170000,
                "eoi": 1000,
                "eom": 178000
                ] as [String : Any]
            let bin:String = determineBin(count, index: i)
            item["bin"] = bin
            
            riObjects[bin]?.append(item as [String : AnyObject])
        }
        return riObjects
    }
    
    func generateRotationItemsFromSongs(_ songs:Array<AudioBlock>, userID:String) -> Array<RotationItem>
    {
        var rotationItems:Array<RotationItem> = []
        
        for i in 0..<songs.count
        {
            let key:String = generateRandomKey(5)
            let bin:String = determineBin(songs.count, index: i)
            let rotationItem = RotationItem(    bin: bin,
                                                song: songs[i],
                                                userID: userID,
                                                boo: 170000,
                                                eoi: 1000,
                                                eom: 178000,
                                                id: "id\(key)")
            
            rotationItems.append(rotationItem)
        }
        return rotationItems
    }

}


// -----------------------------------------------------------------------------
//                          func generateRandomKey
//------------------------------------------------------------------------------
/// generates a random string of x length with capital, lowercase, numerical
/// characters only.
///
/// - parameters:
///     - len: Int - length of the desired string
///
/// - returns:
///     - String - a random string of alphanumeric characters
/// ----------------------------------------------------------------------------
func generateRandomKey (_ len : Int) -> String
{
    let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString : NSMutableString = NSMutableString(capacity: len)
    
    for i in 0..<len
    {
        let length = UInt32 (letters.length)
        let rand = arc4random_uniform(length)
        randomString.appendFormat("%C", letters.character(at: Int(rand)))
    }
    
    return randomString as String
}

let DataMocker = MockerOfData()
