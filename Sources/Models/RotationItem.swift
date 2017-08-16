//
//  RotationItem.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

class RotationItem
{
    var eoi:Int?
    var eom:Int?
    var boo:Int?
    var bin:String
    var song:AudioBlock
    var userID:String
    var history:Array<Dictionary<String,AnyObject>>
    var id:String
    
    //------------------------------------------------------------------------------
    
    init(rawDictionary:Dictionary<String,Any>)
    {
        if let eoi = rawDictionary["eoi"] as! Int?
        {
            self.eoi = eoi
        }
        if let eom = rawDictionary["eom"] as! Int?
        {
            self.eom = eom
        }
        if let boo = rawDictionary["boo"] as! Int?
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
    
    init(bin:String, song:AudioBlock, userID:String, boo:Int?=nil, eoi:Int?=nil, eom:Int?=nil, history:Array<Dictionary<String,AnyObject>>=[], id:String)
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
}
