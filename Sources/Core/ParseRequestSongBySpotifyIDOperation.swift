//
//  ParseRequestSongBySpotifyIDOperation.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/18/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import SwiftyJSON

class ParseRequestSongBySpotifyIDOperation: ParsingOperation
{
    var song:AudioBlock?
    var songStatus:SongStatus?
    
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
                    
                    // old v1  -- THIS branch can be erased after
                    // update
                    if (dataJSON["songStatus"].exists())
                    {
                        if (dataJSON["songStatus"]["code"].exists())
                        {
                            self.songStatus = SongStatus(rawValue: dataJSON["songStatus"]["code"].intValue)
                        }
                        if (self.songStatus == .songExists)
                        {
                            if (dataJSON["song"].exists())
                            {
                                self.song = AudioBlock(json: dataJSON["song"])
                            }
                        }
                    } else {
                        if (dataJSON["status"].stringValue == "The song has been processed")
                        {
                            self.songStatus = .songExists
                            self.song = AudioBlock(json: dataJSON["song"])
                        }
                        else
                        {
                            if (dataJSON["is_processing"].bool != true)
                            {
                                self.songStatus = .failedToAcquire
                            }
                            else
                            {
                                self.songStatus = SongStatus.processing
                            }
                        }
                    }
                }
            }
        }
        if (self.songStatus == nil)
        {
            self.apiError = APIError(response: response)
        }
        executing(false)
        finish(true)
    }
}
