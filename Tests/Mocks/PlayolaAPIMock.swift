//
//  PlayolaAPIMock.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import PromiseKit

class PlayolaAPIMock:PlayolaAPI {
    var getUserCallCount:Int = 0
    var getUserArgs:Array<String> = Array()
    var getUserShouldSucceed:Bool = true
    var getUserSuccessUser:User?
    var getUserFailureError:AuthError?
    
    override public func getUser(userID: String) -> Promise<User>
    {
        self.getUserCallCount += 1
        self.getUserArgs.append(userID)
        
        return Promise
        {
            (fulfill, reject) -> Void in
            if (self.getUserShouldSucceed)
            {
                fulfill(self.getUserSuccessUser!)
            }
            else
            {
                reject(self.getUserFailureError!)
            }
        }
    }
}
