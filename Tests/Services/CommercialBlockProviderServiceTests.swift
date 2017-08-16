//
//  CommercialBlockProviderServiceTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble
@testable import playolaIphone


class CommercialBlockProviderServiceQuickTests: QuickSpec {
    
    override func spec()
    {
        describe("CommercialBlockProviderService")
        {
            var currentUser:User?
            var mockedSharedData:SharedDataService = SharedDataService()
            let commercialBlockProvider:CommercialBlockProviderService = CommercialBlockProviderService.sharedInstance()
            
            class MockSharedData:SharedDataService
            {
            }
            
            beforeEach
                {
                    mockedSharedData = MockSharedData()
                    mockedSharedData.currentUser = DataMocker.generateUsers(1)[0]
                    currentUser = mockedSharedData.currentUser
            }
            
            it ("provides a commercial block")
            {
                mockedSharedData.currentUser!.lastCommercial!["audioFileID"] = 50
                var commercialBlocks:[AudioBlock] = commercialBlockProvider.getCommercialBlocks(5, sharedData: mockedSharedData)
                expect(commercialBlocks[0].__t).to(equal("CommercialBlock"))
                expect(commercialBlocks[0].duration).to(equal(currentUser!.secsOfCommercialPerHour!/2*1000))
                expect(commercialBlocks[0].title!).to(equal("Commercial Block"))
                
                for i in 0..<commercialBlocks.count
                {
                    let audioFileString = commercialBlocks[i].audioFileUrl!
                    expect(audioFileString[audioFileString.index(audioFileString.startIndex, offsetBy: 36)..<audioFileString.index(audioFileString.startIndex, offsetBy: 40)]).to(equal(String(format: "%04d", arguments: [i+1])))
                }
            }
            
            it ("provides an EOM, BOO, and EOI")
            {
                mockedSharedData.currentUser!.lastCommercial!["audioFileID"] = 50
                var commercialBlocks:[AudioBlock] = commercialBlockProvider.getCommercialBlocks(5, sharedData: mockedSharedData)
                expect(commercialBlocks[0].eom).to(equal(179000))
                expect(commercialBlocks[0].boo).to(equal(179000))
                expect(commercialBlocks[0].eoi).to(equal(0))
            }
            
            it ("loops back to the beginning of the commercialBlocks")
            {
                mockedSharedData.currentUser!.lastCommercial!["audioFileID"] = 26
                var commercialBlocks:[AudioBlock] = commercialBlockProvider.getCommercialBlocks(5, sharedData: mockedSharedData)
                let audioFileString = commercialBlocks[1].audioFileUrl!
                expect(audioFileString[audioFileString.index(audioFileString.startIndex, offsetBy: 36)..<audioFileString.index(audioFileString.startIndex, offsetBy: 40)]).to(equal(String(format: "%04d", arguments: [1])))
            }
            
            it ("provides unique IDs")
            {
                mockedSharedData.currentUser!.lastCommercial!["audioFileID"] = 1
                let commercialBlocks:Array<AudioBlock> = commercialBlockProvider.getCommercialBlocks(2, sharedData: mockedSharedData)
                expect(commercialBlocks[0].id).toNot(beNil())
                expect(commercialBlocks[1].id).toNot(beNil())
                expect(commercialBlocks[0].id).toNot(equal(commercialBlocks[1].id))
            }
        }
    }
    
}
