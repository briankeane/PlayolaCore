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
            var dateMocker:DateHandlerMock! = DateHandlerMock()
            var user:UserMock!
            var apiMock:PlayolaAPIMock! = PlayolaAPIMock()
            var scheduler:PlayolaScheduler!
            
            beforeEach
            {
                dateMocker = DateHandlerMock()
                let seedUser = DataMocker.generateUsers(1)[0]!
                user = UserMock(original: seedUser)
                dateMocker.setDate(user.program!.playlist![0].airtime!.addSeconds(-5))
                apiMock = PlayolaAPIMock()
                scheduler = PlayolaScheduler()
                scheduler.injectDependencies(DateHandler: dateMocker, api: apiMock)
                scheduler.setupUser(user: user)
            }
            
            afterEach
            {
                
            }
            
            describe("user model auto-modify")
            {
                it ("turns on autoUpdating")
                {
                    expect(user.autoAdvancingStarted).to(equal(true))
                }
                
                it ("turns on autoAdvancing")
                {
                    expect(user.autoUpdatingStarted).to(equal(true))
                }
            }
            
            describe("playlistTemporaryManipulations")
            {
                beforeEach
                {
                    user.program!.playlist = [
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
                    for (index, spin) in user.program!.playlist!.enumerated()
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
                    for (index, spin) in user.program!.playlist!.enumerated()
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
                
                it ("detects different indexes")
                {
                    var copiedPlaylist = user.program!.playlist!.map { $0.copy() }
                    copiedPlaylist[3].airtime = Date()
                    copiedPlaylist[2].id = "newID"
                    copiedPlaylist[5].audioBlock = AudioBlock(id:"newAudioBlockID")
                    let differentIndexes = scheduler.differentIndexes(oldPlaylist: user.program!.playlist!, newPlaylist: copiedPlaylist)
                    expect(differentIndexes).to(equal([2,3,5]))
                }
                
                it ("returns nil if different counts")
                {
                    var copiedPlaylist = user.program!.playlist!.map { $0.copy() }
                    copiedPlaylist.remove(at: 0)
                    let differentIndexes = scheduler.differentIndexes(oldPlaylist: user.program!.playlist!, newPlaylist: copiedPlaylist)
                    expect(differentIndexes).to(beNil())
                }
            }
            
            describe("moveSpin")
            {
                it ("errors if invalid fromPlaylistPosition")
                {
                    
                }
                
                it ("nils the correct airtimes for a move")
                {
                    let movingSpin = user.program!.playlist![3]
                    let fromPlaylistPosition = movingSpin.playlistPosition!
                    let toPlaylistPosition = user.program!.playlist![6].playlistPosition!
                    apiMock.moveSpinShouldPause = true
                    scheduler.moveSpin(fromPlaylistPosition: fromPlaylistPosition, toPlaylistPosition: toPlaylistPosition)
                    .then
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
                    expect(scheduler.getSpin(playlistPosition:9999999999)).to(beNil())
                }
            }
            
            describe("playlistPositionIsValid")
            {
                beforeEach
                {
                    // set date so that playlist[2] is the first ok airtime
                    dateMocker.setDate(user.program!.playlist![2].airtime?.addSeconds(-(PlayolaConstants.LOCKED_SECONDS_OF_PRELOAD + 10)))
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
