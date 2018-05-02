//
//  ParseRotationItemsCollection.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 2/18/18.
//  Copyright © 2018 Brian D Keane. All rights reserved.
//


class ParseRotationItemsCollection: ParsingOperation {
    var rotationItemsCollection:RotationItemsCollection?
    
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
                if let rawResponse = response.result.value as? [String:Any]
                {
                    // old api --- remove after backend updated
                    if let rawRotationItems = rawResponse["rotationItems"] as? [String: [[String:Any]]]
                    {
                        self.rotationItemsCollection = RotationItemsCollection(rawRotationItems: rawRotationItems)
                    }
                }
                else if let rawResponse = response.result.value as? [[String:Any]]
                {
                    self.rotationItemsCollection = RotationItemsCollection(rawRotationItemsArray: rawResponse)
                }
            }
        }
        
        if (self.rotationItemsCollection == nil)
        {
            self.apiError = APIError(response: response)
        }
        executing(false)
        finish(true)
    }
}
