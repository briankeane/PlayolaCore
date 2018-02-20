//
//  ParseSignInResponseOperation.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/18/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Alamofire
import SwiftyJSON

class ParseSignInResponseOperation: ParsingOperation
{
    var token:String?
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
                    self.token = dataJSON["token"].string
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
