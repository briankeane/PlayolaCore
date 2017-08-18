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
                    case .failure:  // could add (let error) later if needed
                        print(response.result.value as Any)
                        
                        let authErr = AuthError.createFromAlamofireResponse(response)
                        reject(authErr)
                    }
                }
        }
    }
    
    
    // -----------------------------------------------------------------------------
    //                          func getRotationItems
    // -----------------------------------------------------------------------------
    /**
     Gets the current user's RotationItemsCollection from the server
     
     ### Usage Example: ###
     ````
     authService.getRotationItems()
     .then
     {
        (rotationItemsCollection) -> Void in
        print(rotationItemsCollection.listBins())
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
        `Promise<User>` - a promise
     
            * resolves to: a RotationItemsCollection
            * rejects: an AuthError
     */
    func getRotationItems() -> Promise<RotationItemsCollection>
    {
        let url = "\(baseURL)/api/v1/users/me/rotationItems"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, parameters: parameters, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        let rotationItemsCollection:RotationItemsCollection = RotationItemsCollection(rawRotationItems: (response.result.value as? NSDictionary)!["rotationItems"] as! Dictionary<String, Array<Dictionary<String, AnyObject>>>)
                            
                            fulfill(rotationItemsCollection)
                    case .failure:
                        let authErr = AuthError.createFromAlamofireResponse(response)
                        reject(authErr)
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func getActiveSessionsCount
    // -----------------------------------------------------------------------------
    /**
     Gets the current number of listeners for a station
     
      - parameters:
          - broadcasterID: `(String)` - the id of the station
     
     ### Usage Example: ###
     ````
     authService.getActiveSessionsCount()
     .then
     {
        (count) -> Void in
        print(count)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: a RotationItemsCollection
     * rejects: an AuthError
     */
    
    func  getActiveSessionsCount(broadcasterID:String) -> Promise<Int>
    {
        let url = "\(baseURL)/api/v1/listeningSessions/activeSessionsCount"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = ["broadcasterID" : broadcasterID]
        return Promise
            {
                fulfill, reject in
                Alamofire.request(url, parameters:parameters, headers:headers)
                    .validate(statusCode: 200..<300)
                    .responseJSON
                    {
                        (response) -> Void in
                        switch response.result
                        {
                        case .success:
                            if let responseDictionary:NSDictionary = response.result.value as? NSDictionary
                            {
                                if let count = responseDictionary["count"] as? Int
                                {
                                    fulfill(count)
                                }
                            }
                        case .failure(let error):
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
