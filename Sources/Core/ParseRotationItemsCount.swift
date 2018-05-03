//
//  ParseRotationItemsCount.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 5/3/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseRotationItemsCount: ParsingOperation {
    var rotationItemsCount:JSON?
    
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
                if (response.result.value != nil)
                {
                    self.rotationItemsCount = JSON(response.result.value!)
                    // old api --- remove after backend updated
                }
            }
        }
        
        if (self.rotationItemsCount == nil)
        {
            self.apiError = APIError(response: response)
        }
        executing(false)
        finish(true)
    }
}
