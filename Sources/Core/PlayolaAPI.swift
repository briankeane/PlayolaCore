//
//  PlayolaAPI.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/16/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

public class PlayolaAPI:NSObject
{
    // temporary
    var baseURL = PlayolaConstants.BASE_URL
    var accessToken:String?
    
    let defaults:UserDefaults = UserDefaults.standard
    var observers:[NSObjectProtocol] = Array()
    
    
    /// use to set your own development Playola server or to
    public func setBaseURL(baseURL:String)
    {
        self.baseURL = baseURL
    }
    
    public func isSignedIn() -> Bool
    {
        return self.accessToken != nil
    }
    
    public func signOut()
    {
        self.clearAccessToken()
        NotificationCenter.default.post(name: PlayolaEvents.signedOut, object: nil)
    }
    
    private func setAccessToken(tokenValue:String)
    {
        self.accessToken = tokenValue
        defaults.set(tokenValue, forKey: "playolaAccessToken")
    }
    
    private func clearAccessToken()
    {
        defaults.set(nil, forKey: "playolaAccessToken")
        self.accessToken = nil
    }
    
    override public init() {
        super.init()
        self.checkForAccessToken()
    }
    
    
    // FOR TESTING ONLY -- SHOULD REMAIN NON-PUBLIC
    init(accessTokenString:String?, baseURL:String?)
    {
        super.init()
        self.accessToken = accessTokenString
        if let baseURL = baseURL
        {
            self.baseURL = baseURL
        }
    }
    
    private func checkForAccessToken()
    {
        if let accessToken = defaults.string(forKey: "playolaAccessToken")
        {
            self.accessToken = accessToken
            
            // trigger update of current user
            self.getMe()
            .then
            {
                (user) -> Void in
                
            }
            .catch
            {
                (error) -> Void in
            }
        }
    }
    
    private func headersWithAuth(baseHeaders:HTTPHeaders?=nil) -> HTTPHeaders?
    {
        // if not signedIn and no headers
        if ((baseHeaders == nil) && (self.accessToken == nil))
        {
            return nil
        }
        
        // blank headers if necessary
        var modifiedHeaders:HTTPHeaders? = baseHeaders
        if (modifiedHeaders == nil)
        {
            modifiedHeaders = [:]
        }
        
        if let accessToken = self.accessToken
        {
            modifiedHeaders?["Authorization"] = "Bearer \(accessToken)"
        }
        return modifiedHeaders
    }
    
    deinit
    {
        self.removeObservers()
    }
    
