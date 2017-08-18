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
                        let authErr = AuthError(response: response)
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
                        let authErr = AuthError(response: response)
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
     `Promise<Int>` - a promise
     * resolves to: an integer
     * rejects: an AuthError
     */
    
    func  getActiveSessionsCount(broadcasterID:String) -> Promise<Int>
    {
        let url = "\(baseURL)/api/v1/listeningSessions/activeSessionsCount"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = ["broadcasterID" : broadcasterID]
        return Promise
        {
            (fulfill, reject) in
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
                    case .failure:
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func getPresets
    // -----------------------------------------------------------------------------
    /**
     Gets a user's presets.  If no userID is provided it gets the current user's
     presets.
     
     - parameters:
     - userID: `(String?)` - OPTIONAL - the owner of the desired presets.
     
     ### Usage Example: ###
     ````
     authService.getPresets()
     .then
     {
        (presets) -> Void in
        for user in presets
        {
            print(user.name)
        }
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: an array of Users
     * rejects: an AuthError
     */
    func getPresets(userID:String="me") -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/\(userID)/presets"
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
                        if let presets = arrayOfUsersFromResultValue(resultValue: response.result.value, propertyName: "presets")
                        {
                            return fulfill(presets)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func getTopUsers
    // -----------------------------------------------------------------------------
    /**
     Gets the current top Playola broadcasters from the server
     
     ### Usage Example: ###
     ````
     authService.getTopUsers()
     .then
     {
        (topUsers) -> Void in
        for user in topUsers
        {
            print(user.name)
        }
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: an array of Users
     * rejects: an AuthError
     */
    func getTopUsers() -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/topUsers"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, parameters:parameters, headers:headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let users = arrayOfUsersFromResultValue(resultValue: response.result.value, propertyName: "topUsers")
                        {
                            return fulfill(users)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func updateUser
    // -----------------------------------------------------------------------------
    /**
     Updates the current user's info on the playola server.
     
     /// - parameters:
     ///     - updateInfo: `(Dictionary<String,Any>)` - a dictionary of the properties to update
     
     ### Usage Example: ###
     ````
     authService.updateUser(["displayName":""])
     .then
     {
        (updated) -> Void in
        print(updatedUser.displayName)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: an updated user
     * rejects: an AuthError
     */
    func updateUser(_ updateInfo:Dictionary<String, Any>) -> Promise<User?>
    {
        let url = "\(baseURL)/api/v1/users/me"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = updateInfo
        
        return Promise
        {
            fulfill, reject in
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseJSON
                {
                    response -> Void in
                    switch response.result
                    {
                    case .success(let JSON):
                        let responseData = JSON as! NSDictionary
                        if let statusCode:Int = response.response?.statusCode
                        {
                            if (statusCode == 200)
                            {
                                let rawUser:Dictionary<String,AnyObject> = (responseData.object(forKey: "user") as? Dictionary<String, AnyObject>)!
                                let user:User = User(userInfo: rawUser as NSDictionary)
                                    fulfill(user)
                            }
                            else if (statusCode == 422)
                            {
                                reject(AuthError(response: response))
                            }
                        }
                    case .failure:
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func follow
    // -----------------------------------------------------------------------------
    /**
     Follows another user
     
      - parameters:
          - broadcasterID: `(String)` - the id of the user to follow
     
     ### Usage Example: ###
     ````
     authService.follow(["thisIsAUserID")
     .then
     {
        (updatedPresets) -> Void in
        self.presets = updatedPresets
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: the updated presets array
     * rejects: an AuthError
     */
    func follow(broadcasterID:String) -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/\(broadcasterID)/follow"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, method: .put, encoding: JSONEncoding.default, headers: headers)
                //.validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let presets = arrayOfUsersFromResultValue(resultValue: response.result.value, propertyName: "presets")
                        {
                            return fulfill(presets)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        reject(AuthError(response: response))
                    }
                }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func unfollow
    // -----------------------------------------------------------------------------
    /**
     Removes a user from the currentUser's presets
     
     - parameters:
     - broadcasterID: `(String)` - the id of the user to follow
     
     ### Usage Example: ###
     ````
     authService.unfollow(["thisIsAUserID")
     .then
     {
        (updatedPresets) -> Void in
        self.presets = updatedPresets
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: the updated presets array
     * rejects: an AuthError
     */
    func unfollow(broadcasterID:String) -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/\(broadcasterID)/unfollow"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, method: .put, encoding: JSONEncoding.default, headers: headers)
                //.validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let presets = arrayOfUsersFromResultValue(resultValue: response.result.value, propertyName: "presets")
                        {
                            return fulfill(presets)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        reject(AuthError(response: response))
                    }
                }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func findUsersByKeywords
    // -----------------------------------------------------------------------------
    /**
     Searches for a user via the provided searchString
     
     - parameters:
     - searchString: `(String)` - duh
     
     ### Usage Example: ###
     ````
     authService.findUsersByKeywords("Bob")
     .then
     {
        (searchResults) -> Void in
        for user in searchResults
        {
            print(user.displayName)
        }
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: the updated presets array
     * rejects: an AuthError
     */
    func findUsersByKeywords(searchString:String) -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/findByKeywords"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = ["searchString": searchString]
        
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, parameters:parameters, headers:headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let foundUsers = arrayOfUsersFromResultValue(resultValue: response.result.value, propertyName: "searchResults")
                        {
                            return fulfill(foundUsers)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        reject(AuthError(response: response))
                    }
                }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func getMultipleUsers
    // -----------------------------------------------------------------------------
    /**
     Takes an array of userIDs and gets the users from the server
     
     - parameters:
     - userIDs: `(Array<String>)` - duh
     
     ### Usage Example: ###
     ````
     authService.getMultipleUsers(userIDs: [users[0].id, users[1].id])
     .then
     {
        (updatedUsers) -> Void in
        for user in updatedUsers
        {
            print(user.displayName)
        }
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: the updated presets array
     * rejects: an AuthError
     */
    func getMultipleUsers(userIDs:Array<String>) -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/getMultipleUsers"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters:Parameters? = ["userIDs": userIDs]
        
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, parameters:parameters, headers:headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let foundUsers = arrayOfUsersFromResultValue(resultValue: response.result.value, propertyName: "searchResults")
                        {
                            return fulfill(foundUsers)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        reject(AuthError(response: response))
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func getUsersByAttributes
    // -----------------------------------------------------------------------------
    /// gets an array of users from the server
    ///
    /// - parameters:
    ///     - facebookUIDs: `(Array<String>)` - an array of facebookUIDs
    ///     - googleUIDs: `(Array<String>)` - an array of googleUIDs
    ///     - emails: `(Array<String>)` - an array of emails
    ///
    /// - returns:
    ///    `Promise<Array<User!>` - an array of matching users
    ///
    /// ----------------------------------------------------------------------------
    // ----------------------------------------------------------------------------
    //                          func getUsersByAttributes
    // -----------------------------------------------------------------------------
    /**
     Searches the playola server for users matching the provided attributes
     
     - parameters:
        - attributes: `(Dictionary<String,Any>)` - a dictionary of the search attributes
            -- currently supported attributes:
                * facebookUIDs `(Array<String>)`
                * googleUIDs `(Array<String>)`
                * email `(String)`
     
     ### Usage Example: ###
     ````
     authService.getUsersByAttributes(attributes: [ "email": "bob@bob.com" ])
     .then
     {
        (searchResults) -> Void in
        for user in searchResults
        {
            print(user.displayName)
        }
    }
    .catch (err)
    {
        print(err)
    }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: the updated presets array
     * rejects: an AuthError
     */
    func getUsersByAttributes(attributes:Dictionary<String,Any>) -> Promise<Array<User>>
    {
        let url = "\(baseURL)/api/v1/users/getByAttributes"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        let parameters = attributes
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, parameters:parameters, headers:headers)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if ((response.response!.statusCode >= 200) && (response.response!.statusCode <= 300))
                        {
                            if let foundUsers = arrayOfUsersFromResultValue(resultValue: response.result.value, propertyName: "searchResults")
                            {
                                return fulfill(foundUsers)
                            }
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        reject(AuthError(response: response))                    }
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



fileprivate func arrayOfUsersFromResultValue(resultValue:Any?, propertyName:String) -> Array<User>?
{
    if let resultDict = resultValue as? Dictionary<String,Any>
    {
        if let rawUsers = resultDict[propertyName] as? Array<NSDictionary>
        {
            return rawUsers.map({
                            (rawUser) -> User in
                            return User(userInfo: rawUser as NSDictionary)
            })
        }
    }
    return nil
}

fileprivate func buildUsersByAttributesParameters(facebookUIDs:Array<String>?=nil, googleUIDs:Array<String>?=nil, emails:Array<String>?=nil, deepLink:String?=nil) -> Parameters?
{
    var params:Parameters = Parameters()
    if let facebookUIDs = facebookUIDs
    {
        params["facebookUIDs"] = facebookUIDs as AnyObject?
    }
    if let googleUIDs = googleUIDs
    {
        params["googleUIDs"] = googleUIDs as AnyObject?
    }
    if let emails = emails
    {
        params["emails"] = emails as AnyObject?
    }
    
    if let deepLink = deepLink
    {
        params["deepLink"] = deepLink as AnyObject?
    }
    if (params.count == 0)
    {
        return nil
    }
    else
    {
        return params
    }
}
