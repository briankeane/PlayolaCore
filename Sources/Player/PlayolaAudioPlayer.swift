//
//  PlayolaAudioPlayer.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import AudioKit

class PlayolaAudioPlayer: NSObject
{
    var nowPlayingPapSpin:PAPSpin?
    var queueDictionary:Dictionary<String, PAPSpin> = Dictionary()
    var mixer:AKMixer!
    var playerBank:Array<(AKAudioPlayer, String?)>!
    
    //------------------------------------------------------------------------------
    // dependency injections
    //------------------------------------------------------------------------------
    var DateHandler:DateHandlerService = DateHandlerService.sharedInstance()
    
    func injectDependencies(dateHandler:DateHandlerService=DateHandlerService.sharedInstance())
    {
        self.DateHandler = dateHandler
    }
    
    //------------------------------------------------------------------------------
    
    override init()
    {
        super.init()
        
        AKSettings.playbackWhileMuted = true  // allows playback to continue after screen is locked
        self.setupPlayerBank()
    }
    
    // ----------------------------------------------------------------------------
    //                           func loadAudio
    // -----------------------------------------------------------------------------
    /**
     Loads the audio into the queue for scheduling.
     
     - parameters:
          - audioFileURL: `(URL)` - the local url of the file to play
          - startTime: `(Date)` - the time when playing should begin.  If in the past, the spin will begin at the appropriate seek point.
          - beginFadeOutTime: `(Date)` - The time when the spin should begin fading out
          - spinInfo: `(Dictionary<String,Any>)` - a dictionary to be broadcast with any notifications regarding this spin.  (Usually used to store title, artist, etc.)
     */
    func loadAudio(audioFileURL:URL, startTime: Date, beginFadeOutTime: Date, spinInfo:[String:Any])
    {
        let papSpin = PAPSpin(audioFileURL: audioFileURL, player: self.requestAvailablePlayer(key: audioFileURL.absoluteString), startTime: startTime, beginFadeOutTime: beginFadeOutTime, spinInfo: spinInfo)
        self.loadPAPSpin(papSpin)
    }
    
    // -----------------------------------------------------------------------------
    //                          func loadPAPSpin
    // -----------------------------------------------------------------------------
    /**
     loads a PAPSpin into the queue and schedules it for play.  The Audio should
     be already downloaded by the time this function is called.
     
     If the spin should already be playing, it will begin playing from the correct
     time in the middle of the song.  If the spin should start later, it will schedule
     a timer.
     
     - parameters:
        - papSpin: `(PAPSpin)` - the papSpin to load
    */
    fileprivate func loadPAPSpin(_ papSpin:PAPSpin)
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
    
    // ----------------------------------------------------------------------------
    //                           func addToQueueDictionary
    // -----------------------------------------------------------------------------
    /**
     Adds a PAPSpin to the queue dictionary.
     
     - parameters:
        - papSpin: `(PAPSpin)` - the papSpin to add to the queue
     */
    fileprivate func addToQueueDictionary(papSpin:PAPSpin)
    {
        self.queueDictionary[papSpin.audioFileURL.absoluteString] = papSpin
    }
    
    // ----------------------------------------------------------------------------
    //                           func removeFromQueueDictionary
    // -----------------------------------------------------------------------------
    /**
     Removes a PAPSpin from the queue dictionary.
     
     - parameters:
        - papSpin: `(PAPSpin)` - the papSpin to remove from the queue
     */
    fileprivate func removeFromQueueDictionary(papSpin:PAPSpin)
    {
        self.queueDictionary.removeValue(forKey: papSpin.audioFileURL.absoluteString)
    }
    
    // ----------------------------------------------------------------------------
    //                     fileprivate func setupPlayerBank
    // -----------------------------------------------------------------------------
    /**
     Instantiates a mixer (self.mixer) containing a bank of reusable AKAudioPlayers and connects them to the audio graph.
     
      - parameters:
          - numberOfPlayers: `(Int)` - the number of players to set up and connect.  Default is 10.
     */
    fileprivate func setupPlayerBank(_ numberOfPlayers:Int=10)
    {
        self.playerBank = Array()
        for _ in 0...numberOfPlayers
        {
            var player:AKAudioPlayer?
            do
            {
                let file = try AKAudioFile()
                player = try AKAudioPlayer(file: file)
            }
            catch let err
            {
                print("error creating player: \(err.localizedDescription)")
            }
            if let player = player
            {
                self.playerBank.append((player, nil))
            }
        }
        self.mixer = AKMixer(self.playerBank.map({$0.0}))
        AudioKit.output = self.mixer
        AudioKit.start()
    }
    
