//
//  CommercialBlockProviderTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/25/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble

class CommercialBlockProviderServiceQuickTests: QuickSpec {
    
    override func spec()
    {
        describe("CommercialBlockProviderService")
        {
            var dataMocker:DataMocker!
            var currentUser:User?
            var mockedCurrentUserInfo:PlayolaCurrentUserInfoService!
            let commercialBlockProvider:CommercialBlockProviderService = CommercialBlockProviderService.sharedInstance()
            
            beforeEach
            {
                dataMocker = DataMocker()
                mockedCurrentUserInfo = PlayolaCurrentUserInfoService()
                mockedCurrentUserInfo.user = dataMocker.generateUsers(1)[0]
                currentUser = mockedCurrentUserInfo.user
                
                commercialBlockProvider.setValuesForKeys([
                    "currentUserInfo": mockedCurrentUserInfo
                    ])
            }
            
            it ("provides a commercial block")
            {
                mockedCurrentUserInfo.user!.lastCommercial!["audioFileID"] = 50
                var commercialBlocks:[AudioBlock] = commercialBlockProvider.getCommercialBlocks(5)
                expect(commercialBlocks[0].__t).to(equal("CommercialBlock"))
                expect(commercialBlocks[0].duration).to(equal(currentUser!.secsOfCommercialPerHour!/2*1000))
                expect(commercialBlocks[0].title!).to(equal("Commercial Block"))
                
                for i in 0..<commercialBlocks.count
                {
                    let audioFileString = String(describing: commercialBlocks[i].audioFileUrl!.absoluteURL)
                    expect(String(audioFileString[audioFileString.index(audioFileString.startIndex, offsetBy: 36)..<audioFileString.index(audioFileString.startIndex, offsetBy: 40)])).to(equal(String(format: "%04d", arguments: [i+1])))
                }
            }
            
            it ("provides an EOM, BOO, and EOI")
            {
                mockedCurrentUserInfo.user!.lastCommercial!["audioFileID"] = 50
                var commercialBlocks:[AudioBlock] = commercialBlockProvider.getCommercialBlocks(5)
                expect(commercialBlocks[0].eom).to(equal(179000))
                expect(commercialBlocks[0].boo).to(equal(179000))
                expect(commercialBlocks[0].eoi).to(equal(0))
            }
            
            it ("loops back to the beginning of the commercialBlocks")
            {
                mockedCurrentUserInfo.user!.lastCommercial!["audioFileID"] = 26
                var commercialBlocks:[AudioBlock] = commercialBlockProvider.getCommercialBlocks(5)
                let audioFileString = String(describing: commercialBlocks[1].audioFileUrl!.absoluteURL)
                expect(String(audioFileString[audioFileString.index(audioFileString.startIndex, offsetBy: 36)..<audioFileString.index(audioFileString.startIndex, offsetBy: 40)])).to(equal(String(format: "%04d", arguments: [1])))
            }
            
            it ("provides unique IDs")
            {
                mockedCurrentUserInfo.user!.lastCommercial!["audioFileID"] = 1
                let commercialBlocks:Array<AudioBlock> = commercialBlockProvider.getCommercialBlocks(2)
                expect(commercialBlocks[0].id).toNot(beNil())
                expect(commercialBlocks[1].id).toNot(beNil())
                expect(commercialBlocks[0].id).toNot(equal(commercialBlocks[1].id))
            }
        }
    }
}
