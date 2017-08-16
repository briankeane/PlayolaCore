//
//  AuthService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class AuthService:NSObject
{
    
    // temporary
    var baseURL = "hi"
    var accessToken = "accessToken"
    
    // -----------------------------------------------------------------------------
    //                          func getMe
    // -----------------------------------------------------------------------------
    /// gets the current user from the playola server
    ///
    /// - returns:
    ///    `Promise<User>` - a promise that resolves to the current user
    ///
    /// ----------------------------------------------------------------------------
    func getMe() -> Promise<User>
    {
        let url = "\(baseURL)/api/v1/users/me"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = nil
        
        return Promise
        {
            fulfill, reject in
            Alamofire.request(url, parameters:parameters, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success(let JSON):
                        let responseData = JSON as! NSDictionary
                        let user:User = User(userInfo: response.result.value! as! NSDictionary)
                        fulfill(user)
                    case .failure(let error):
                        // For now, assuming this is a 401
                        reject(error)
                    }
                }
        }
    }
    //------------------------------------------------------------------------------
    //                  Singleton
    //------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the AuthService for all to use
    ///
    /// - returns:
    ///    `AuthService` - the central Auth Service instance
    ///
    /// ----------------------------------------------------------------------------
    class func sharedInstance() -> AuthService
    {
        if (self._instance == nil)
        {
            self._instance = AuthService()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:AuthService?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ authService:AuthService)
    {
        self._instance = authService
    }
}
