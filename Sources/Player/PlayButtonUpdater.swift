//
//  PlayButtonUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/29/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

#if os(iOS)
//    import KDCircularProgress   // manual until he fixes cocoapod
    import UIKit
#endif

class PlayButtonUpdater:NSObject
{
    weak var playButton:AutoUpdatingButton?
    
    var stationPlayer = PlayolaStationPlayer.sharedInstance()
    
    #if os(iOS)
    var superview:UIView?
    var progressView:KDCircularProgress?
    #endif
    
    init(playButton:AutoUpdatingButton)
    {
        super.init()
        self.playButton = playButton
        self.setupListeners()
        self.setValue()
    }
    
    func setupListeners()
    {
        // Change Text or Image if play state changes
        NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.stationChanged, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.setValue()
        }
        
        NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.startedLoadingStation, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.setValue()
        }
        
       
        NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.loadingStationProgress, object: nil, queue: .main)
        {
            (notification) -> Void in
            self.setValue()
        }
        
        // React to press
        #if os(iOS)
        self.playButton?.addTarget(self, action:#selector(self.playPressed), for: .touchUpInside)
        #elseif os(OSX)
        self.playButton?.action = #selector(self.playPressed)
        #endif
        }
    
    @objc func playPressed()
    {
        if let textPlayButton = playButton as? AutoUpdatingPlayButtonWithText
        {
            if (self.stationPlayer.isPlaying() || self.stationPlayer.isLoading)
            {
                self.stationPlayer.stop()
            }
            else
            {
                if let userID = textPlayButton.userID
                {
                    self.stationPlayer.loadUserAndPlay(userID: userID)
                    .then
                    {
                        print("playing")
                    }
                    .catch
                    {
                        (error) -> Void in
                        print("error!")
                        print(error.localizedDescription)
                        
                    }
                }
            }
        }
        // ELSE it's an Image Button
        else if let imageButton = self.playButton as? AutoUpdatingPlayButtonWithImage
        {
            if (self.stationPlayer.isPlaying() || self.stationPlayer.isLoading)
            {
                self.stationPlayer.stop()
            }
            else
            {
                if let userID = imageButton.userID
                {
                    self.stationPlayer.loadUserAndPlay(userID: userID)
                    .then
                    {
                        print("playing")
                    }
                    .catch
                    {
                        (error) -> Void in
                        print("error!")
                        print(error.localizedDescription)
                    }
                }
            }
        }

    }
    
    func setValue()
    {
        if let playButton = self.playButton as? AutoUpdatingPlayButtonWithText
        {
            self.setValueWithText(buttonWithText: playButton)
        }
        else if let playButton = self.playButton as? AutoUpdatingPlayButtonWithImage
        {
            self.setValueWithImage(buttonWithImage: playButton)
        }
        
    }
    
    func setValueWithText(buttonWithText:AutoUpdatingPlayButtonWithText)
    {
        if (self.stationPlayer.isPlaying() || self.stationPlayer.isLoading)
        {
            self.setIsPlayingText()
            self.setLoadingValue()
        
        }
        else
        {
            self.setIsStoppedText()
        }
    }
    
    func setValueWithImage(buttonWithImage:AutoUpdatingPlayButtonWithImage)
    {
        if (self.stationPlayer.isLoading || self.stationPlayer.isPlaying())
        {
            self.setIsPlayingImage()
        }
        else
        {
            self.setIsStoppedImage()
        }
        self.setLoadingValue()
    }
    
    func setIsStoppedText()
    {
        if (self.playButton?.getTitle() != "Play")
        {
            DispatchQueue.main.async
            {
                self.playButton?.setTitle(title: "Play")
            }
            
        }
    }
    
    func setIsPlayingText()
    {
        DispatchQueue.main.async
        {
            self.playButton?.setTitle(title: "Stop")
        }
    }
    
    func setIsPlayingImage()
    {
        if let image = self.playButton?.getIsPlayingImage()
        {
            DispatchQueue.main.async
            {
                self.playButton?.setImage(image: image)
            }
        }
    }
    
    func setIsStoppedImage()
    {
        if let image = self.playButton?.getIsStoppedImage()
        {
            DispatchQueue.main.async
            {
                self.playButton?.setImage(image: image)
        
            }
        }
    }
    
    func setupProgressView()
    {
        #if os(iOS)
        // IF the the imageView has been created
        if (self.playButton?.imageView != nil)
        {
            if (self.progressView == nil)
            {
                if let frame = self.playButton?.imageView?.frame
                {
                    if let superview = self.playButton?.superview
                    {
                        let convertedFrame = self.playButton!.imageView!.convert(frame, to: superview)
                            
                        // add 20% to make it overlap
                        let frameWithPadding = CGRect(origin: convertedFrame.origin, size: CGSize(width: convertedFrame.width*1.25, height: convertedFrame.width*1.25))
                        self.progressView = KDCircularProgress(frame: frameWithPadding)
                        self.progressView!.center = self.playButton!.convert(self.playButton!.imageView!.center, to: superview)
                        self.progressView!.startAngle = -90
                        self.progressView!.angle = 90
                        self.progressView!.progressThickness =  0.3
                        self.progressView!.trackThickness = 0.7
                        self.progressView!.clockwise = true
                        self.progressView!.gradientRotateSpeed = 2
                        self.progressView!.roundedCorners = true
                        self.progressView!.glowMode = .forward
                        self.progressView!.backgroundColor = UIColor.clear
                        //cell.progressView!.trackColor = cell.contentView.backgroundColor!
                        self.progressView!.trackColor = UIColor.black.withAlphaComponent(0.3)
                        self.progressView!.set(colors: UIColor.white, UIColor.white, UIColor.white)
                        self.progressView!.isHidden = false
                        
                        superview.addSubview(self.progressView!)
                        self.superview = superview
                    }
                }
            }
        }
        #endif
    }
    
    func setLoadingValue()
    {
        #if os(iOS)
        if (self.stationPlayer.isLoading)
        {
            if (self.progressView == nil)
            {
                self.setupProgressView()
            }
            
            if let downloadProgress = self.stationPlayer.loadingProgress
            {
                let percentage = round(downloadProgress*100.0)
                let shouldBeHidden = (downloadProgress == 100.0)
                DispatchQueue.main.async
                {
                    print("animating to \(percentage)")
                    self.progressView?.isHidden = shouldBeHidden
                    self.progressView?.animate(toAngle: Double(percentage*3.60), duration: 0.1, completion: nil)
                    
                    // for testing
//                    self.progressView?.isHidden = false
//                    self.progressView?.animate(toAngle: Double(0.7*3.60), duration: 0.1, completion: nil)
                }
            }
         
        }
        else
        {
            DispatchQueue.main.async
            {
                self.progressView?.isHidden = true
            }
        }
        #endif
    }
}
