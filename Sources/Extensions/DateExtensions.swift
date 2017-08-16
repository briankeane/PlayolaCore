//
//  DateExtensions.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation



// from http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift


extension Date
{
    // -----------------------------------------------------------------------------
    //                          func convenience init
    //------------------------------------------------------------------------------
    /// initializes a date with a String in the format `yyyy-MM-dd HH:mm:ss`
    ///
    /// - parameters:
    ///     - dateString: String - a String in the format `yyyy-MM-dd HH:mm:ss`
    /// ----------------------------------------------------------------------------
    init(dateString:String)
    {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
    
    init?(isoString:String?)
    {
        if let isoString = isoString
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            
            if let newDate = dateFormatter.date(from: isoString)
            {
                self.init(timeInterval:0, since: newDate)
                return
            }
        }
        return nil
    }
    
    // -----------------------------------------------------------------------------
    //                          func isAfter
    //------------------------------------------------------------------------------
    /// returns true if self is after the provided date
    ///
    /// - parameters:
    ///     - dateToCompare: NSDate - the date to compare
    ///
    /// - returns:
    ///     - Bool - true/false value indicating self is after
    /// ----------------------------------------------------------------------------
    func isAfter(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    // -----------------------------------------------------------------------------
    //                          func isBefore
    //------------------------------------------------------------------------------
    /// returns true if self is before the provided date
    ///
    /// - parameters:
    ///     - dateToCompare: NSDate - the date to compare
    ///
    /// - returns:
    ///     - Bool - true/false value indicating self is before
    /// ----------------------------------------------------------------------------
    func isBefore(_ dateToCompare : Date) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    // -----------------------------------------------------------------------------
    //                          func addDays
    //------------------------------------------------------------------------------
    /// returns an NSDate with x days added to self
    ///
    /// - parameters:
    ///     - daysToAdd: Int - number of days to add
    ///
    /// - returns:
    ///     - NSDate - a new NSDate
    /// ----------------------------------------------------------------------------
    func addDays(_ daysToAdd : Int) -> Date
    {
        let secondsInDays : TimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : Date = self.addingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    // -----------------------------------------------------------------------------
    //                          func addDays
    //------------------------------------------------------------------------------
    /// returns an NSDate with x days added to self
    ///
    /// - parameters:
    ///     - daysToAdd: Int - number of days to add
    ///
    /// - returns:
    ///     - NSDate - a new NSDate
    /// ----------------------------------------------------------------------------
    func addHours(_ hoursToAdd : Int) -> Date
    {
        let secondsInHours : TimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : Date = self.addingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
    
    // -----------------------------------------------------------------------------
    //                          func addMinutes
    //------------------------------------------------------------------------------
    /// returns an NSDate with x minutes added to self
    ///
    /// - parameters:
    ///     - daysToAdd: Int - number of minutes to add
    ///
    /// - returns:
    ///     - NSDate - a new NSDate
    /// ----------------------------------------------------------------------------
    func addMinutes(_ minutesToAdd : Int) -> Date {
        let secondsInMinutes : TimeInterval = Double(minutesToAdd) * 60
        let dateWithMinutesAdded : Date = self.addingTimeInterval(secondsInMinutes)
        
        //Return Result
        return dateWithMinutesAdded
    }
    
    // -----------------------------------------------------------------------------
    //                          func addSeconds
    //------------------------------------------------------------------------------
    /// returns an NSDate with x seconds added to self
    ///
    /// - parameters:
    ///     - secondsToAdd: Int - number of seconds to add
    ///
    /// - returns:
    ///     - NSDate - a new NSDate
    /// ----------------------------------------------------------------------------
    func addSeconds(_ secondsToAdd : Int) -> Date {
        let secondsInSeconds : TimeInterval = Double(secondsToAdd)
        let dateWithSecondsAdded : Date = self.addingTimeInterval(secondsInSeconds)
        
        //Return Result
        return dateWithSecondsAdded
    }
    
    // -----------------------------------------------------------------------------
    //                          func addMilliseconds
    //------------------------------------------------------------------------------
    /// returns an NSDate with x ms added to self
    ///
    /// - parameters:
    ///     - msToAdd: Int - number of ms to add
    ///
    /// - returns:
    ///     - NSDate - a new NSDate
    /// ----------------------------------------------------------------------------
    func addMilliseconds(_ msToAdd : Int) -> Date {
        let millisecondsInSeconds: TimeInterval = Double(msToAdd)/1000.0
        let dateWithMSAdded : Date = self.addingTimeInterval(millisecondsInSeconds)
        
        //Return Result
        return dateWithMSAdded
    }
    
    // -----------------------------------------------------------------------------
    //                          func toISOString
    //------------------------------------------------------------------------------
    /// returns an ISOString representation of self
    ///
    /// - returns:
    ///     - String - an iso representation of the date, in `yyyy-MM-dd'T'HH:mm:ss.SSSZ` format
    /// ----------------------------------------------------------------------------
    func toISOString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
    
    // -----------------------------------------------------------------------------
    //                          func toBeautifulString
    //------------------------------------------------------------------------------
    /// returns a fucking beautiful string version of itself
    ///
    /// ----------------------------------------------------------------------------
    func toBeautifulString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm:ssa"
        return formatter.string(from: self).lowercased()
    }
    
    // -----------------------------------------------------------------------------
    //                          func toApiParamString
    // -----------------------------------------------------------------------------
    /// returns an apiParamString...
    ///
    /// example: "1983/04/15/13/30"
    ///
    /// ----------------------------------------------------------------------------
    func toApiParamString() -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd/HH/mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: self)
    }
    
    // -----------------------------------------------------------------------------
    //                          func timeSince
    //------------------------------------------------------------------------------
    /// returns a string representation of the time since self...
    ///
    /// - examples:
    ///     * "1 year ago"
    ///     * "Last Year"
    ///     * "5 days ago"
    ///
    /// - adapted from https://gist.github.com/jacks205/4a77fb1703632eb9ae79
    ///
    /// - returns:
    ///     - String - casual string representing time since the date
    ///
    /// ----------------------------------------------------------------------------
    func timeSince(_ numericDates:Bool = true) -> String {
        let date = self
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if (components.year! >= 2) {
            return "\(components.year!) years ago"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 year ago"
            } else {
                return "Last year"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) months ago"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 month ago"
            } else {
                return "Last month"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) weeks ago"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 week ago"
            } else {
                return "Last week"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) days ago"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) mins ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 min ago"
            } else {
                return "a min ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second!) secs ago"
        } else {
            return "Just now"
        }
    }
    
    // -----------------------------------------------------------------------------
    //                     class func stationEditCutoffTime
    //------------------------------------------------------------------------------
    /// returns an NSDate past which a station cannot be edited.  Currently this
    /// time is 6 minutes
    ///
    /// - returns:
    ///     - NSDate - a new NSDate
    ///
    /// ----------------------------------------------------------------------------
    static func stationEditCutoffTime() -> Date
    {
        return Date().addMinutes(MINUTES_OF_PRELOAD)
    }
}
