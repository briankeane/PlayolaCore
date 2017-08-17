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
    var baseURL = PlayolaConstants.BASE_URL
    var accessToken = "accessToken"
    
    // -----------------------------------------------------------------------------
    //                          func getMe
    // -----------------------------------------------------------------------------
    /**
     Gets the current user from the playola server
     
     ### Usage Example: ###
     ````
     authService.getMe()
     .then
     {
        (user) -> Void in
        print(user.name)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
        `Promise<User>` - a promise
            
            * resolves to: a User
            * rejects: an AuthError
     */
    func getMe() -> Promise<User>
    {
        let url = "\(self.baseURL)/api/v1/users/me"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, parameters:parameters, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        let user:User = User(userInfo: response.result.value! as! NSDictionary)
                        fulfill(user)
                    case .failure(let _):  // error
                        print(response.result.value as Any)
                        var message:String?
                        if let dict = response.result.value as? [String:Any?]
                        {
                            if let unwrappedMessage = dict["message"] as? String
                            {
                                message = unwrappedMessage
                            }
                        }
                        
                        let authErr = AuthError.create(statusCode: response.response?.statusCode, message: message)
                        reject(authErr)
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
