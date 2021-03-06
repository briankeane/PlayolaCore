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
    @objc var api:PlayolaAPI! = PlayolaAPI.sharedInstance()
    @objc var currentUserInfo:PlayolaCurrentUserInfoService! = PlayolaCurrentUserInfoService.sharedInstance()
    
    var observers:[NSObjectProtocol] = Array()
    
    
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
        self.observers.append(NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.nowPlayingChanged, object: nil, queue: OperationQueue.main)
        {
            (notification) -> Void in
            if let userInfo = (notification as NSNotification).userInfo
            {
                if let broadcasterID = userInfo["broadcasterID"] as? String
                {
                    self.reportListening(broadcasterID: broadcasterID, listenerID:self.currentUserInfo.user?.id, deviceID: self.currentUserInfo.getDeviceID())
                }
            }
        })
            
        // report stopped listening
        NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.stoppedPlayingStation, object: nil, queue: OperationQueue.main)
        {
                (notification) -> Void in
                self.reportStoppedListening(listenerID: self.currentUserInfo.user?.id, deviceID: self.currentUserInfo.getDeviceID())
        }
    }
        //------------------------------------------------------------------------------
    
    func reportListening(broadcasterID:String, listenerID:String?, deviceID:String?)
    {
        if let _ = listenerID
        {
            self.api.reportListeningSession(broadcasterID: broadcasterID)
            .done
            {
                (responseDict) -> Void in
            }
            .catch
            {
                (error) -> Void in
            }
        }
        else if let deviceID = deviceID
        {
            self.api.reportAnonymousListeningSession(broadcasterID: broadcasterID, deviceID: deviceID)
            .done
            {
                (responseDict) -> Void in
            }
            .catch
            {
                (error) -> Void in
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func reportStoppedListening(listenerID:String?, deviceID:String?)
    {
        if let _ = listenerID
        {
            self.api.reportEndOfListeningSession()
            .done
            {
                (responseDict) -> Void in
                
            }
            .catch
            {
                (error) -> Void in
            }
        }
        else if let deviceID = deviceID
        {
            self.api.reportEndOfAnonymousListeningSession(deviceID: deviceID)
            .done
            {
                (responseDict) -> Void in
            }
            .catch
            {
                (error) -> Void in
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func removeObservers()
    {
        for observer in observers
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    deinit
    {
        removeObservers()
    }
}