    private func removeObservers()
    {
        for observer in self.observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func loginViaFacebook
    // -----------------------------------------------------------------------------
    /**
     Logs the user into the playolaServer via the accessToken they received from facebook.
     
    - parameters:
         - accessTokenString: `(String)` - the facebook accessTokenString
    
     - returns:
        `Promise<User>` - a promise that resolves to the current User
     
     ### Usage Example: ###
     ````
     api.loginViaFacebook(accessTokenString: "theTokenStringReceivedFromFacebook")
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
    
    public func loginViaFacebook(accessTokenString:String) -> Promise<(User)>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
            let parameters:Parameters = ["accessToken":accessTokenString]
            let url = "\(baseURL)/auth/facebook/mobile"
                
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:[:])
            .validate(statusCode: 200..<300)
            .responseJSON
            {
                (response) -> Void in
                switch response.result
                {
                case .success:
                    if let foundUserData = response.result.value as? [String:Any]
                    {
                        if let receivedToken = foundUserData["token"] as? String
                        {
                            self.setAccessToken(tokenValue: receivedToken)
                            NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": receivedToken])
                        }
                        if let userData = foundUserData["user"] as? NSDictionary
                        {
                            let user = User(userInfo: userData)
                            fulfill(user)
                            NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
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
    //                          func loginViaFacebook
    // -----------------------------------------------------------------------------
    /**
     Logs the user into the playolaServer via the accessToken they received from facebook.
     
     - parameters:
     - accessTokenString: `(String)` - the facebook accessTokenString
     
     - returns:
     `Promise<User>` - a promise that resolves to the current User
     
     ### Usage Example: ###
     ````
     api.loginViaGoogle(accessTokenString: "theTokenStringReceivedFromGoogle", refreshTokenString: "refreshTokenStringFromGoogle")
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
    public func loginViaGoogle(accessTokenString:String, refreshTokenString:String) -> Promise<(User)>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
            let url = "\(baseURL)/auth/google/mobile"
            
            Alamofire.request(url, method: .post, parameters: ["accessToken":accessTokenString,
                                                                "refreshToken": refreshTokenString], encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON
            {
                (response) -> Void in
            
                switch response.result
                {
                case .success:
                    if let foundUserData = response.result.value as? [String:Any]
                    {
                        if let receivedToken = foundUserData["token"] as? String
                        {
                            self.setAccessToken(tokenValue: receivedToken)
                            NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": receivedToken])
                        }
                        if let userData = foundUserData["user"] as? NSDictionary
                        {
                            let user = User(userInfo: userData)
                            fulfill(user)
                            NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
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
    //                          func loginLocal
    // -----------------------------------------------------------------------------
    /**
     Gets a session token from the playola server via the local login info.
     
     - parameters:
     - email: `(String)` - the user's email
     - password: `(String)` - the user's password
     
     - returns:
     `Promise<User>` - a promise that resolves to the current User
     
     ### Usage Example: ###
     ````
     api.loginLocal(email: "bob@bob.com", password: "bobsPassword")
     .then
     {
        (user) -> Void in
        print(user.name)
     }
     .catch
     {
        (err) -> Void in
        print(err)
     }
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: a User
     * rejects: an AuthError
     */
    public func loginLocal(email:String, password:String) -> Promise<User>
    {
        let url = "\(baseURL)/auth/local"
        let parameters:Parameters = ["email": email, "password": password]
        
        return Promise
        {
            (fulfill, reject) in
                
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON
            {
                (response) -> Void in
                switch response.result
                {
                case .success:
                    if let foundUserData = response.result.value as? [String:Any]
                    {
                        if let receivedToken = foundUserData["token"] as? String
                        {
                            self.setAccessToken(tokenValue: receivedToken)
                            NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": receivedToken])
                        }
                        if let userData = foundUserData["user"] as? NSDictionary
                        {
                            let user = User(userInfo: userData)
                            NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                            fulfill(user)
                        }
                    }
                case .failure:
                    if let data = response.data {
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        {
                            if let rejectionCode = jsonObject?["loginRejectionCode"] as? Int
                            {
                                if (rejectionCode == 1)
                                {
                                    return reject(LoginErrorType.emailNotRegistered)
                                }
                                else
                                {
                                    return reject(LoginErrorType.passwordIncorrect)
                                }
                            }
                        }
                    }
                    let authErr = AuthError(response: response)
                    reject(authErr)
                }
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func createUser
    // -----------------------------------------------------------------------------
    /**
     Gets a session token from the playola server via the local login info.  If the
     user was successfully created, the user is signed in.
     
     - parameters:
     - emailConfirmationID: `(String)` - the id of the emailConfirmation request
     - passcode: `(String)` - the passcode that was included in the user's email
     
     - returns:
     `Promise<User>` - a promise that resolves to the current User
     
     ### Usage Example: ###
     ````
     api.createUser(emailConfirmationID: "anEmailConfirmationID", passcode: "1234)
     .then
     {
        (user) -> Void in
        print(user.name)
     }
     .catch
     {
     (err) -> Void in
     print(err)
     }
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: a User
     * rejects: an AuthError
     */
    public func createUser(emailConfirmationID:String, passcode:String) -> Promise<User>
    {
        let url = "\(baseURL)/auth/local"
        let parameters:Parameters = ["emailConfirmationID": emailConfirmationID, "passcode": passcode]
        
        return Promise
        {
            (fulfill, reject) in
                
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let foundUserData = response.result.value as? [String:Any]
                        {
                            if let receivedToken = foundUserData["token"] as? String
                            {
                                self.setAccessToken(tokenValue: receivedToken)
                                NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": receivedToken])
                            }
                            if let userData = foundUserData["user"] as? NSDictionary
                            {
                                let user = User(userInfo: userData)
                                NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                                fulfill(user)
                            }
                        }
                    case .failure:
                        if let data = response.data {
                            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                            {
                                if let message = jsonObject?["message"] as? String
                                {
                                    if (message.lowercased().range(of: "passcode") != nil)
                                    {
                                        return reject(LoginErrorType.passcodeIncorrect)
                                    }
                                }
                            }
                        }
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }


    
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
    public func getMe() -> Promise<User>
    {
        let url = "\(self.baseURL)/api/v1/users/me"
        let headers:HTTPHeaders? = self.headersWithAuth()
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
                        NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                        fulfill(user)
                    case .failure:  // could add (let error) later if needed
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func reportListeningSession
    // -----------------------------------------------------------------------------
    /**
     Reports a listeningSession
     
     ### Usage Example: ###
     ````
     api.reportListeningSession(broadcasterID: "someBroadcasterID")
     .then
     {
        (responseDict) -> Void in
        print(responseDict)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Dictionary<String,Any>>` - a promise
     
     * resolves to: the raw response dictionary from the server
     * rejects: an AuthError
     */
    public func reportListeningSession(broadcasterID:String) -> Promise<Dictionary<String,Any>>
    {
        let url = "\(baseURL)/api/v1/listeningSessions"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["userBeingListenedToID":broadcasterID]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        let responseDict = response.result.value as! Dictionary<String,Any>
                        fulfill(responseDict)
                    case .failure:
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }
    
    
    // -----------------------------------------------------------------------------
    //                          func reportAnonymousListeningSession
    // -----------------------------------------------------------------------------
    /**
     Reports a listeningSession when listener is not a logged in user
     
     ### Usage Example: ###
     ````
     api.reportAnonymousListeningSession(broadcasterID: "someBroadcasterID", deviceID: "usersUniqueDeviceID")
     .then
     {
        (responseDict) -> Void in
        print(responseDict)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Dictionary<String,Any>>` - a promise
     
     * resolves to: the raw response dictionary from the server
     * rejects: an AuthError
     */
    public func reportAnonymousListeningSession(broadcasterID:String, deviceID:String) -> Promise<Dictionary<String,Any>>
    {
        let url = "\(baseURL)/api/v1/listeningSessions/anonymous"
        let headers:HTTPHeaders? = nil
        let parameters:Parameters? = [
            "userBeingListenedToID":broadcasterID,
            "deviceID":deviceID
        ]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        let responseDict = response.result.value as! Dictionary<String,Any>
                        fulfill(responseDict)
                    case .failure:
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }

    
    // -----------------------------------------------------------------------------
    //                      func reportEndOfListeningSession
    // -----------------------------------------------------------------------------
    /// tells the playolaServer that a listeningSession has ended
    ///
    /// - returns:
    ///    `Promise<Dictionary<String,AnyObject>>` - resolves to the server response
    ///                                              message body
    ///
    /// ----------------------------------------------------------------------------
    // -----------------------------------------------------------------------------
    //                          func reportEndOfListeningSession
    // -----------------------------------------------------------------------------
    /**
     Reports the end of a user's listeningSession
     
     ### Usage Example: ###
     ````
     api.reportEndOfListeningSession()
     .then
     {
        (responseDict) -> Void in
        print(responseDict)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Dictionary<String,Any>>` - a promise
     
     * resolves to: the raw response dictionary from the server
     * rejects: an AuthError
     */
    public func reportEndOfListeningSession() -> Promise<Dictionary<String,Any>>
    {
        let url = "\(baseURL)/api/v1/listeningSessions/endSession"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        let responseDict = response.result.value as! Dictionary<String,Any>
                        fulfill(responseDict)
                    case .failure:
                        let authErr = AuthError(response: response)
                        reject(authErr)
                    }
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                      func reportEndOfAnonymousListeningSession
    // -----------------------------------------------------------------------------
    /// tells the playolaServer that a listeningSession has ended
    ///
    /// - parameters:
    ///     - deviceID: `(String)` - a unique identifier for this iPhone
    /// - returns:
    ///    `Promise<Dictionary<String,AnyObject>>` - resolves to the server response
    ///                                              message body
    ///
    /// ----------------------------------------------------------------------------
    public func reportEndOfAnonymousListeningSession(deviceID:String) -> Promise<Dictionary<String,Any>>
    {
        let url = "\(baseURL)/api/v1/listeningSessions/endAnonymous"
        let headers:HTTPHeaders? = nil
        let parameters:Parameters? = ["deviceID":deviceID]
        
        return Promise
        {
            (fulfill, reject) -> Void in
                Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                    .validate(statusCode: 200..<300)
                    .responseJSON
                    {
                        (response) -> Void in
                        switch response.result
                        {
                        case .success:
                            let responseDict = response.result.value as! Dictionary<String,Any>
                            fulfill(responseDict)
                        case .failure:
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
    public func getRotationItems() -> Promise<RotationItemsCollection>
    {
        let url = "\(baseURL)/api/v1/users/me/rotationItems"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
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
    
    public func getActiveSessionsCount(broadcasterID:String) -> Promise<Int>
    {
        let url = "\(baseURL)/api/v1/listeningSessions/activeSessionsCount"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["broadcasterID" : broadcasterID]
        return Promise
        {
            (fulfill, reject) -> Void in
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
    public func getPresets(userID:String="me") -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/\(userID)/presets"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
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
    public func getTopUsers() -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/topUsers"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
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
    public func updateUser(_ updateInfo:Dictionary<String, Any>) -> Promise<User?>
    {
        let url = "\(baseURL)/api/v1/users/me"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = updateInfo
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseJSON
                {
                    (response) -> Void in
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
                                NotificationCenter.default.post(name: PlayolaEvents.currentUserUpdated, object: nil, userInfo: ["user": user])
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
    public func follow(broadcasterID:String) -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/\(broadcasterID)/follow"
        let headers:HTTPHeaders? = self.headersWithAuth()
        
        return Promise
        {
            (fulfill, reject) -> Void in
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
    public func unfollow(broadcasterID:String) -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/\(broadcasterID)/unfollow"
        let headers:HTTPHeaders? = self.headersWithAuth()
        
        return Promise
        {
            (fulfill, reject) -> Void in
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
    public func findUsersByKeywords(searchString:String) -> Promise<Array<User?>>
    {
        let url = "\(baseURL)/api/v1/users/findByKeywords"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["searchString": searchString]
        
        
        return Promise
        {
            (fulfill, reject) -> Void in
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
    //                          func findSongsByKeywords
    // -----------------------------------------------------------------------------
    /**
     Gets a list of songs matching a searchString from the server
     
     - parameters:
     - searchString: `(String)` - duh
     
     ### Usage Example: ###
     ````
     authService.findSongsByKeywords("Bob")
     .then
     {
        (searchResults) -> Void in
        for audioBlock in searchResults
        {
            print(audioBlock.title)
        }
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<AudioBlock>>` - a promise
     * resolves to: an array of the found AudioBlocks
     * rejects: an AuthError
     */
    public func findSongsByKeywords(searchString:String) -> Promise<Array<AudioBlock>>
    {
        let url = "\(baseURL)/api/v1/songs/findByKeywords"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["searchString": searchString]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, parameters:parameters, headers:headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let foundSongs = arrayOfSongsFromResultValue(resultValue: response.result.value, propertyName: "searchResults")
                        {
                            return fulfill(foundSongs)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        reject(AuthError(response: response))
                    }
                }
        }
    }

    
    // ----------------------------------------------------------------------------
    //                          func getUser
    // -----------------------------------------------------------------------------
    /**
     Takes a userID and gets the user's info from the server
     
     - parameters:
     - userID: `(String)` - duh
     
     ### Usage Example: ###
     ````
     authService.getUser(userID: users[0].id)
     .then
     {
        (updatedUser) -> Void in
        print(user.displayName)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: an up-to-date User object
     * rejects: an AuthError
     */
    public func getUser(userID:String) -> Promise<User>
    {
        let url = "\(baseURL)/api/v1/users/\(userID)"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = [:]
        
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, parameters:parameters, headers:headers)
                .validate(statusCode: 200..<300)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success:
                        if let foundUserData = response.result.value as? NSDictionary
                        {
                            let user = User(userInfo: foundUserData)
                            return fulfill(user)
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        reject(AuthError(response: response))
                    }
                }
        }
    }
    
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
    public func getUsersByAttributes(attributes:Dictionary<String,Any>) -> Promise<Array<User>>
    {
        let url = "\(baseURL)/api/v1/users/getByAttributes"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters = attributes
        
        return Promise
        {
            (fulfill, reject) -> Void in
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

    
    // -----------------------------------------------------------------------------
    //                          func addSongsToBin
    // -----------------------------------------------------------------------------
    /**
     Adds songs to the specified bin.
     
     - parameters:
     - songIDs: `(Array<String>)` - the ids of the songs to add
     - bin: `(String)` - the name of the bin to add them to
     
     ### Usage Example: ###
     ````
     authService.addSongsToBin(songIDs: ["thisIsASongID"], bin:"heavy")
     .then
     {
        (updatedRotationItemsCollection) -> Void in
        print(updatedRotationItemsCollection.listBins())
     }
        .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<RotationItemsCollection>` - a promise
     
     * resolves to: a RotationItemsCollection
     * rejects: an AuthError
     */
    public func addSongsToBin(songIDs:Array<String>, bin:String) -> Promise<RotationItemsCollection>
    {
        let url = "\(baseURL)/api/v1/rotationItems"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["songIDs":songIDs, "bin":bin]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON
            {
                (response) -> Void in
                switch response.result
                {
                case .success(let JSON):
                    if let statusCode:Int = response.response?.statusCode
                    {
                        if (200..<300 ~= statusCode)
                        {
                            if let responseDictionary:NSDictionary = JSON as? NSDictionary
                            {
                                let rawRotationItems:Dictionary<String, Array<Dictionary<String, AnyObject>>> = (responseDictionary.object(forKey: "rotationItems") as? Dictionary<String, Array<Dictionary<String, AnyObject>>>)!
                                let rotationItemsCollection:RotationItemsCollection = RotationItemsCollection(rawRotationItems: rawRotationItems)
                                return fulfill(rotationItemsCollection)
                            }
                        }
                    }
                    return reject(AuthError(response: response))
                case .failure:
                    return reject(AuthError(response: response))
                }
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func deactivateRotationItem
    // -----------------------------------------------------------------------------
    /**
     Deactivates a rotationItem
     
     - parameters:
        - rotationItemID: `(String)` - the id of the RotationItem to deactivate
     
     ### Usage Example: ###
     ````
     authService.deactivateRotationItem(rotationItemID: "thisIsASongID")
     .then
     {
        (updatedRotationItemsCollection) -> Void in
        print(updatedRotationItemsCollection.listBins())
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<RotationItemsCollection>` - a promise
     * resolves to: a RotationItemsCollection
     * rejects: an AuthError
     */
    public func deactivateRotationItem(rotationItemID:String) -> Promise<RotationItemsCollection>
    {
        let url = "\(baseURL)/api/v1/rotationItems/\(rotationItemID)"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseJSON
                {
                    (response) -> Void in
                    switch response.result
                    {
                    case .success(let JSON):
                        if let statusCode:Int = response.response?.statusCode
                        {
                            if (200..<300 ~= statusCode)
                            {
                                if let responseDictionary:NSDictionary = JSON as? NSDictionary
                                {
                                    let rawRotationItems:Dictionary<String, Array<Dictionary<String, AnyObject>>> = (responseDictionary.object(forKey: "rotationItems") as? Dictionary<String, Array<Dictionary<String, AnyObject>>>)!
                                    let rotationItemsCollection:RotationItemsCollection = RotationItemsCollection(rawRotationItems: rawRotationItems)
                                    return fulfill(rotationItemsCollection)
                                }
                            }
                        }
                        return reject(AuthError(response: response))
                    case .failure:
                        return reject(AuthError(response: response))
                    }
                }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func moveSpin
    // -----------------------------------------------------------------------------
    /**
     Moves a spin
     
      - parameters:
          - spinID: `(String)` - the id of the spin to move
          - newPlaylistPosition: `(Int)` - the desired newPlaylistPosition
     
     ### Usage Example: ###
     ````
     api.moveSpin(spinID:"thisIsASpinID", newPlaylistPosition:42)
     .then
     {
        (updatedUser) -> Void in
        print(updatedUser.program?.playlist)
     }
     .catch
     {
        (error) -> Void in
        print(error)
     }

     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: an updated user
     * rejects: an AuthError
     */
    public func moveSpin(spinID:String, newPlaylistPosition:Int) -> Promise<User>
    {
        let url = "\(baseURL)/api/v1/spins/\(spinID)/move"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["newPlaylistPosition": newPlaylistPosition]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            print("headers")
            print(headers!)
            print("parameters")
            print(parameters!)
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseJSON
                {
                    (response) -> Void in
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
                                    NotificationCenter.default.post(name: PlayolaEvents.currentUserUpdated, object: nil, userInfo: ["user": user])
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
    //                          func removeSpin
    // -----------------------------------------------------------------------------
    /**
     Removes a spin
     
     - parameters:
     - spinID: `(String)` - the id of the spin to move
     
     ### Usage Example: ###
     ````
     api.removeSpin(spinID:"thisIsASpinID")
     .then
     {
     (updatedUser) -> Void in
     print(updatedUser.program?.playlist)
     }
     .catch
     {
     (error) -> Void in
     print(error)
     }
     
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: an updated user
     * rejects: an AuthError
     */
    public func removeSpin(spinID:String) -> Promise<User>
    {
        let url = "\(baseURL)/api/v1/spins/\(spinID)"
        let headers:HTTPHeaders? = self.headersWithAuth()
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers)
                .responseJSON
                {
                    (response) -> Void in
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
                                NotificationCenter.default.post(name: PlayolaEvents.currentUserUpdated, object: nil, userInfo: ["user": user])
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
    //                          func insertSpin
    // -----------------------------------------------------------------------------
    /**
     Inserts a spin
     
     - parameters:
        - audioBlockID: `(String)` - the id of the audioBlock to insert
        - playlistPosition: `(Int)` - the desired playlistPosition
     
     ### Usage Example: ###
     ````
     api.insertSpin(audioBlockID:"thisIsASpinID", playlistPosition:42)
     .then
     {
        (updatedUser) -> Void in
        print(updatedUser.program?.playlist)
     }
     .catch
     {
        (error) -> Void in
        print(error)
     }
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: an updated user
     * rejects: an AuthError
     */
    public func insertSpin(audioBlockID:String, playlistPosition:Int) -> Promise<User>
    {
        let url = "\(baseURL)/api/v1/spins"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["audioBlockID": audioBlockID,
                                      "playlistPosition": playlistPosition]
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseJSON
                {
                    (response) -> Void in
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
                                NotificationCenter.default.post(name: PlayolaEvents.currentUserUpdated, object: nil, userInfo: ["user": user])
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

    
    // -----------------------------------------------------------------------------
    //                          func broadcastUsersUpdated
    // -----------------------------------------------------------------------------
    /**
     Broadcast when a new version of a user comes in.
     
     - parameters:
     - rotationItemID: `(String)` - the id of the RotationItem to deactivate
     
     ### Usage Example: ###
     ````
     authService.deactivateRotationItem(rotationItemID: "thisIsASongID")
     .then
     {
     (updatedRotationItemsCollection) -> Void in
     print(updatedRotationItemsCollection.listBins())
     }
     .catch (err)
     {
     print(err)
     }
     ````
     
     - returns:
     `Promise<RotationItemsCollection>` - a promise
     * resolves to: a RotationItemsCollection
     * rejects: an AuthError
     */

    fileprivate func broadcastUsersUpdated(_ users:Array<User>)
    {
        for user in users
        {
            NotificationCenter.default.post(name: PlayolaEvents.currentUserUpdated, object: nil, userInfo: ["user": user])
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
    public class func sharedInstance() -> PlayolaAPI
    {
        if (self._instance == nil)
        {
            self._instance = PlayolaAPI()
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:PlayolaAPI?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the DateHandlerService class
    ///
    /// - parameters:
    ///     - DateHandler: `(DateHandlerService)` - the new DateHandlerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ api:PlayolaAPI)
    {
        self._instance = api
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
    
fileprivate func arrayOfSongsFromResultValue(resultValue:Any?, propertyName:String) -> Array<AudioBlock>?
{
    if let resultDict = resultValue as? Dictionary<String,Any>
    {
        if let rawSongs = resultDict[propertyName] as? Array<NSDictionary>
        {
            return rawSongs.map({
                (rawSong) -> AudioBlock in
                return AudioBlock(audioBlockInfo: rawSong as! Dictionary<String,Any>)
            })
        }
    }
    return nil
}

