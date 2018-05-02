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

@objc open class PlayolaAPI:NSObject
{
    // temporary
    var baseURL:String {
        get {
            if let _baseURL = _baseURL {
                return _baseURL
            }
            return PlayolaConstants.BASE_URL
        }
        set {
            _baseURL = newValue
        }
    }
    var _baseURL:String?
    
    var accessToken:String?
    
    let defaults:UserDefaults = UserDefaults.standard
    var observers:[NSObjectProtocol] = Array()
    
    let userCache:UserCache = UserCache.sharedInstance()
    
    private var _signInPending:Bool = false
    
    var operationQueue:OperationQueue = OperationQueue() {
        didSet {
            operationQueue.qualityOfService = .background
            operationQueue.maxConcurrentOperationCount = 2
        }
    }
    
    var userInitiatedOperationQueue:OperationQueue = OperationQueue() {
        didSet {
            userInitiatedOperationQueue.qualityOfService = .userInitiated
        }
    }
    
    open func signInPending() -> Bool
    {
        return self._signInPending
    }
    
    /// use to set your own development Playola server or to
    open func setBaseURL(baseURL:String)
    {
        self.baseURL = baseURL
    }
    
    open func isSignedIn() -> Bool
    {
        return self.accessToken != nil
    }
    
    open func signOut()
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
            NotificationCenter.default.post(name: PlayolaEvents.signInBegan, object: nil)
            self._signInPending = true
            // trigger update of current user
            self.getMe()
            .then
            {
                (user) -> Void in
                self._signInPending = false
            }
            .catch
            {
                (error) -> Void in
                self._signInPending = false
                self.signOut()
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
    
    private func performAPIOperations(apiCallOp:APIRequestOperation, parsingOp:ParsingOperation, priority:Operation.QueuePriority = .normal, queue:OperationQueue? = nil) -> Promise<Void>
    {
        return Promise
        {
            (fulfill, reject) -> Void in
            let dataPasser = BlockOperation()
            {
                [unowned parsingOp, unowned apiCallOp] in
                parsingOp.response = apiCallOp.response
            }
            dataPasser.addDependency(apiCallOp)
            parsingOp.addDependency(dataPasser)
            parsingOp.completionBlock =
            {
                return fulfill(())
            }
            
            apiCallOp.queuePriority = priority
            dataPasser.queuePriority = priority
            parsingOp.queuePriority = priority
            
            if let queue = queue
            {
                queue.addOperations([apiCallOp, dataPasser, parsingOp], waitUntilFinished: false)
            }
            else
            {
                self.operationQueue.addOperations([apiCallOp, dataPasser, parsingOp], waitUntilFinished: false)
            }
        }
    }
    
    deinit
    {
        self.removeObservers()
        self.operationQueue.cancelAllOperations()
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
     * rejects: an APIError
     */
    
    open func loginViaFacebook(accessTokenString:String, priority:Operation.QueuePriority = .normal) -> Promise<User>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/auth/facebook/mobile"
        let parameters:Parameters = ["accessToken":accessTokenString]
        let headers:HTTPHeaders? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSignInResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let token = parsingOp.token
                {
                    self.setAccessToken(tokenValue: token)
                    NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": token])
                }
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func loginViaGoogle
    // -----------------------------------------------------------------------------
    /**
     Logs the user into the playolaServer via the accessToken they received from google.
     
     - parameters:
     - accessTokenString: `(String)` - the google accessTokenString
     - refreshTokenString:`(String)` - the google refreshTokenString
     
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
     * rejects: an APIError
     */
    open func loginViaGoogle(accessTokenString:String, refreshTokenString:String) -> Promise<(User)>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/auth/google/mobile"
        let parameters:Parameters = [ "accessToken": accessTokenString,
                                     "refreshToken": refreshTokenString ]
        let headers:HTTPHeaders? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSignInResponseOperation()
        
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp)
            .then
            {
                () -> Void in
                if let token = parsingOp.token
                {
                    self.setAccessToken(tokenValue: token)
                    NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": token])
                }
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
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
     * rejects: an APIError
     */
    open func loginLocal(email:String, password:String, priority:Operation.QueuePriority = .normal) -> Promise<User>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/auth/local"
        let parameters:Parameters = ["email": email, "password": password]
        let headers:HTTPHeaders? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSignInResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let token = parsingOp.token
                {
                    self.setAccessToken(tokenValue: token)
                    NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": token])
                }
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func requestSongBySpotifyID
    // -----------------------------------------------------------------------------
    /**
     Gets a session token from the playola server via the local login info.
     
     - parameters:
     - spotifyID: `(String)` - the spotifyID of the desired song
     
     - returns:
     `Promise<User>` - a promise that resolves to the current User
     
     ### Usage Example: ###
     ````
     api.requestSongBySpotifyID(spotifyID: "aSpotifyID")
     .then
     {
        (result) -> Void in
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
     * rejects: an APIError
     */
    open func requestSongBySpotifyID(spotifyID:String, priority:Operation.QueuePriority = .normal) -> Promise<(songStatus:SongStatus, song:AudioBlock?)>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/songs/requestViaSpotifyID/\(spotifyID)"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseRequestSongBySpotifyIDOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill((songStatus: parsingOp.songStatus!, song: parsingOp.song))
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func createVoiceTrack
    // -----------------------------------------------------------------------------
    /**
     Creates a voiceTrack from the audio file located at the specified url.
     
     - parameters:
     - url: `(String)` - the url of the audioFile to import
     
     - returns:
     `Promise<(voiceTrackStatus:VoiceTrackStatus, voiceTrack: AudioBlock?)>` - a promise that resolves to
      a tuple comtaining the voiceTrackStatus and the resulting voiceTrack if successful.
     
     ### Usage Example: ###
     ````
     api.createVoiceTrack(url: "https://www.briankeane.com/myVoiceTrack.m4a")
     .then
     {
        (result) -> Void in
        print(result.voiceTrackStatus)
        print(result.voiceTrack)
     }
     .catch
     {
        (err) -> Void in
        print(err)
     }
     ````
     
     - returns:
     `Promise<(voiceTrackStatus:VoiceTrackStatus, voiceTrack:AudioBlock?)>` - a promise
     * that resolves to: a User
     * rejects: an APIError
     */
    open func createVoiceTrack(voiceTrackURL:String, priority:Operation.QueuePriority = .normal) -> Promise<(voiceTrackStatus:VoiceTrackStatus, voiceTrack:AudioBlock?)>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/voiceTracks/"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = [ "url": voiceTrackURL ]
        
        return Promise
        {
            (fulfill, reject) in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseCreateVoiceTrackOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill((voiceTrackStatus: parsingOp.voiceTrackStatus!, voiceTrack: parsingOp.voiceTrack))
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
     * rejects: an APIError
     */
    open func createUser(emailConfirmationID:String, passcode:String, priority:Operation.QueuePriority = .veryHigh) -> Promise<User>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/users"
        let parameters:Parameters = ["emailConfirmationID": emailConfirmationID, "passcode": passcode]
        let headers:HTTPHeaders? = nil
        
        return Promise
        {
            (fulfill, reject) in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSignInResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if let token = parsingOp.token
                {
                    self.setAccessToken(tokenValue: token)
                    NotificationCenter.default.post(name: PlayolaEvents.accessTokenReceived, object: nil, userInfo: ["accessToken": token])
                }
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func createEmailConfirmation
    // -----------------------------------------------------------------------------
    /**
     Creates an emailConfirmation on the server and requests that a confirmation email
     be sent to the user containing a passcode.
     
     - parameters:
     - email: `(String)` - the email for the new user
     - displayName: `(String)` - the desired displayName for the new user
     - password: `(String)` - the desired password for the new user
     
     - returns:
     `Promise<String>` - a promise that resolves to the emailConfirmationID. This should be stored in order to call createUser later on when it works.
     
     ### Usage Example: ###
     ````
     api.createEmailConfirmation(email:"bob@bob.com", displayName: "Bob", password:"BobsSuperSecretPassword")
     .then
     {
        (emailConfirmationID) -> Void in
        print(emailConfirmationID)
     }
     .catch
     {
        (err) -> Void in
        print(err)
     }
     ````
     
     - returns:
     `Promise<User>` - a promise
     * resolves to: an emailConfirmationID
     * rejects: an APIError
     */
    open func createEmailConfirmation(email:String, displayName:String, password:String) -> Promise<String>
    {
        let url = "\(baseURL)/api/v1/emailConfirmations"
        let parameters:Parameters = ["email": email, "displayName": displayName, "password": password]
        
        return Promise
        {
            (fulfill, reject) in
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .responseJSON
                {
                    (response) -> Void in
                    if let statusCode = response.response?.statusCode
                    {
                        if (200..<300 ~= statusCode)
                        {
                            if let foundUserData = response.result.value as? [String:Any]
                            {
                                if let emailConfirmationID = foundUserData["id"] as? String
                                {
                                    return fulfill(emailConfirmationID)
                                }
                            }
                        }
                    }
                    return reject(APIError(response: response))
                }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func requestPasswordReset
    // -----------------------------------------------------------------------------
    /// requests a password reset -- a reset password link will be sent to the user's
    /// email.
    ///
    /// - parameters:
    ///     - email: `(String)` - the future user's email
    ///     - password: `(String)` - the desired password
    ///     - displayName: `(String)` - the desired displayName
    ///
    /// - returns:
    ///    `Promise<Dictionary<String,String>>` - resolves to a Dictionary with the
    ///                                           server response body
    ///
    /// ----------------------------------------------------------------------------
    open func requestPasswordReset() -> Promise<Void>
    {
        let url = "\(baseURL)/api/v1/users/me/changePassword"
        let headers:HTTPHeaders? = ["Authorization": "Bearer \(self.accessToken)"]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .put, encoding: JSONEncoding.default, headers: headers)
            .responseJSON
            {
                (response) -> Void in
                switch response.result
                {
                case .success(let JSON):
                    let responseData = JSON as! NSDictionary
                    if let statusCode:Int = response.response?.statusCode
                    {
                        if (200..<300 ~= statusCode)
                        {
                            return fulfill(())
                        }
                    }
                case .failure(let error):
                    return reject(APIError(response: response))
                }
                return reject(APIError(response: response))
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
            * rejects: an APIError
     */
    open func getMe(priority:Operation.QueuePriority = .normal) -> Promise<User>
    {
        return self.getUser(userID: "me", priority: priority)
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
     * rejects: an APIError
     */
    open func reportListeningSession(broadcasterID:String, priority:Operation.QueuePriority = .low) -> Promise<[String:Any]>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/listeningSessions"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["userBeingListenedToID":broadcasterID]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseResponseAsDictionary()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.responseDict!)
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
     * rejects: an APIError
     */
    open func reportAnonymousListeningSession(broadcasterID:String, deviceID:String) -> Promise<Dictionary<String,Any>>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/listeningSessions/anonymous"
        let headers:HTTPHeaders? = nil
        let parameters:Parameters? = [
            "userBeingListenedToID":broadcasterID,
            "deviceID":deviceID
        ]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseResponseAsDictionary()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.responseDict!)
            }
        }
    }

    
    //  -----------------------------------------------------------------------------
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
     * rejects: an APIError
     */
    open func reportEndOfListeningSession(priority:Operation.QueuePriority = .low) -> Promise<[String:Any]>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/listeningSessions/endSession"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseResponseAsDictionary()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.responseDict!)
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
    open func reportEndOfAnonymousListeningSession(deviceID:String, priority:Operation.QueuePriority = .low) -> Promise<[String:Any]>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/listeningSessions/endAnonymous"
        let headers:HTTPHeaders? = nil
        let parameters:Parameters? = ["deviceID":deviceID]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseResponseAsDictionary()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.responseDict!)
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
            * rejects: an APIError
     */
    open func getRotationItems(priority:Operation.QueuePriority = .normal) -> Promise<RotationItemsCollection>
    {
        let method:HTTPMethod = .get
        let url = "\(baseURL)/api/v1/users/me/rotationItems"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseRotationItemsCollection()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.rotationItemsCollection!)
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
     * rejects: an APIError
     */
    
    open func getActiveSessionsCount(broadcasterID:String, priority:Operation.QueuePriority = .normal) -> Promise<Int>
    {
        let method:HTTPMethod = .get
        let url = "\(baseURL)/api/v1/listeningSessions/activeSessionsCount"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["broadcasterID" : broadcasterID]
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseCountOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.count!)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func getPresets
    // -----------------------------------------------------------------------------
    /**
     Gets a user's favorites.  If no userID is provided it gets the current user's
     favorites.
     
     - parameters:
     - userID: `(String?)` - OPTIONAL - the owner of the desired favorites.
     
     ### Usage Example: ###
     ````
     authService.getPresets()
     .then
     {
        (favorites) -> Void in
        for user in favorites
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
     `Promise<[User]>` - a promise
     * resolves to: an array of Users
     * rejects: an APIError
     */
    open func getPresets(userID:String="me", priority:Operation.QueuePriority = .normal) -> Promise<[User]>
    {
        let method:HTTPMethod = .get
        let url = "\(baseURL)/api/v1/users/\(userID)/presets"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseMultipleUsersResponseOperation(key: "presets")
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if var users = parsingOp.users
                {
                    users = self.userCache.refresh(users: users)
                    if (userID == "me")
                    {
                         NotificationCenter.default.post(name: PlayolaEvents.currentUserPresetsReceived, object: nil, userInfo: ["favorites": users])
                    }
                    return fulfill(users)
                }
                return reject(parsingOp.apiError!)
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
     * rejects: an APIError
     */
    open func getTopStations(priority:Operation.QueuePriority = .normal) -> Promise<[User]>
    {
        let method:HTTPMethod = .get
        let url = "\(baseURL)/api/v1/users/topUsers"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseMultipleUsersResponseOperation(key: "topUsers")
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if var users = parsingOp.users
                {
                    users = self.userCache.refresh(users: users)
                    return fulfill(users)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func updateUser
    // -----------------------------------------------------------------------------
    /**
     Updates the current user's info on the playola server.
     
     - parameters:
        - updateInfo: `([String,Any])` - a dictionary of the properties to update
     
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
     * rejects: an APIError
     */
    open func updateUser(_ updateInfo:[String:Any], priority:Operation.QueuePriority = .normal) -> Promise<User>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/users/me"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = updateInfo
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSingleUserResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func registerSpotifyCredentials
    // -----------------------------------------------------------------------------
    /**
     Updates the user's spotify info.
     
     /// - parameters:
     ///     - refreshToken: `(String)` - the spotify refreshToken
     ///     - accessToken: `(String)` - the spotify accessToken
     
     
     ### Usage Example: ###
     ````
     api.registerSpotifyCredentials(refreshToken: "myRefreshToken",
                                    accessToken: "myAccessToken")
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
     `Promise<>` - a promise
     * resolves to: Void
     * rejects: an APIError
     */
    open func registerSpotifyCredentials(refreshToken:String, accessToken:String, priority:Operation.QueuePriority = .normal) -> Promise<Void>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/users/me/spotifyCredentials"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["accessToken": accessToken,
                                      "refreshToken": refreshToken]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseEmpty()
                
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var error = parsingOp.apiError
                {
                    return reject(parsingOp.apiError!)
                }
                return fulfill(())
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func removeRotationItemsAndReset
    // -----------------------------------------------------------------------------
    /**
     Removes the specified rotationItems from rotation and resets the rotationItemsCollection
     
     /// - parameters:
     ///     - rotationItemIDs: `([String])` - an array of the ids of the rotationItems to be removed
     
     ### Usage Example: ###
     ````
     api.removeRotationItemsAndReset(rotationItemIDs: ["firstRotationItemID", "secondRotationItemID"])
     .then
     {
        (rotationItemsCollection) -> Void in
        print("rotationItemsCollection updated")
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<RotationItemsCollection>` - a promise that resolves to a rotationItemsCollection
     * resolves to: RotationItemsCollection
     * rejects: an APIError
     */
    open func removeRotationItemsAndReset(rotationItemIDs:[String], priority:Operation.QueuePriority = .normal) -> Promise<RotationItemsCollection>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/rotationItems/removeAndReset"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["rotationItemIDs": rotationItemIDs]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseRotationItemsCollection()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.rotationItemsCollection!)
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func changePassword
    // -----------------------------------------------------------------------------
    /**
     Updates the current user's info on the playola server.
     
     /// - parameters:
     ///     - oldPassword: `(String)` - duh
     ///     = newPassword: `(String)` - also duh
     
     ### Usage Example: ###
     ````
     authService.changePassword(oldPassword: "bobsOldPassword", newPassword: "bobsNewPassword")
     .then
     {
        (()) -> Void in
        print("password updated")
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Void>` - a promise
     */
    open func changePassword(oldPassword:String, newPassword:String) -> Promise<Void>
    {
        let url = "\(baseURL)/api/v1/users/me/changePassword"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters = ["newPassword": newPassword, "oldPassword": oldPassword]
    
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON
            {
                (response) -> Void in
                if let statusCode = response.response?.statusCode
                {
                    if (200..<300 ~= statusCode)
                    {
                        fulfill(())
                    }
                }
                return reject(APIError(response: response))
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
        self.favorites = updatedPresets
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: the updated favorites array
     * rejects: an APIError
     */
    open func follow(broadcasterID:String, priority:Operation.QueuePriority = .normal) -> Promise<[User]>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/users/\(broadcasterID)/follow"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseMultipleUsersResponseOperation(key: "presets")
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var users = parsingOp.users
                {
                    users = self.userCache.refresh(users: users)
                    NotificationCenter.default.post(name: PlayolaEvents.currentUserPresetsReceived, object: nil, userInfo: ["favorites": users])
                    return fulfill(users)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func unfollow
    // -----------------------------------------------------------------------------
    /**
     Removes a user from the currentUser's favorites
     
     - parameters:
     - broadcasterID: `(String)` - the id of the user to follow
     
     ### Usage Example: ###
     ````
     authService.unfollow(["thisIsAUserID")
     .then
     {
        (updatedPresets) -> Void in
        self.favorites = updatedPresets
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<Array<User>>` - a promise
     * resolves to: the updated favorites array
     * rejects: an APIError
     */
    open func unfollow(broadcasterID:String, priority:Operation.QueuePriority = .normal) -> Promise<[User]>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/users/\(broadcasterID)/unfollow"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseMultipleUsersResponseOperation(key: "presets")
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var users = parsingOp.users
                {
                    users = self.userCache.refresh(users: users)
                    NotificationCenter.default.post(name: PlayolaEvents.currentUserPresetsReceived, object: nil, userInfo: ["favorites": users])
                    return fulfill(users)
                }
                return reject(parsingOp.apiError!)
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
     `Promise<[User]>` - a promise
     * resolves to: the updated favorites array
     * rejects: an APIError
     */
        open func findUsersByKeywords(searchString:String, priority:Operation.QueuePriority = .normal) -> Promise<[User]>
    {
        let method:HTTPMethod = .get
        let url = "\(baseURL)/api/v1/users/findByKeywords"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["searchString": searchString]
        
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseMultipleUsersResponseOperation(key: "searchResults")
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var users = parsingOp.users
                {
                    users = self.userCache.refresh(users: users)
                    return fulfill(users)
                }
                return reject(parsingOp.apiError!)
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
     * rejects: an APIError
     */
    open func findSongsByKeywords(searchString:String) -> Promise<[AudioBlock]>
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
                    if let statusCode = response.response?.statusCode
                    {
                        if (200..<300 ~= statusCode)
                        {
                            if let foundSongs = arrayOfSongsFromResultValue(resultValue: response.result.value, propertyName: "searchResults")
                            {
                                return fulfill(foundSongs)
                            }
                        }
                    }
                    return reject(APIError(response: response))
                }
        }
    }

    
    // ----------------------------------------------------------------------------
    //                          func getUser()
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
     * rejects: an APIError
     */
    open func getUser(userID:String, priority:Operation.QueuePriority = .normal) -> Promise<User>
    {
        let method:HTTPMethod = .get
        let url = "\(baseURL)/api/v1/users/\(userID)"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = [:]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSingleUserResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    
                    if (userID == "me")
                    {
                        NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    }
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
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
     * resolves to: the updated favorites array
     * rejects: an APIError
     */
    open func getUsersByAttributes(attributes:[String:Any], priority:Operation.QueuePriority = .normal) -> Promise<[User]>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/users/getByAttributes"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = attributes
        
        return Promise
        {
            (fulfill, reject) -> Void in
            
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseMultipleUsersResponseOperation(key: "searchResults")
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var users = parsingOp.users
                {
                    users = self.userCache.refresh(users: users)
                    return fulfill(users)
                }
                return reject(parsingOp.apiError!)
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
     * rejects: an APIError
     */
    open func addSongsToBin(songIDs:[String], bin:String, priority:Operation.QueuePriority = .normal) -> Promise<RotationItemsCollection>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/rotationItems"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["songIDs":songIDs, "bin": bin]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseRotationItemsCollection()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.rotationItemsCollection!)
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
     * rejects: an APIError
     */
    open func deactivateRotationItem(rotationItemID:String, priority:Operation.QueuePriority = .normal) -> Promise<RotationItemsCollection>
    {
        let method:HTTPMethod = .delete
        let url = "\(baseURL)/api/v1/rotationItems/\(rotationItemID)"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseRotationItemsCollection()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.rotationItemsCollection!)
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
     * rejects: an APIError
     */
    open func moveSpin(spinID:String, newPlaylistPosition:Int) -> Promise<User>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/spins/\(spinID)/move"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["newPlaylistPosition": newPlaylistPosition]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSingleUserResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: .veryHigh, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                            return fulfill(user)
                }
                return reject(parsingOp.apiError!)
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
     * rejects: an APIError
     */
    open func removeSpin(spinID:String) -> Promise<User>
    {
        let method:HTTPMethod = .delete
        let url = "\(baseURL)/api/v1/spins/\(spinID)"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSingleUserResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: .veryHigh, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // ----------------------------------------------------------------------------
    //                          func shuffleStation
    // -----------------------------------------------------------------------------
    /**
     Shuffles your station
     
     ### Usage Example: ###
     ````
     api.shuffleStation()
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
     * rejects: an APIError
     */
    open func shuffleStation() -> Promise<User>
    {
        let url = "\(baseURL)/api/v1/spins/shuffle"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseJSON
                {
                    (response) -> Void in
                    if let statusCode = response.response?.statusCode
                    {
                        if (200..<300 ~= statusCode)
                        {
                            if let responseData = response.result.value as? [String:Any]
                            {
                                let rawUser:[String:AnyObject] = (responseData["user"] as? [String:AnyObject])!
                                var user:User = User(userInfo: rawUser as NSDictionary)
                                if let oldUser = self.userCache.getUser(userID: user.id)
                                {
                                    if let oldProgram = oldUser.program
                                    {
                                        if let newProgram = user.program
                                        {
                                            if let firstDifferentSpin = newProgram.firstDifferentSpin(compareTo: oldProgram)
                                            {

                                                NotificationCenter.default.post(name: PlayolaEvents.playlistShuffled, object: nil, userInfo: ["firstDifferentSpin": firstDifferentSpin])
                                                
                                            }
                                        }
                                    }
                                }
                                user = self.userCache.refresh(user: user)
                                NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                                return fulfill(user)
                            }
                        }
                    }
                    return reject(APIError(response: response))
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
     * rejects: an APIError
     */
    open func insertSpin(audioBlockID:String, playlistPosition:Int) -> Promise<User>
    {
        let method:HTTPMethod = .post
        let url = "\(baseURL)/api/v1/spins"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = ["audioBlockID": audioBlockID,
                                      "playlistPosition": playlistPosition]
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSingleUserResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: .veryHigh, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func resetRotationItems
    // -----------------------------------------------------------------------------
    /**
     Completely resets the rotationItems for the current user.
     
     - parameters:
        - items: `[(songID:String, bin:String)]` - an array of tuples containing the
                playola songID and desired bin for each.

     NOTE:
     The bin minumums must be met!
     
     ### Usage Example: ###
     ````
     authService.addSongsToBin(items: ([(songID: "playolaSongID1", bin: "heavy"),
                                        (songID: "playolaSongID2", bin: "medium"),
                                        (songID: "playolaSongID3", bin: "light")
                                      ])
     .then
     {
        (user, updatedRotationItemsCollection) -> Void in
        print(updatedRotationItemsCollection.listBins())
        print(user.displayName!)
     }
     .catch (err)
     {
        print(err)
     }
     ````
     
     - returns:
     `Promise<RotationItemsCollection>` - a promise
     
     * resolves to: a tuple containing the updated user and rotationItemsCollection
     * rejects: an APIError
     */
    open func resetRotationItems(items:[(songID:String, bin:String)], priority:Operation.QueuePriority = .normal)    -> Promise<RotationItemsCollection>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/rotationItems/reset"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let itemsDict = items.map { (tuple) -> [String:String] in
            return ["songID": tuple.songID, "bin": tuple.bin]
        }
        let parameters:Parameters? = ["items": itemsDict]
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseRotationItemsCollection()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: priority)
            .then
            {
                () -> Void in
                if let err = parsingOp.apiError
                {
                    return reject(err)
                }
                return fulfill(parsingOp.rotationItemsCollection!)
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
     * rejects: an APIError
     */
    open func startStation() -> Promise<User>
    {
        let method:HTTPMethod = .put
        let url = "\(baseURL)/api/v1/users/me/startStation"
        let headers:HTTPHeaders? = self.headersWithAuth()
        let parameters:Parameters? = nil
        
        return Promise
        {
            (fulfill, reject) -> Void in
            let apiCallOp = APIRequestOperation(urlString: url, method: method, headers: headers, parameters: parameters)
            let parsingOp = ParseSingleUserResponseOperation()
            
            self.performAPIOperations(apiCallOp: apiCallOp, parsingOp: parsingOp, priority: .veryHigh, queue: self.userInitiatedOperationQueue)
            .then
            {
                () -> Void in
                if var user = parsingOp.user
                {
                    user = self.userCache.refresh(user: user)
                    NotificationCenter.default.post(name: PlayolaEvents.getCurrentUserReceived, object: nil, userInfo: ["user": user])
                    return fulfill(user)
                }
                return reject(parsingOp.apiError!)
            }
        }
    }

    
    // -----------------------------------------------------------------------------
    //                          func broadcastUsersUpdated
    // -----------------------------------------------------------------------------
    /**
     Broadcast when a new version of a user comes in.
     
     - parameters:
        - users: `[User]` - an array of the new users updated
     
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
    /// provides a Singleton of the PlayolaAPI for all to use
    ///
    /// - returns:
    ///    `PlayolaAPI` - the central PlayolaAPI Service instance
    ///
    /// ----------------------------------------------------------------------------
    open class func sharedInstance() -> PlayolaAPI
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
                let user = User(userInfo: rawUser as NSDictionary)
                return user
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

