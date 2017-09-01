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
            var api:PlayolaAPIMock! = PlayolaAPIMock()
//            var currentUserInfoServiceMock! = PlayolaCurrentUserInfoMock()
            var reporter:PlayolaListeningSessionReporter! = PlayolaListeningSessionReporter()
            
            beforeEach
            {
                reporter.injectDependencies(api: api)
            }
            
            it ("reports a listeningSession started")
            {
                PlayolaCurrentUserInfoService.sharedInstance()
            }
        }
    }
}
