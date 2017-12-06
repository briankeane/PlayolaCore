//
//  SongFactoryTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 12/5/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble

class SongFactoryTests: QuickSpec
{
    override func spec()
    {
        fdescribe ("SongFactory")
        {
            var songFactory:SongFactory!
            var apiMock:PlayolaAPIMock!
            var songRequestInfos:[SongRequestInfo]!
            var dataMocker:DataMocker!
            
            func createSongFactory()
            {
                dataMocker = DataMocker()
                apiMock = PlayolaAPIMock()
                songFactory = SongFactory()
                songFactory.setValuesForKeys([
                    "api":apiMock
                    ])
                songRequestInfos = Array()
                songRequestInfos.append(SongRequestInfo(spotifyID: "song1"))
                songRequestInfos.append(SongRequestInfo(spotifyID: "song2"))
                songRequestInfos.append(SongRequestInfo(spotifyID: "song3"))
                songRequestInfos.append(SongRequestInfo(spotifyID: "song4"))
            }
            
            beforeEach
            {
                createSongFactory()
            }
            
            describe ("making and handling a single request")
            {
                it ("with status only")
                {
                    apiMock.requestSongBySpotifyIDResponses = [(songStatus: .processing, song: nil)]
                    songFactory.makeSongRequest(songRequest: songRequestInfos[0])
                    expect(songRequestInfos[0].songStatus).toEventually(equal(SongStatus.processing))
                }
                
                it ("with status and song")
                {
                    let song = dataMocker.generateSongs(1)[0]
                    apiMock.requestSongBySpotifyIDResponses = [(songStatus: .songExists, song: song)]
                    apiMock.requestSongBySpotifyIDSongStatus = SongStatus.songExists
                    songFactory.makeSongRequest(songRequest: songRequestInfos[0])
                    expect(songRequestInfos[0].songStatus).toEventually(equal(SongStatus.songExists))
                    expect(songRequestInfos[0].song?.id).toNotEventually(beNil())
                    expect(songRequestInfos[0].song?.id).toEventually(equal(song.id))
                }
            }
            
            describe ("making multiple requests")
            {
                var songs:[AudioBlock]!
                beforeEach
                {
                    songs = dataMocker.generateSongs(3)
                    apiMock.requestSongBySpotifyIDResponses = [
                        (songStatus: .processing,         song: nil),
                        (songStatus: .failedToAcquire,    song: nil),
                        (songStatus: .songExists,         song: songs[0]),
                        (songStatus: .notFound,           song: nil)
                    ]
                    songFactory.songRequests = songRequestInfos
                }
                
                it ("makes multiple requests")
                {
                    songFactory.sendAllSongRequests()
                    let allRequests:[String] = apiMock.requestSongBySpotifyIDArgs.map({$0["spotifyID"] as! String})
                    expect(apiMock.requestSongBySpotifyIDCount).toEventually(equal(4))
                    expect(allRequests).to(contain(songRequestInfos[0].spotifyID))
                    expect(allRequests).to(contain(songRequestInfos[1].spotifyID))
                    expect(allRequests).to(contain(songRequestInfos[2].spotifyID))
                    expect(allRequests).to(contain(songRequestInfos[3].spotifyID))
                }

                it ("handles multiple responses")
                {
                    songFactory.sendAllSongRequests()
                    expect(songFactory.songRequests[0].songStatus).toEventually(equal(SongStatus.processing))
                    expect(songFactory.songRequests[0].song).to(beNil())
                    
                    expect(songFactory.songRequests[1].songStatus).toEventually(equal(SongStatus.failedToAcquire))
                    expect(songFactory.songRequests[1].song).to(beNil())
                    
                    expect(songFactory.songRequests[2].songStatus).toEventually(equal(SongStatus.songExists))
                    expect(songFactory.songRequests[2].song).toNot(beNil())
                    expect(songFactory.songRequests[2].song?.id).to(equal(songs[0].id))
                    
                    expect(songFactory.songRequests[3].songStatus).toEventually(equal(SongStatus.notFound))
                    expect(songFactory.songRequests[3].song?.id).to(beNil())
                }
                
                describe ("on progress, on completion")
                {
                    beforeEach
                    {
                        // set all to compelete
                        apiMock.requestSongBySpotifyIDResponses = [
                            (songStatus: .failedToAcquire, song: nil),
                            (songStatus: .failedToAcquire, song: nil),
                            (songStatus: .failedToAcquire, song: nil),
                            (songStatus: .failedToAcquire, song: nil)
                        ]
                    }
                    it ("properly calls onProgress blocks")
                    {
                        var progressCallCount:Int = 0
                        songFactory
                        .onProgress(
                        {
                            (songFactory) in
                            progressCallCount += 1
                        })
                        songFactory.sendAllSongRequests()
                        expect(progressCallCount).toEventually(equal(4))
                    }
                    
                    it ("properly calls onCompletion blocks")
                    {
                        var completionCallCount:Int = 0
                        songFactory
                        .onCompletion(
                        {
                            (songFactory) in
                            completionCallCount += 1
                        })
                        songFactory.sendAllSongRequests()
                        expect(completionCallCount).toEventually(equal(1))
                        expect(completionCallCount).toEventuallyNot(equal(2))
                    }
                }
            }
        }
    }
    
}
