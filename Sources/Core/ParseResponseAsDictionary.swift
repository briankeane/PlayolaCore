//
//  ParseResponseAsDictionary.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/18/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

class ParseResponseAsDictionary: ParsingOperation
{
    var responseDict:[String:Any]?
    
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
                if let rawValue = response.result.value as? [String:Any]
                {
                    self.responseDict = rawValue
                }
            }
        }
        if (self.responseDict == nil)
        {
            self.apiError = APIError(response: response)
        }
        executing(false)
        finish(true)
    }
                    
}
