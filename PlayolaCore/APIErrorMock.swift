//
//  APIErrorMock.swift
//  playolaCore
//
//  Created by Brian D Keane on 11/14/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

class APIErrorMock:APIError
{
    init(type:APIErrorType?) {
        self.storedType = type
    }
    
    var storedType:APIErrorType?
    override open func type() -> APIErrorType
    {
        // if something has been stored, use it
        if let storedType = self.storedType
        {
            return storedType
        }
        return super.type()
    }
}

