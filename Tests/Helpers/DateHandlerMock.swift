//
//  DateHandlerMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class DateHandlerMock:DateHandlerService
{
    var actualTimeStarted:Date = Date()
    var mockStartDate:Date! = Date()
    
    func setStartDate(_ date:Date)
    {
        self.mockStartDate = date
        self.actualTimeStarted = Date()
    }
    
    override func now() -> Date!
    {
        return self.convertDateToMockDate(Date())
    }
    
    func convertDateToMockDate(_ date:Date) -> Date!
    {
        return self.mockStartDate.addingTimeInterval(-self.actualTimeStarted.timeIntervalSince(date))
    }
    
    override func adjustedDate(_ date: Date?) -> Date?
    {
        if let date = date
        {
            return self.convertMockDateToRealDate(date)
        }
        else
        {
            return nil
        }
    }
    
    func convertMockDateToRealDate(_ date: Date) -> Date
    {
        return self.actualTimeStarted.addingTimeInterval(-self.mockStartDate.timeIntervalSince(date))
    }
}
