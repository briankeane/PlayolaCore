//
//  DateHandlerService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class DateHandlerService
{
    // -----------------------------------------------------------------------------
    //                          func now
    //------------------------------------------------------------------------------
    /// provides the current date -- same as NSDate() but wrapped to allow mocking
    ///
    /// - returns:
    ///     - Date - the current date
    /// --------------------------------------------------------------------------
    func now() -> Date!
    {
        return Date()
    }
    
    // -----------------------------------------------------------------------------
    //                          func createNSDateFromReadableString
    //------------------------------------------------------------------------------
    /// creates an NSDate from inputted string, format: `yyyy-MM-dd' 'HH:mm:ss`
    ///
    /// - returns:
    ///     - Date! - the corresponding unwrapped NSDate
    /// --------------------------------------------------------------------------
    func createNSDateFromReadableString (_ dateString:String!) -> Date!
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        
        let newDate = dateFormatter.date(from: dateString)
        return newDate
    }
    
    // -----------------------------------------------------------------------------
    //                          func adjustedDate
    // -----------------------------------------------------------------------------
    /// adjusts a date according to the appwide reference time
    ///
    /// - parameters:
    ///     - date: `(Date?)` - the date to adjust
    ///
    /// - returns:
    ///    `NSDate?` - the adjusted date
    ///
    /// ----------------------------------------------------------------------------
    func adjustedDate(_ date:Date?) -> Date?
    {
        return date
    }
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the DateHandlerClass for all to use
    ///
    /// - returns:
    ///    `DateHandlerClass` - the central image uploader instance
    ///
    /// ----------------------------------------------------------------------------
    class func sharedInstance() -> DateHandlerService
    {
        if (self._instance == nil)
        {
            self._instance = DateHandlerService()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:DateHandlerService?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ DateHandler:DateHandlerService)
    {
        self._instance = DateHandler
    }
    
}
