//
//  PlayolaListeningSessionReporter.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/31/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

class PlayolaListeningSessionReporter:NSObject
{
    // dependency injections
    var api:PlayolaAPI! = PlayolaAPI()
    var currentUserInfo:PlayolaCurrentUserInfoService! = PlayolaCurrentUserInfoService.sharedInstance()
    
    func injectDependencies(api:PlayolaAPI=PlayolaAPI(), currentUserInfo:PlayolaCurrentUserInfoService=PlayolaCurrentUserInfoService.sharedInstance())
    {
        self.api = api
        self.currentUserInfo = currentUserInfo
    }
    
    //------------------------------------------------------------------------------
        
    override init()
    {
        super.init()
        self.setupListeners()
    }
        
    //------------------------------------------------------------------------------
        
    func setupListeners()
    {
        // update media information if nowplaying advances
        NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, queue: OperationQueue.main)
        {
            (notification) -> Void in
            if let userInfo = (notification as NSNotification).userInfo
            {
                if let broadcasterID = userInfo["broadcasterID"] as? String
                {
                    self.reportListening(broadcasterID: broadcasterID, listenerID:self.currentUserInfo.user?.id, deviceID: self.currentUserInfo.getDeviceID())
                }
            }
        }
//            
//        // report stopped listening
//        NotificationCenter.default.addObserver(forName: kPAPStopped, object: nil, queue: OperationQueue.main)
//        {
//                (notification) -> Void in
//                if let userInfo = (notification as NSNotification).userInfo
//                {
//                    if let player = userInfo["player"] as? StationAudioPlayer
//                    {
//                        if (player.identifier == kStationAudioPlayerIdentifier)
//                        {
//                            if (self.authService.accessToken != "")
//                            {
//                                self.authService.reportEndOfListeningSession()
//                            }
//                            else
//                            {
//                                if let deviceID = UIDevice.current.identifierForVendor?.uuidString
//                                {
//                                    self.authService.reportEndOfAnonymousListeningSession(deviceID)
//                                }
//                            }
//                            
//                        }
//                    }
//                }
//            }
//        }
        
        //------------------------------------------------------------------------------
    }
    
    func reportListening(broadcasterID:String, listenerID:String?, deviceID:String?)
    {
        if let listenerID = listenerID
        {
            self.api.reportListeningSession(broadcasterID: broadcasterID)
        }
        else if let deviceID = deviceID
        {
            self.api.reportAnonymousListeningSession(broadcasterID: broadcasterID, deviceID: deviceID)
        }
    }
    
    func reportStartedListening()
    {
        
    }
}
