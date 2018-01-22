//
//  AudioPlayerService.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import Foundation

open class PlayolaAVAudioPlayer: NSObject, PlayolaAudioPlayer
{
    var isPlayingFlag:Bool = false
    var identifier:String!
    
    var delegate:PlayerDelegate?
    
    var nowPlayingPapSpin:PAPSpin?
    var queueDictionary:Dictionary<String, PAPSpin> = Dictionary()
    var playerBank:[(Player, String?)]!
    
    public init(identifier:String, delegate:PlayerDelegate?=nil)
    {
        super.init()
        self.identifier = identifier
        self.delegate = delegate
        self.setupPlayerBank()
    }
    
    open func loadAudio(audioFileURL:URL, startTime: Date, beginFadeOutTime: Date, spinInfo:[String:Any])
    {
        let papSpin = PAPSpin(audioFileURL: audioFileURL, player: self.requestAvailablePlayer(key: audioFileURL.absoluteString), startTime: startTime, beginFadeOutTime: beginFadeOutTime, spinInfo: spinInfo)
        self.loadPAPSpin(papSpin)
    }
    
    open func addToQueueDictionary(papSpin:PAPSpin)
    {
        self.queueDictionary[papSpin.audioFileURL.absoluteString] = papSpin
    }
    
    open func removeFromQueueDictionary(papSpin:PAPSpin)
    {
        self.queueDictionary.removeValue(forKey: papSpin.audioFileURL.absoluteString)
    }
    
    // -----------------------------------------------------------------------------
    //                      private func setupPlayerBank
    // -----------------------------------------------------------------------------
    /// loads a bank of audioPlayers and gets them ready to play spins
    ///
    /// ----------------------------------------------------------------------------
    private func setupPlayerBank()
    {
        self.playerBank = Array()
        for _ in 0...10
        {
            self.playerBank.append((Player(delegate: self.delegate),nil))
        }
    }
    
    // -----------------------------------------------------------------------------
    //                     func requestAvailablePlayer
    // -----------------------------------------------------------------------------
    /// grabs an available player from the playerBank and marks it as 'in use'
    ///
    /// ----------------------------------------------------------------------------
    open func requestAvailablePlayer(key:String) -> Player?
    {
        for (index, playerTuple) in self.playerBank.enumerated()
        {
            if (playerTuple.1 == nil)
            {
                puts("getting player: \(index)")
                self.playerBank[index].1 = key
                return playerTuple.0
            }
        }
        return nil
    }
    
