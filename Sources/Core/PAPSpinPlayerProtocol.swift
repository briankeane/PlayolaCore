//
//  PAPSpinPlayerProtocol.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 12/29/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public protocol PAPSpinPlayer
{
    func stop()
    func play(from:Double, to:Double?)
    func schedulePlay(at:Date)
    func loadFile(with url: URL)
    func setVolume(_ level:Float)
    var volume:Float { get }
    var duration:Double { get }
    var delegate:PlayerDelegate? { get set }
}

