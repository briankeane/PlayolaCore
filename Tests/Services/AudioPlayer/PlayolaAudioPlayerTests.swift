//
//  PlayolaAudioPlayerTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

class PlayolaAudioPlayerTests: QuickSpec {
    override func spec()
    {
        describe("PlayolaAudioPlayer")
        {
            describe("loadAudio")
            {
                var dateHandlerMock:DateHandlerMock!
                var PAP:PlayolaAudioPlayer!
                
                beforeEach
                {
                    PAP = PlayolaAudioPlayer()
                    dateHandlerMock = DateHandlerMock(dateAsReadableString: "2015-03-15 13:15:00")
                    PAP.injectDependencies(dateHandler: dateHandlerMock)
                }
                
                // TODO: Figure out how to fucking test this
            }
        }
    }
}