    // -----------------------------------------------------------------------------
    //                    private func freePlayer
    // -----------------------------------------------------------------------------
    /// marks a player as free
    ///
    /// ----------------------------------------------------------------------------
    func freePlayer(key:String)
    {
        for (index, playerTuple) in self.playerBank.enumerated()
        {
            if (playerTuple.1 == key)
            {
                puts("freeing \(index)")
                self.playerBank[index].0.stop()
                self.playerBank[index].1 = nil
                return
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                    private func freeAllPlayers
    // -----------------------------------------------------------------------------
    /// marks all players as free
    ///
    /// ----------------------------------------------------------------------------
    func freeAllPlayers()
    {
        for (i, _) in self.playerBank.enumerated()
        {
            self.playerBank[i].1 = nil
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func loadPAPSpin
    // -----------------------------------------------------------------------------
    /// loads a PAPSpin into the queue and schedules it for play.  The Audio should
    /// be already downloaded and ready to go by the time this function is called.
    /// If the song should already be playing, it will seek to the proper spot and
    /// begin playback immediately.
    ///
    /// ----------------------------------------------------------------------------
    open func loadPAPSpin(_ papSpin:PAPSpin)
    {
        if (!self.isQueued(papSpin))
        {
            // IF it should be playing now, go ahead and start it
            if (papSpin.isPlaying())
            {
                self.playPapSpin(papSpin)
                self.addToQueueDictionary(papSpin: papSpin)
            }
            else
            {
                self.addToQueueDictionary(papSpin: papSpin)
            }
            self.refreshQueueTimers()
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func isQueued
    // -----------------------------------------------------------------------------
    /// tells whether a papSpin is queued or not
    ///
    /// - parameters:
    ///     - papSpin: `(PAPSpin)` - the PAPSpin to check for
    ///
    /// - returns:
    ///    `BOOL` - true if papSpin is in the queue
    ///
    /// ----------------------------------------------------------------------------
    func isQueued(_ papSpin:PAPSpin) -> Bool
    {
        return (self.queueDictionary[papSpin.audioFileURL.absoluteString] != nil)
    }
    
    open func isQueued(localFileURL: URL) -> Bool
    {
        return (self.queueDictionary[localFileURL.absoluteString] != nil)
    }
    
    
    // -----------------------------------------------------------------------------
    //                          func clearQueue()
    // -----------------------------------------------------------------------------
    /// cleanly clears the queue of PAPSpins... invalidating all timers
    ///
    /// ----------------------------------------------------------------------------
    func clearQueue()
    {
        for (key,papSpin) in self.queueDictionary
        {
            papSpin.player?.stop()
            papSpin.fadeOutTimer?.invalidate()
            self.queueDictionary.removeValue(forKey: key)
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func refreshQueueTimers()
    // -----------------------------------------------------------------------------
    /// refreshes all existing timers and creates new ones if needed
    ///
    /// ----------------------------------------------------------------------------
    func refreshQueueTimers()
    {
        for (_, papSpin) in self.queueDictionary
        {
            self.scheduleFuturePapSpin(papSpin)
            self.setPapSpinFadeOutTimer(papSpin)
        }
    }
    
    // -----------------------------------------------------------------------------
    //                private func scheduleFuturePapSpin
    // -----------------------------------------------------------------------------
    /// schedules or refreshes a future papSpin
    ///
    /// - parameters:
    ///     - papSpin: `(PAPSpin)` - the PAPSpin to be scheduled
    ///
    /// ----------------------------------------------------------------------------
    fileprivate func scheduleFuturePapSpin(_ papSpin:PAPSpin)
    {
        if (!papSpin.playerSet) {
            
            if (!papSpin.startTime.isBefore(Date()))
            {
                papSpin.player.schedulePlay(at: papSpin.startTime)
                papSpin.playerSet = true
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                private func setPapSpinFadeOutTimer
    // -----------------------------------------------------------------------------
    /// schedules or refreshes the papSpin's fadeOutTimer
    ///
    /// - parameters:
    ///     - papSpin: `(PAPSpin)` - the PAPSpin to be scheduled
    ///
    /// ----------------------------------------------------------------------------
    fileprivate func setPapSpinFadeOutTimer(_ papSpin:PAPSpin)
    {
        papSpin.fadeOutTimer?.invalidate()
        
        papSpin.fadeOutTimer = Timer(timeInterval: papSpin.beginFadeOutTime.timeIntervalSinceNow, target: self, selector: #selector(self.handleFadeOutTimerFired(_:)), userInfo: ["papSpin":papSpin as AnyObject] , repeats: false)
        RunLoop.main.add(papSpin.fadeOutTimer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    // -----------------------------------------------------------------------------
    //                @objc func handleFadeOutTimerFired
    // -----------------------------------------------------------------------------
    /// @objc function called by the fadeOutTimer.  Extracts the papSpin from the
    /// timer's userInfo object and passes it along to fadeOutPapSpin()
    ///
    /// - parameters:
    ///     - timer: `(NSTimer)` - the fadeOutTimer that fired
    ///
    /// ----------------------------------------------------------------------------
    @objc func handleFadeOutTimerFired(_ timer:Timer)
    {
        let userInfo = timer.userInfo as! NSDictionary
        if let papSpin = userInfo["papSpin"] as? PAPSpin
        {
            self.fadeOutPapSpin(papSpin)
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func fadeOutPapSpin
    // -----------------------------------------------------------------------------
    /// gradually fades out a papSpin... removing it from the queue after it's
    /// faded out.
    ///
    /// - parameters:
    ///     - papSpin: `(PAPSpin)` - the papSpin to fadeOut and delete
    /// ----------------------------------------------------------------------------
    func fadeOutPapSpin(_ papSpin:PAPSpin)
    {
        if let player = papSpin.player
        {
            self.fadePlayer(player, fromVolume: 1.0, toVolume: 0, overTime: 3.0)
            {
                self.freePlayer(key: papSpin.audioFileURL.absoluteString)
                self.removeFromQueueDictionary(papSpin: papSpin)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func playPapSpin
    // -----------------------------------------------------------------------------
    /// starts a papSpin
    ///
    /// - parameters:
    ///     - papSpin: `(PAPSpin)` - the papSpin to fadeOut and delete
    /// ----------------------------------------------------------------------------
    func playPapSpin(_ papSpin:PAPSpin)
    {
        let currentTimeInSeconds = Date().timeIntervalSince(papSpin.startTime)
        papSpin.player.play(from: currentTimeInSeconds, to: nil)
        
        self.nowPlayingPapSpin = papSpin
        
        // report player start if starting for the first time.
        if (!self.isPlayingFlag)
        {
            self.isPlayingFlag = true
            // -------- Post Notification (started playing) ------------
        }
        
        // -------------- Post Notification (nowPlaying changed) -------------
    }
    
    // -----------------------------------------------------------------------------
    //                    private func fadePlayer
    // -----------------------------------------------------------------------------
    /// schedules a gradual fade of an AKAudioPlayer
    /// -- adapted from https://www.safaribooksonline.com/library/view/ios-swift-game/9781491920794/ch04.html
    //
    /// - parameters:
    ///     - player: `(AKAudioPlayer)` - the player to fade
    ///     - fromVolume/startVolume: `(Float)` - the starting volume
    ///     - toVolume/endVolume: `(Float)` - the ending volume
    ///     - overTime/time: `(Float)` - number of seconds to spread the fade over
    ///     - completionBlock: `(()->())` - code to execute upon completion (optional)
    ///
    /// ----------------------------------------------------------------------------
    fileprivate func fadePlayer(_ player: PAPSpinPlayer,
                                fromVolume startVolume : Float,
                                toVolume endVolume : Float,
                                overTime time : Float,
                                completionBlock: (()->())!=nil)
    {
        // Update the volume every 1/100 of a second
        let fadeSteps : Int = Int(time) * 100
        // Work out how much time each step will take
        let timePerStep:Float = 1 / 100.0
        
        player.setVolume(startVolume)
        
        // Schedule a number of volume changes
        for step in 0...fadeSteps
        {
            let delayInSeconds : Float = Float(step) * timePerStep
            
            let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
            
            DispatchQueue.main.asyncAfter(deadline: popTime)
            {
                let fraction:Float = (Float(step) / Float(fadeSteps))
                
                player.setVolume(startVolume +
                    (endVolume - startVolume) * fraction)
                
                // if it was the final step, execute the completion block
                if (step == fadeSteps)
                {
                    //                    player.stop()
                    player.setVolume(1.0)
                    completionBlock?()
                }
                
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func stop
    // -----------------------------------------------------------------------------
    /// cleanly stop the player and post kAudioPlayerStopped notification
    ///
    /// ----------------------------------------------------------------------------
    open func stop()
    {
        self.clearQueue()
        self.freeAllPlayers()
        self.isPlayingFlag = false
        //        NotificationCenter.default.post(name: kPAPStopped, object: nil, userInfo: ["playerIdentifier":self.identifier,
        //                                                                                   "player":self])
    }
    
    // -----------------------------------------------------------------------------
    //                          func isPlaying
    // -----------------------------------------------------------------------------
    /// tells whether the station is currently playing... returns false if loading
    ///
    /// - returns:
    ///    `Bool` - true if the station is playing
    ///
    /// ----------------------------------------------------------------------------
    open func isPlaying() -> Bool
    {
        return self.isPlayingFlag
    }
    
    // -----------------------------------------------------------------------------
    //                      class func sharedInstance()
    // -----------------------------------------------------------------------------
    /// provides a Singleton of the AdminSharedData for all to use
    ///
    /// - returns:
    ///    `DateHandlerClass` - the central SharedData instance
    ///
    /// ----------------------------------------------------------------------------
    open class func sharedInstance() -> PlayolaAVAudioPlayer
    {
        if (self._instance == nil)
        {
            self._instance = PlayolaAVAudioPlayer(identifier: "playolaSharedPAPPlayer")
        }
        return self._instance!
    }
    
    /// internally shared singleton instance
    fileprivate static var _instance:PlayolaAVAudioPlayer?
    
    // -----------------------------------------------------------------------------
    //                          func replaceSharedInstance
    // -----------------------------------------------------------------------------
    /// replaces the Singleton shared instance of the AdminSharedData class
    ///
    /// - parameters:
    ///     - voiceTrackPreviewPlayer: `(VoiceTrackPreviewPlayerService)` - the new
    //                                    VoiceTrackPreviewPlayerService
    ///
    /// ----------------------------------------------------------------------------
    class func replaceSharedInstance(_ playolaAVAudioPlayer:PlayolaAVAudioPlayer)
    {
        self._instance = playolaAVAudioPlayer
    }
}
