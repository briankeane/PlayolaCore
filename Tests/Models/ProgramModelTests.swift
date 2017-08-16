//
//  ProgramModelTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble

class ProgramModelQuickTests: QuickSpec {
    
    override func spec()
    {
        describe("Program Model Tests")
        {
            var rawPlaylist:Array<Dictionary<String,Any>> = []
            var dateHandlerMock:DateHandlerMock = DateHandlerMock()
//            var commercialBlockProviderMock = CommercialBlockProviderMock()
            
//            beforeEach
//                {
//                    dateHandlerMock = DateHandlerMock()
//                    commercialBlockProviderMock = CommercialBlockProviderMock()
//                    rawPlaylist = [
//                        [ "id": "spinNowPlaying" as AnyObject, "airtime": Date(dateString: "2015-3-15 13:10:00").toISOString() ],
//                        [ "id": "spin1", "airtime": Date(dateString: "2015-3-15 13:13:00").toISOString() ],
//                        [ "id": "spin2", "airtime": Date(dateString: "2015-3-15 13:16:00").toISOString(), "isCommercialBlock": true ],
//                        [ "id": "spin3", "airtime": Date(dateString: "2015-3-15 13:19:00").toISOString() ],
//                        [ "id": "spin4", "airtime": Date(dateString: "2015-3-15 13:21:00").toISOString() ],
//                        [ "id": "spin5", "airtime": Date(dateString: "2015-3-15 13:24:00").toISOString() ],
//                        [ "id": "spin6", "airtime": Date(dateString: "2015-3-15 13:27:00").toISOString(), "isCommercialBlock": true ],
//                        [ "id": "spin7", "airtime": Date(dateString: "2015-3-15 13:30:00").toISOString() ]
//                    ]
//            }
//            
//            it ("initializes with a playlist")
//            {
//                var newProgram = Program(rawPlaylist: rawPlaylist, DateHandler: dateHandlerMock as DateHandlerService)
//                expect(newProgram.playlist![0].id).to(equal("spin2"))
//                
//                dateHandlerMock.mockedDate = Date(dateString: "2015-3-15 13:22:00")
//                newProgram = Program(rawPlaylist: rawPlaylist, DateHandler: dateHandlerMock)
//                expect(newProgram.nowPlaying!.id).to(equal("spin4"))
//                expect(newProgram.playlist![0].id).to(equal("spin5"))
//            }
//            
//            describe("bringCurrent()")
//            {
//                it ("brings the program current")
//                {
//                    let newProgram = Program(rawPlaylist: rawPlaylist, DateHandler: dateHandlerMock as DateHandlerService, commercialBlockProvider: commercialBlockProviderMock)
//                    dateHandlerMock.mockedDate = dateHandlerMock.createNSDateFromReadableString("2015-3-15 13:22:00")
//                    newProgram.bringCurrent()
//                    expect(newProgram.nowPlaying!.id).to(equal("spin4"))
//                    expect(newProgram.playlist![0].id).to(equal("spin5"))
//                }
//            }
//            
//            describe("nowPlaying()")
//            {
//                it ("gets the nowPlaying() spin")
//                {
//                    let newProgram = Program(rawPlaylist: rawPlaylist, DateHandler: dateHandlerMock as DateHandlerService)
//                    dateHandlerMock.mockedDate = dateHandlerMock.createNSDateFromReadableString("2015-3-15 13:22:00")
//                    newProgram.bringCurrent()
//                    expect(newProgram.getNowPlaying()!.id).to(equal("spin4"))
//                }
//            }
//            
//            it ("provides super fucking entertaining commercials")
//            {
//                let newProgram = Program(rawPlaylist: rawPlaylist, DateHandler: dateHandlerMock as DateHandlerService)
//                expect(newProgram.playlist!.count > 0).to(beTrue())
//                for i in 0..<newProgram.playlist!.count
//                {
//                    if (newProgram.playlist![i].id == "spin2") || (newProgram.playlist![i].id == "spin6") {
//                        expect(newProgram.playlist![i].audioBlock!.id).to(contain("commercialBlock"))
//                    }
//                }
//            }
//            
//            it ("can tell if it's the same as another program")
//            {
//                dateHandlerMock.mockedDate = Date(dateString: "2015-3-15 13:22:00")
//                let newProgram = Program(rawPlaylist: rawPlaylist)
//                let otherProgram = Program(rawPlaylist: rawPlaylist)
//                expect(newProgram.isSameAs(otherProgram)).to(beTrue())
//            }
//            
//            it ("can tell if it's not the same as another program")
//            {
//                dateHandlerMock.mockedDate = Date(dateString: "2015-3-15 13:22:00")
//                let newProgram = Program(rawPlaylist: rawPlaylist, DateHandler: dateHandlerMock as DateHandlerService)
//                let otherProgram = Program(rawPlaylist: rawPlaylist, DateHandler: dateHandlerMock as DateHandlerService)
//                otherProgram.playlist![0].id = "newID"
//                expect(newProgram.isSameAs(otherProgram)).to(beFalse())
//            }
        }
    }
}
