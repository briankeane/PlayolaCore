//
//  ParseEmpty.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 4/26/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import SwiftyJSON
import Alamofire

class ParseEmpty: ParsingOperation {
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
            if (!(200..<300 ~= statusCode))
            {
                self.apiError = APIError(response: self.response!)
            }
        }
        executing(false)
        finish(true)
    }
}
