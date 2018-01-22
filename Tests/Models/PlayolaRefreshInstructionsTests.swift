//
//  PlaylistRefreshInstructionsTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 12/25/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble

class PlaylistRefreshInstructionsTests: QuickSpec
{
    override func spec()
    {
        describe ("RefreshInstructions")
        {
            var dataMocker:DataMocker!
            var oldProgram:Program!
            
            beforeEach
            {
                dataMocker = DataMocker()
                oldProgram = dataMocker.generateProgram("aUserID")
            }
            
            it ("works if both playlists are nil")
            {
                let instructions = PlaylistRefreshInstructions(oldPlaylist:nil, newPlaylist:nil)
                expect(instructions.fullReload).to(equal(false))
                expect(instructions.reloadIndexes.count).to(equal(0))
            }
            
            it ("returns .full if both oldPlaylist is nil")
            {
                let instructions = PlaylistRefreshInstructions(oldPlaylist:nil, newPlaylist:oldProgram.playlist)
                expect(instructions.fullReload).to(equal(true))
            }
            
            it ("returns .full if newPlaylist is nil")
            {
                let instructions = PlaylistRefreshInstructions(oldPlaylist:oldProgram.playlist, newPlaylist: nil)
                expect(instructions.fullReload).to(equal(true))
            }
            
            it ("returns .noReload if programs are identical")
            {
                let newProgram = oldProgram.copy()
                let instructions = PlaylistRefreshInstructions(oldPlaylist: oldProgram.playlist, newPlaylist: newProgram.playlist)
                expect(instructions.fullReload).to(equal(false))
                expect(instructions.reloadIndexes.count).to(equal(0))
                expect(instructions.removeItemAtIndex).to(beNil())
            }
            
            describe ("nowPlayingAdvanced")
            {
               xit ("detects a nowPlaying advance")
               {
                    var newProgram = oldProgram.copy()
                    newProgram.nowPlaying = newProgram.playlist?.removeFirst()
                    let instructions = PlaylistRefreshInstructions(oldPlaylist: oldProgram.playlist, newPlaylist: newProgram.playlist)
                    expect(instructions.fullReload).to(equal(false))
                    expect(instructions.removeItemAtIndex).to(equal(0))
                    expect(instructions.reloadIndexes).to(equal([]))
                }
                
                xit ("detects a nowPlaying advance with some random reloads")
                {
                    var newProgram = oldProgram.copy()
                    newProgram.nowPlaying = newProgram.playlist?.removeFirst()
                    newProgram.playlist![2].id = "randomID"
                    newProgram.playlist![3].airtime = nil
                    let instructions = PlaylistRefreshInstructions(oldPlaylist: oldProgram.playlist, newPlaylist: newProgram.playlist)
                    expect(instructions.removeItemAtIndex).to(equal(0))
                    expect(instructions.reloadIndexes).to(equal([2,3]))
                }
                
                it ("properly works for a moved spin")
                {
                    var newProgram = oldProgram.copy()
                    let movedSpin = newProgram.playlist!.remove(at: 4)
                    newProgram.playlist!.insert(movedSpin, at: 2)
                    let instructions = PlaylistRefreshInstructions(oldPlaylist: oldProgram.playlist, newPlaylist: newProgram.playlist)
                    expect(instructions.fullReload).to(equal(false))
                    expect(instructions.removeItemAtIndex).to(beNil())
                    expect(instructions.reloadIndexes).to(equal([2,3,4]))
                }
                
                it ("properly works for a removed spin")
                {
                    var newProgram = oldProgram.copy()
                    let removedSpin = newProgram.playlist!.remove(at: 4)
                    for index in 4..<newProgram.playlist!.count
                    {
                        newProgram.playlist![index].airtime = nil
                    }
                    let instructions = PlaylistRefreshInstructions(oldPlaylist: oldProgram.playlist, newPlaylist: newProgram.playlist)
                    expect(instructions.fullReload).to(equal(false))
                    expect(instructions.removeItemAtIndex).to(equal(4))
                    
                    let reloadIndexes = [Int](4...(newProgram.playlist!.count-1))
                    expect(instructions.reloadIndexes).to(equal(reloadIndexes))
                }
            }
        }
    }
    
}
