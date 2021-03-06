//
//  PlayolaSchedulerTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/10/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation


import XCTest
import Quick
import Nimble


class PlayolaSchedulerTests: QuickSpec
{
    override func spec()
    {
        describe("PlayolaSchedulerTests")
        {
            var dataMocker:DataMocker!
            var dateMocker:DateHandlerMock!
            var user:UserMock!
            var apiMock:PlayolaAPIMock!
            var scheduler:PlayolaScheduler!
            
            beforeEach
            {
                dataMocker = DataMocker()
                dateMocker = DateHandlerMock()
                let seedUser = dataMocker.generateUsers(1)[0]
                user = UserMock(original: seedUser)
                dateMocker.setDate(user.program!.playlist![0].airtime!.addSeconds(-5))
                apiMock = PlayolaAPIMock()
                scheduler = PlayolaScheduler()
                scheduler.setValuesForKeys([
                    "DateHandler": dateMocker,
                    "api": apiMock
                    ])
                scheduler.setupUser(user: user)
            }
            
            afterEach
            {
                
            }
            
            describe("user model auto-modify")
            {
                it ("turns on autoUpdating")
                {
                    expect((scheduler.user as! UserMock).autoAdvancingStarted).to(equal(true))
                }
                
                it ("turns on autoAdvancing")
                {
                    expect((scheduler.user as! UserMock).autoUpdatingStarted).to(equal(true))
                }
            }
            
            describe("playlistTemporaryManipulations")
            {
                beforeEach
                {
                    scheduler.user.program!.playlist = [
                            Spin(id: "a", playlistPosition: 11, audioBlock: AudioBlock(id: "1a"), airtime: Date()),
                            Spin(id: "b", playlistPosition: 12, audioBlock: AudioBlock(id: "1b"), airtime: Date()),
                            Spin(id: "c", playlistPosition: 13, audioBlock: AudioBlock(id: "1c"), airtime: Date()),
                            Spin(id: "d", playlistPosition: 14, audioBlock: AudioBlock(id: "1d"), airtime: Date()),
                            Spin(id: "e", playlistPosition: 15, audioBlock: AudioBlock(id: "1e"), airtime: Date()),
                            Spin(id: "f", playlistPosition: 16, audioBlock: AudioBlock(id: "1f"), airtime: Date()),
                            Spin(id: "g", playlistPosition: 17, audioBlock: AudioBlock(id: "1g"), airtime: Date())
                                            ]
                }
                
                it ("temporarily moves a spin forward")
                {
                    scheduler.performTemporaryMoveSpin(fromPlaylistPosition: 12, toPlaylistPosition: 15)
                    let idMap = scheduler.user.program!.playlist!.map({$0.id!})
                    expect(idMap).to(equal(["a","c","d","e","b","f","g"]))
                    for (index, spin) in scheduler.user.program!.playlist!.enumerated()
                    {
                        if ((index >= 1) && (index <= 4))
                        {
                            expect(spin.airtime).to(beNil())
                        }
                        else
                        {
                            expect(spin.airtime).toNot(beNil())
                        }
                    }
                }
                
                it ("temporarily moves a spin backward")
                {
                    scheduler.performTemporaryMoveSpin(fromPlaylistPosition: 15, toPlaylistPosition: 12)
                    let idMap = scheduler.user.program!.playlist!.map({$0.id!})
                    expect(idMap).to(equal(["a","e","b","c","d","f","g"]))
                    for (index, spin) in scheduler.user.program!.playlist!.enumerated()
                    {
                        if ((index >= 1) && (index <= 4))
                        {
                            expect(spin.airtime).to(beNil())
                        }
                        else
                        {
                            expect(spin.airtime).toNot(beNil())
                        }
                    }
                }
            }
            
            describe("moveSpin")
            {
                it ("errors if invalid fromPlaylistPosition")
                {
                    
                }
                
                it ("nils the correct airtimes for a move")
                {
                    let movingSpin = scheduler.user.program!.playlist![3]
                    let fromPlaylistPosition = movingSpin.playlistPosition!
                    let toPlaylistPosition = scheduler.user.program!.playlist![6].playlistPosition!
                    apiMock.moveSpinShouldPause = true
                    scheduler.moveSpin(fromPlaylistPosition: fromPlaylistPosition, toPlaylistPosition: toPlaylistPosition)
                    .done
                    {
                        (playlist) -> Void in
                    }
                    .catch
                    {
                        (error) -> Void in
                        
                    }
                    let playlist = scheduler.playlist()!
                    expect(playlist.count) > 0
                    for spin in playlist
                    {
                        if ((spin.playlistPosition! >= fromPlaylistPosition) && (spin.playlistPosition! <= toPlaylistPosition))
                        {
                            expect(spin.airtime).to(beNil())
                        }
                        else
                        {
                            expect(spin.airtime).toNot(beNil())
                        }
                    }
                }
            }
            
            describe("getSpin")
            {
                it ("returns a spin if it exists")
                {
                    let movingSpin = scheduler.getSpin(playlistPosition: user.program!.playlist![3].playlistPosition!)
                    expect(movingSpin!.id).to(equal(user.program!.playlist![3].id!))
                }
                
                it ("returns nil if it does not exist")
                {
                    expect(scheduler.getSpin(playlistPosition:9999999)).to(beNil())
                }
            }
            
            describe("playlistPositionIsValid")
            {
                beforeEach
                {
                    // set date so that playlist[2] is the first ok airtime
                    dateMocker.setDate(scheduler.user.program!.playlist![2].airtime?.addSeconds(-(PlayolaConstants.LOCKED_SECONDS_OF_PRELOAD + 10)))
                }
                
                it ("returns true if it's first changeable one")
                {
                    expect(scheduler.playlistPositionIsValid(playlistPosition: user.program!.playlist![2].playlistPosition!)).to(equal(true))
                }
                
                it ("returns true if it's just after the schedule")
                {
                    expect(scheduler.playlistPositionIsValid(playlistPosition: user.program!.playlist!.last!.playlistPosition! + 1)).to(equal(true))
                }
                
                it ("returns false if it is too low")
                {
                    expect(scheduler.playlistPositionIsValid(playlistPosition: 1)).to(equal(false))
                }
                
                it ("returns false if it is too high")
                {
                    expect(scheduler.playlistPositionIsValid(playlistPosition: user.program!.playlist!.last!.playlistPosition! + 2)).to(equal(false))
                }
                
                it ("returns false if it is just before ok airtime")
                {
                    expect(scheduler.playlistPositionIsValid(playlistPosition: user.program!.playlist![1].playlistPosition!)).to(equal(false))
                }
            }
        }
    }
}
