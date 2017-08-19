//
//  DateHandlerMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class DateHandlerMock:DateHandlerService
{
    // default mockdate
    var mockedDate:Date!
    
    init(dateAsReadableString:String = "2015-03-15 13:15:00") {
        super.init()
        self.mockedDate = Date(dateString: dateAsReadableString)
    }
    override func now() -> Date! {
        return mockedDate
    }
    
    func setDate(_ date:Date!) {
        self.mockedDate = date
    }
}

