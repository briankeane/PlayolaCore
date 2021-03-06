//
//  RotationItem.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

open class RotationItem: Hashable
{
    public var eoi:Int?
    public var eom:Int?
    public var boo:Int?
    public var bin:String
    public var song:AudioBlock
    public var userID:String
    public var history:Array<Dictionary<String,AnyObject>>
    public var id:String
    public var removalInProgress:Bool = false
    
    //------------------------------------------------------------------------------
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: RotationItem, rhs: RotationItem) -> Bool {
        return lhs.id == rhs.id && lhs.id == rhs.id
    }
    
    public init(rawDictionary:[String:Any])
    {
        if let eoi = rawDictionary["eoi"] as? Int
        {
            self.eoi = eoi
        }
        if let eom = rawDictionary["eom"] as? Int
        {
            self.eom = eom
        }
        if let boo = rawDictionary["boo"] as? Int
        {
            self.boo = boo
        }
        self.bin = (rawDictionary["bin"] as? String)!
        self.song = AudioBlock(audioBlockInfo: (rawDictionary["song"]) as! Dictionary<String,AnyObject>)
        self.userID = (rawDictionary["userID"] as? String)!
        self.history = (rawDictionary["history"] as? Array<Dictionary<String,AnyObject>>)!
        self.id = (rawDictionary["id"] as? String)!
    }
    
    //------------------------------------------------------------------------------
    
    public init(id:String="", bin:String="", song:AudioBlock, userID:String="", boo:Int?=nil, eoi:Int?=nil, eom:Int?=nil, history:[Dictionary<String,AnyObject>]=Array())
    {
        self.bin = bin
        self.eoi = eoi
        self.eom = eom
        self.boo = boo
        self.song = song
        self.userID = userID
        self.history = history
        self.id = id
    }
    
    public func toDictionary() -> [String:Any]
    {
        return [
            "eoi": self.eoi as Any,
            "eom": self.eom as Any,
            "boo": self.boo as Any,
            "bin": self.bin as Any,
            "song": self.song.toDictionary() as Any,
            "userID": self.userID as Any,
            "history": self.history as Any,
            "id": self.id as Any,
            "removalInProgress": self.removalInProgress as Any
        
        ]
    }
}
