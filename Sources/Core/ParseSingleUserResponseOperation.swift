//
//  ParseSingleUserResponseOperation.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/17/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import SwiftyJSON
import Alamofire

class ParseSingleUserResponseOperation: ParsingOperation {
    var user:User?
    
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
                    self.user = User(json: dataJSON["user"])
                }
            }
        }
        if (self.user == nil)
        {
            self.apiError = APIError(response: self.response!)
        }
        executing(false)
        finish(true)
    }
}