    // -----------------------------------------------------------------------------
    //               fileprivate func requestAvailablePlayer
    // -----------------------------------------------------------------------------
    /// grabs an available player from the playerBank and marks it as 'in use'
    ///
    /// - parameters:
    ///     - key: `(String)` - A unique identifier to associate with the player
    ///
    /// ----------------------------------------------------------------------------
    fileprivate func requestAvailablePlayer(key:String) -> AKAudioPlayer?
    {
        for (index, playerTuple) in self.playerBank.enumerated()
        {
            if (playerTuple.1 == nil)
            {
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
    /// - parameters:
    ///     - key: `(String)` - the unique identifier of the player to mark as free
    ///
    /// ----------------------------------------------------------------------------
    fileprivate func freePlayer(key:String)
    {
        for (index, playerTuple) in self.playerBank.enumerated()
        {
            if (playerTuple.1 == key)
            {
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
    fileprivate func freeAllPlayers()
    {
        for (i, _) in self.playerBank.enumerated()
        {
            self.playerBank[i].1 = nil
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func getOutputNode
    // -----------------------------------------------------------------------------
    /// returns an AudioKit audio node for output
    ///
    /// ----------------------------------------------------------------------------
    func getOutputNode() -> AKNode
    {
        return self.mixer
    }
    
    // -----------------------------------------------------------------------------
    //                          func isQueued
    // -----------------------------------------------------------------------------
    /**
     tells whether a papSpin is queued or not
    
     - parameters:
        - papSpin: `(PAPSpin)` - the PAPSpin to check for
    
     - returns:
        `BOOL` - true if papSpin is in the queue
    */
    fileprivate func isQueued(_ papSpin:PAPSpin) -> Bool
    {
        return (self.queueDictionary[papSpin.audioFileURL.absoluteString] != nil)
    }
    
    // -----------------------------------------------------------------------------
    //                          func isQueued
    // -----------------------------------------------------------------------------
    /// tells whether a localURL is queued or not.
    ///
    /// - parameters:
    ///     - papSpin: `(localURL)` - the localURL of the audioFile to check for
    ///
    /// - returns:
    ///    `BOOL` - true if the localFile has already been scheduled
    ///
    /// ----------------------------------------------------------------------------
    public func isQueued(localFileURL:URL) -> Bool
    {
        return (self.queueDictionary[localFileURL.absoluteString] != nil)
    }
    
    // -----------------------------------------------------------------------------
    //                          func clearQueue()
    // -----------------------------------------------------------------------------
    /// cleanly clears the queue of PAPSpins... invalidating all timers
    ///
    /// ----------------------------------------------------------------------------
    fileprivate func clearQueue()
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
        print("scheduleFuturePapSpin \(papSpin.audioFileURL.lastPathComponent)")
        if (!papSpin.playerSet) {
            
            if (!papSpin.startTime.isBefore(Date()))
            {
                let secsTill = papSpin.startTime.timeIntervalSinceNow
                let avTime = AKAudioPlayer.secondsToAVAudioTime(hostTime: mach_absolute_time(), time: secsTill)
                print("avTime: \(avTime)")
                papSpin.player!.stop()
                papSpin.player!.play(from: 0, to: papSpin.player!.duration, avTime: avTime)
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
                void -> Void in
                self.freePlayer(key: papSpin.audioFileURL.absoluteString)
                self.removeFromQueueDictionary(papSpin: papSpin)
            }
        }
    }
    
    // -----------------------------------------------------------------------------
    //                          func playPapSpin
    // -----------------------------------------------------------------------------
    /// starts playing a papSpin.
    ///
    /// - parameters:
    ///     - papSpin: `(PAPSpin)` - the papSpin to fadeOut and delete
    /// ----------------------------------------------------------------------------
    func playPapSpin(_ papSpin:PAPSpin)
    {
        let wasPlaying = self.isPlaying()
        
        var currentTimeInSeconds:TimeInterval = 0.0
        
        // IF it's the current spin, start it at the right position immediately
        if (papSpin.isPlaying())
        {
            // grab current time in secs from DateHandler
            let adjustedAirtime = papSpin.startTime
            
            currentTimeInSeconds = Date().timeIntervalSince(adjustedAirtime)
        }
        let beginFadeOutTimeInterval = papSpin.beginFadeOutTime.timeIntervalSince(papSpin.startTime)
        var endFadeOutTimeInterval = beginFadeOutTimeInterval.adding(3.0)
        
        if (endFadeOutTimeInterval > papSpin.player.duration)
        {
            endFadeOutTimeInterval = papSpin.player.duration
        }

        papSpin.player.play(from: currentTimeInSeconds, to: endFadeOutTimeInterval)
        
        self.nowPlayingPapSpin = papSpin
        
        // report player start if starting for the first time.
        if (!wasPlaying)
        {
            NotificationCenter.default.post(name: PAPEvents.playerStarted, object: nil, userInfo: self.nowPlayingPapSpin?.spinInfo)
        }
        
        // report new nowPlaying spin either way.
        NotificationCenter.default.post(name: PAPEvents.nowPlayingChanged, object: nil, userInfo: self.nowPlayingPapSpin?.spinInfo)
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
    fileprivate func fadePlayer(_ player: AKAudioPlayer,
                                fromVolume startVolume : Float,
                                toVolume endVolume : Float,
                                overTime time : Float,
                                completionBlock: (()->())!=nil)
    {
        // Update the volume every 1/100 of a second
        let fadeSteps : Int = Int(time) * 100
        // Work out how much time each step will take
        let timePerStep:Float = 1 / 100.0
        
        player.volume = Double(startVolume)
        
        // Schedule a number of volume changes
        for step in 0...fadeSteps
        {
            let delayInSeconds : Float = Float(step) * timePerStep
            
            let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC);
            DispatchQueue.main.asyncAfter(deadline: popTime)
            {
                let fraction:Float = (Float(step) / Float(fadeSteps))
                
                player.volume = Double(startVolume +
                    (endVolume - startVolume) * fraction)
                
                // if it was the final step, execute the completion block
                if (step == fadeSteps)
                {
                    player.stop()
                    player.volume = 1.0
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
    func stop()
    {
        let wasPlaying = self.isPlaying()
        
        self.clearQueue()
        self.freeAllPlayers()
        self.nowPlayingPapSpin = nil
        
        if (wasPlaying)
        {
            NotificationCenter.default.post(name: PAPEvents.playerStopped, object: nil, userInfo: nil)
        }
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
    func isPlaying() -> Bool
    {
        return (self.nowPlayingPapSpin != nil)
    }
}
