//
//  PlayolaModelRefreshsHandlerTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import XCTest
import Quick
import Nimble

class PlayolaModelRefreshHandlerTests: QuickSpec {
    override func spec()
    {
        describe("PlayolaModelRefreshHandler")
        {
            var apiMock:PlayolaAPIMock!
            var observers:[NSObjectProtocol] = Array()
            var refresher:PlayolaModelRefreshHandler = PlayolaModelRefreshHandler()
            var dataMocker:DataMocker!
            
            beforeEach
            {
                dataMocker = DataMocker()
                apiMock = PlayolaAPIMock()
                dataMocker.loadMocks()
                apiMock.getUserSuccessUser = dataMocker.users[0]!
                observers = Array()
                refresher = PlayolaModelRefreshHandler()
                refresher.setValuesForKeys([
                    "api": apiMock
                    ])
            }
            
            afterEach
            {
                for observer in observers
                {
                    NotificationCenter.default.removeObserver(observer)
                }
                observers = Array()
            }
            
            it ("responds to requests")
            {
                NotificationCenter.default.post(name: PlayolaEvents.userUpdateRequested, object: nil, userInfo: ["userID":"aUserID"])
                expect(apiMock.getUserCallCount).to(equal(1))
                expect(apiMock.getUserArgs[0]).to(equal("aUserID"))
            }
            
            it ("broadcasts the results")
            {
                NotificationCenter.default.post(name: PlayolaEvents.userUpdateRequested, object: nil, userInfo:["userID":"aUserID"])
                
                var broadcastDisplayName = "wrongDisplayName"
                
                let observer = NotificationCenter.default.addObserver(forName: PlayolaEvents.userUpdated, object: nil, queue: .main)
                {
                    (notification) -> Void in
                    let user:User = notification.userInfo!["user"] as! User
                    broadcastDisplayName = user.displayName!
                }
                observers.append(observer)
                expect(broadcastDisplayName).toEventually(equal(dataMocker.users[0]?.displayName))
            }
        }
    }
}
