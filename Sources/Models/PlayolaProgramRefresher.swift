//
//  PlayolaProgramRefresher.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/26/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

public class PlayolaProgramRefresher:NSObject
{
    var user:User!
    var refreshTimer:Timer?
    var refreshInterval:TimeInterval = 45.0  // default 45 secs between updates
    
    init(user:User)
    {
        self.user = user
        super.init()
        self.restartTimer()
        
        self.setupListeners()
        
        // ensure that RefreshHandler has been instantiated
        let _ = PlayolaModelRefreshHandler.sharedInstance()
    }
    
    func setupListeners()
    {
        NotificationCenter.default.addObserver(forName: PlayolaEvents.userUpdated, object: nil, queue: .main)
        {
            (notification) -> Void in
            if let userInfo = notification.userInfo
            {
                if let updatedUser = userInfo["user"] as? User
                {
                    if let updatedUserID = updatedUser.id
                    {
                        if let myID = self.user.id
                        {
                            if (updatedUserID == myID)
                            {
                                self.updateProgram(updatedUser: updatedUser)
                                self.restartTimer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------
    
    func restartTimer()
    {
        self.refreshTimer?.invalidate()
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: self.refreshInterval, repeats: false)
        {
            (timer) -> Void in
            self.requestUpdate()
            self.restartTimer()
        }
    }
    
    func updateProgram(updatedUser:User)
    {
        self.user.replaceProgram(updatedUser.program)
    }
    
    func requestUpdate()
    {
        if let id = self.user.id
        {
           NotificationCenter.default.post(name: PlayolaEvents.userUpdateRequested, object: nil, userInfo: ["userID": id])
        }
    }
    
}
