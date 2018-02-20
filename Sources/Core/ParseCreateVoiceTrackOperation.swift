//
//  ParseCreateVoiceTrackOperation.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/18/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import SwiftyJSON

class ParseCreateVoiceTrackOperation: ParsingOperation {
    var voiceTrack:AudioBlock?
    var voiceTrackStatus:VoiceTrackStatus?
    
    override func main()
    {
        guard (self.isCancelled == false) else {
            self.finish(true)
            return
        }
        
        self.executing(true)
        guard let response = response else {
            executing(false)
            finish(true)
            return
        }
        
        if let statusCode = response.response?.statusCode
        {
            if (200..<300 ~= statusCode)
            {
                if let rawValue = response.result.value
                {
                    let dataJSON = JSON(rawValue)
                    if (dataJSON["voiceTrackStatus"]["code"].exists())
                    {
                        self.voiceTrackStatus = VoiceTrackStatus(rawValue: dataJSON["voiceTrackStatus"]["code"].intValue)
                    }
                    if (self.voiceTrackStatus == .completed )
                    {
                        if (dataJSON["voiceTrack"].exists())
                        {
                            self.voiceTrack = AudioBlock(json: dataJSON["voiceTrack"])
                        }
                    }
                }
            }
        }
        if (self.voiceTrackStatus == nil)
        {
            self.apiError = APIError(response: response)
        }
        executing(false)
        finish(true)
    }
}
