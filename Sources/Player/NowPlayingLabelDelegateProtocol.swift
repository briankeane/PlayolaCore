//
//  NowPlayingLabelDelegateProtocol.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

@objc public protocol NowPlayingLabelDelegate
{
    // -----------------------------------------------------------------------------
    //                     optional func alternateDisplayText
    // -----------------------------------------------------------------------------
    /**
     This function can be used to override the default value of the display text for an AutoUpdatingLabel.  It will be called anytime that nowPlaying changes, and will provide a dictionary representation of the currently playing AudioBlock.  If nowPlaying is now nil, then audioBlockDict will be nil.
     
     Returning nil falls back to the default value. For example if you want to only override if the new spin is a CommercialBlock, the function should look like this:
     
     ### Usage Example: ###
     ````
     func alternateDisplayText(_ label:UILabel, audioBlockDict:[String:Any]?)
     {
        if let isCommercialBlock = audioBlockDict?["isCommercialBlock"] as? Bool
        {
            if (isCommercialBlock)
            {
                return "Money, Money, Money"
            }
        }
        return nil
     }
     ````
     
     - parameters:
        - label: `(AutoUpdatingLabel)` - the label to update
        - audioBlockDict: `([String:Any]?)` - a dictionary representation of the currently playing AudioBlock
        - defaultText: `(String)` - the default text that will be displayed if not modified by this
     
     - returns:
     `String?` - return nil to use default value, otherwise return a String to override the default value
     */
    @objc optional func alternateDisplayText(_ label:NowPlayingLabel, audioBlockDict:[String:Any]?, defaultText:String) -> String?
}
