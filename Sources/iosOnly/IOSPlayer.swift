////
//  Player.swift
//  Waveform
//
//  Created by Syed Haris Ali on 12/28/17.
//  Copyright © 2017 Ausome Apps LLC. All rights reserved.
//

import Foundation
import AVFoundation
import os.log

/// High level audio player class
public class Player: PAPSpinPlayer
{
    public var duration: Double = 0
    
    // dependencies
    @objc var playolaMainMixer:PlayolaMainMixer = PlayolaMainMixer.sharedInstance()
    
    /// Namespaced logger
    private static let logger = OSLog(subsystem: "com.ausomeapps", category: "Player")
    
    /// An internal instance of AVAudioEngine
    private let engine:AVAudioEngine! = PlayolaMainMixer.sharedInstance().engine!
    
    /// The node responsible for playing the audio file
    private let playerNode = AVAudioPlayerNode()
    
    /// The currently playing audio file
    private var currentFile: AVAudioFile? {
        didSet {
            if let file = currentFile {
                loadFile(file)
            }
        }
    }
    
    /// A delegate to receive events from the Player
    weak public var delegate: PlayerDelegate?
    
    /// A Bool indicating whether the engine is playing or not
    public var isPlaying: Bool {
        return playerNode.isPlaying
    }
    
    public var volume:Float {
        get {
            return playerNode.volume
        }
        set {
            playerNode.volume = newValue
        }
    }
    
    /// Singleton instance of the player
    static let shared = Player()
    
    // MARK: Lifecycle
    
    
    
    init(delegate:PlayerDelegate?=nil)
    {
        do
        {
            let session = AVAudioSession()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [
                .allowBluetoothA2DP,
                .defaultToSpeaker
                ])
        }
        catch
        {
            os_log("Error setting up session: %@", log: Player.logger, type: .default, #function, #line, error.localizedDescription)
        }

        
        self.delegate = delegate
        /// Make connections
        engine.attach(playerNode)
        engine.connect(playerNode, to: self.playolaMainMixer.mixerNode, format: TapProperties.default.format)
        engine.prepare()
        
        /// Install tap
        playerNode.installTap(onBus: 0, bufferSize: TapProperties.default.bufferSize, format: TapProperties.default.format, block: onTap(_:_:))
    }
    
    // MARK: Playback
    
    /// Begins playback (starts engine and player node)
    func play() {
        os_log("%@ - %d", log: Player.logger, type: .default, #function, #line)
        
        guard !isPlaying, let _ = currentFile else {
            return
        }
        
        do {
            try engine.start()
            playerNode.play()
            delegate?.player(self, didChangePlaybackState: true)
        } catch {
            os_log("Error starting engine: %@", log: Player.logger, type: .default, #function, #line, error.localizedDescription)
        }
    }
    
    public func stop()
    {
        if !engine.isRunning
        {
            do {
                try engine.start()
            } catch {
                os_log("Error starting engine while stopping: %@", log: Player.logger, type: .default, #function, #line, error.localizedDescription)
                return
            }
        }
        self.playerNode.stop()
        self.playerNode.reset()
        //        self.currentFile = nil
    }
    
    /// play a segment of a song immediately
    public func play(from: Double, to: Double?=nil)
    {
        do
        {
            try engine.start()
            
            // calculate segment info
            let sampleRate = playerNode.outputFormat(forBus: 0).sampleRate
            let newSampleTime = AVAudioFramePosition(sampleRate * from)
            let framesToPlay = AVAudioFrameCount(Float(sampleRate) * Float(self.duration))
            
            // stop the player, schedule the segment, restart the player
            playerNode.stop()
            playerNode.scheduleSegment(self.currentFile!, startingFrame: newSampleTime, frameCount: framesToPlay, at: nil, completionHandler: nil)
            playerNode.play()
            
            // tell the delegate
            delegate?.player(self, didChangePlaybackState: true)
        }
        catch
        {
            os_log("Error starting engine: %@", log: Player.logger, type: .default, #function, #line, error.localizedDescription)
        }
    }
    
    private func avAudioTimeFromDate(date:Date) -> AVAudioTime
    {
        let outputFormat = self.playerNode.outputFormat(forBus: 0)
        let now = playerNode.lastRenderTime!.sampleTime
        let secsUntilDate = date.timeIntervalSinceNow
        return AVAudioTime(sampleTime: (now + Int64(secsUntilDate * outputFormat.sampleRate)), atRate: outputFormat.sampleRate)
    }
    
    /// schedule a future play from the beginning of the file
    public func schedulePlay(at: Date) {
        do {
            try engine.start()
            let avAudiotime = self.avAudioTimeFromDate(date: at)
            playerNode.play(at: avAudiotime)
            delegate?.player(self, didChangePlaybackState: true)
        } catch {
            os_log("Error starting engine: %@", log: Player.logger, type: .default, #function, #line, error.localizedDescription)
        }
    }
    
    
    /// Pauses playback (pauses the engine and player node)
    func pause() {
        os_log("%@ - %d", log: Player.logger, type: .default, #function, #line)
        
        guard isPlaying, let _ = currentFile else {
            return
        }
        
        playerNode.pause()
        //        engine.pause()
        delegate?.player(self, didChangePlaybackState: false)
    }
    
    // MARK: File Loading
    
    /// Loads an AVAudioFile into the current player node
    private func loadFile(_ file: AVAudioFile) {
        os_log("%@ - %d", log: Player.logger, type: .default, #function, #line)
        // store duration
        
        self.storeDuration(file: file)
        
        
        playerNode.scheduleFile(file, at: nil)
    }
    
    
    public func setVolume(_ level: Float)
    {
        self.playerNode.volume = level
    }
    
    /// Loads an audio file at the provided URL into the player node
    public func loadFile(with url: URL) {
        os_log("%@ - %d", log: Player.logger, type: .default, #function, #line)
        
        do {
            currentFile = try AVAudioFile(forReading: url)
        } catch {
            os_log("Error loading (%@): %@", log: Player.logger, type: .error, #function, #line, url.absoluteString, error.localizedDescription)
        }
    }
    
    fileprivate func storeDuration(file:AVAudioFile)
    {
        let audioNodeFileLength = AVAudioFrameCount(file.length)
        self.duration = Double(Double(audioNodeFileLength) / 44100)
    }
    
    // MARK: Tap
    
    /// Handles the audio tap
    private func onTap(_ buffer: AVAudioPCMBuffer, _ time: AVAudioTime) {
        guard let file = currentFile,
            let nodeTime = playerNode.lastRenderTime,
            let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else {
                return
        }
        
        let currentTime = TimeInterval(playerTime.sampleTime) / playerTime.sampleRate
        delegate?.player(self, didPlayFile: file, atTime: currentTime, withBuffer: buffer)
    }
}
