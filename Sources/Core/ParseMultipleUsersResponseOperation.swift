//
//  ParseMultipleUsersResponseOperation.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/18/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Alamofire
import SwiftyJSON

class ParseMultipleUsersResponseOperation: ParsingOperation
{
    var key:String?
    var users:[User]?
    
    init(key:String? = nil) {
        super.init()
        self.key = key
    }
    
    override func main() {
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
                    
                    // if there is a key, use it
                    let jsonArray:[JSON] = (self.key != nil) ? dataJSON[self.key!].arrayValue : dataJSON.arrayValue
                    self.users = jsonArray.map({User(json: $0)})
                }
            }
        }
        if (self.users == nil)
        {
            self.apiError = APIError(response: self.response!)
        }
        executing(false)
        finish(true)
    }
}
