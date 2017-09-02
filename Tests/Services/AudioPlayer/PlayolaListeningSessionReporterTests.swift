//
//  PlayolaListeningSessionReporterTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/31/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation


import XCTest
import Quick
import Nimble


class PlayolaListeningSessionReporterQuickTests: QuickSpec
{
    override func spec()
    {
        describe("PlayolaListeningSessionReporter Tests")
        {
            var apiMock:PlayolaAPIMock! = PlayolaAPIMock()
            var currentUserInfoMock:PlayolaCurrentUserInfoMock!
            var reporter:PlayolaListeningSessionReporter!
            
            beforeEach
            {
                apiMock = PlayolaAPIMock()
                currentUserInfoMock = PlayolaCurrentUserInfoMock()
                reporter = PlayolaListeningSessionReporter()
                reporter.injectDependencies(api: apiMock, currentUserInfo: currentUserInfoMock)
            }
            
            afterEach
            {
                reporter.removeObservers()
            }
            
            it ("reports a listeningSession started when logged in")
            {
                currentUserInfoMock.user = User(userInfo: ["id": "theUsersID"])
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo:
                    ["broadcasterID":"aBroadcastersID"])
                expect(apiMock.reportListeningSessionCallCount).toEventually(equal(1))
                expect(apiMock.reportListeningSessionArgs[0]).to(equal("aBroadcastersID"))
            }
            
            it ("reports a listening session started when not logged in")
            {
                currentUserInfoMock.user = nil
                currentUserInfoMock.deviceIDToProvide = "aDeviceID"
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, userInfo:
                    ["broadcasterID":"aBroadcastersID"])
                expect(apiMock.reportAnonymousListeningSessionCallCount).toEventually(equal(1))
                
                expect(apiMock.reportAnonymousListeningSessionArgs.count).toEventually(equal(1))
                print("here")
                expect((apiMock.reportAnonymousListeningSessionArgs[0]["broadcasterID"] as! String)).to(equal("aBroadcastersID"))
                expect((apiMock.reportAnonymousListeningSessionArgs[0]["deviceID"] as! String)).to(equal("aDeviceID"))
            }
            
            it ("reports a listening session ended when logged in")
            {
                currentUserInfoMock.user = User(userInfo: ["id": "theUsersID"])
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stoppedPlayingStation, object: nil, userInfo:
                    ["broadcasterID":"aBroadcastersID"])
                expect(apiMock.reportEndOfListeningSessionCallCount).toEventually(equal(1))
            }
            
            it ("reports a listening session ended when not logged in")
            {
                currentUserInfoMock.user = nil
                currentUserInfoMock.deviceIDToProvide = "aDeviceID"
                NotificationCenter.default.post(name: PlayolaStationPlayerEvents.stoppedPlayingStation, object: nil, userInfo:
                    ["broadcasterID":"aBroadcastersID"])
                expect(apiMock.reportEndOfAnonymousListeningSessionCallCount).toEventually(equal(1))
                
                expect(apiMock.reportEndOfAnonymousListeningSessionArgs.count).toEventually(equal(1))
                print("here")
                expect(apiMock.reportEndOfAnonymousListeningSessionArgs[0]).to(equal("aDeviceID"))
            }
        }
    }
}
