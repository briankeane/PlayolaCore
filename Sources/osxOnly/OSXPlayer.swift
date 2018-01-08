//
//  OSXPlayer.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 1/3/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation

public class Player:NSObject, PAPSpinPlayer
{

    convenience public init(delegate:PlayerDelegate?) {
        self.init()
        self.delegate = delegate
    }
    public func stop() {
        puts("stop")
    }
    
    public func play(from: Double, to: Double?) {
        puts("play")
    }
    
    public func schedulePlay(at: Date) {
        puts("schedulePlay")
    }
    
    public func loadFile(with url: URL) {
        puts("loadFile")
    }
    
    public func setVolume(_ level: Float) {
        puts("setVolume")
    }
    
    public var volume: Float = 0.0
    
    public var duration: Double = 0.0
    
    public var delegate: PlayerDelegate?
    
    
}
