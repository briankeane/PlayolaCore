//
//  PlayButtonUpdater.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 9/29/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

#if os(iOS)
    import KDCircularProgress
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
        self.playButton?.addTarget(self, action:#selector(self.playPressed), for: .touchUpInside)
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
                }
            }
        }
        // ELSE it's an Image Button
        else
        {
            
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
        self.setIsPlayingImage()
        self.setLoadingValue()
    }
    
    func setIsStoppedText()
    {
        self.playButton?.setTitle("Play", for: .normal)
    }
    
    func setIsPlayingText()
    {
        DispatchQueue.main.async
        {
            self.playButton?.setTitle("Stop", for: .normal)
        }
    }
    
    func setIsPlayingImage()
    {
        
    }
    
    func setIsStoppedImage()
    {
        
    }
    
    func setLoadingValue()
    {
        if (self.stationPlayer.isLoading)
        {
            #if os(iOS)
            if (self.progressView == nil)
            {
                if let frame = self.playButton?.imageView?.frame
                {
                    if let superview = self.playButton?.superview
                    {
                        let convertedFrame = self.playButton!.imageView!.convert(frame, to: superview)
                        let frameWithPadding = CGRect(origin: convertedFrame.origin, size: CGSize(width: convertedFrame.width + 4.0, height: convertedFrame.height+4.0))
                        self.progressView = KDCircularProgress(frame: frameWithPadding)
                        self.progressView!.center = self.playButton!.convert(self.playButton!.imageView!.center, to: superview)
                        self.progressView!.startAngle = -90
                        self.progressView!.angle = 90
                        self.progressView!.progressThickness = 0.2
                        self.progressView!.trackThickness = 0.7
                        self.progressView!.clockwise = true
                        self.progressView!.gradientRotateSpeed = 2
                        self.progressView!.roundedCorners = true
                        self.progressView!.glowMode = .forward
                        self.progressView!.backgroundColor = UIColor.red
                        //cell.progressView!.trackColor = cell.contentView.backgroundColor!
                        self.progressView!.trackColor = UIColor.clear
                        self.progressView!.set(colors: UIColor.white, UIColor.white, UIColor.white)
                        self.progressView!.isHidden = false
                        superview.addSubview(self.progressView!)
                        superview.backgroundColor = .blue
                        
                        self.superview = superview
                    }
                }
            }
            
                
                if let downloadProgress = self.stationPlayer.loadingProgress
                {
                    let percentage = round(downloadProgress*100.0)
                    DispatchQueue.main.async
                    {
                        print("animating to \(percentage)")
                        self.progressView?.isHidden = false
                        self.progressView?.animate(toAngle: Double(percentage*3.60), duration: 0.1, completion: nil)
                    }
                }

        #endif
        }
        else
        {
            self.progressView?.removeFromSuperview()
        }
    }
}
