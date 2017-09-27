//
//  StationPlayingLabelDelegateProtocol.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/27/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

@objc public protocol StationPlayingLabelDelegate
{
    // -----------------------------------------------------------------------------
    //                     optional func alternateDisplayText
    // -----------------------------------------------------------------------------
    /**
     This function can be used to override the default value of the display text for an AutoUpdatingLabel.  It will be called anytime that the station changes, starts, or stops and will provide a dictionary representation of the user that is now playing.  If the station has stopped playing is now nil, then audioBlockDict will be nil.
     
     Returning nil falls back to the default value. For example if you want to only override if Bob's station has started playing:
     
     ### Usage Example: ###
     ````
     func alternateDisplayText(_ label:UILabel, audioBlockDict:[String:Any]?)
     {
        if let displayName = userPlayingDict?["displayName"] as? String
        {
            if (displayName == "BoB")
            {
                return "Douchebag"
            }
        }
        return nil
     }
     ````
     
     - parameters:
     - label: `(AutoUpdatingLabel)` - the label to update
     - userPlayingDict: `([String:Any]?)` - a dictionary representation of the currently playing AudioBlock
     
     - returns:
     `Promise<User>` - a promise that resolves to the current User
     
     
     
     - returns:
     `String?` - return nil to use default value, otherwise return a String to override the default value
     */
    @objc optional func alternateDisplayText(_ label:AutoUpdatingLabel, userPlayingDict:[String:Any]?) -> String?
}

