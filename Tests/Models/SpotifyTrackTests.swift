//
//  SpotifyTrackModelTests.swift
//  playolaIphone
//
//  Created by Brian D Keane on 5/15/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble
import SwiftyJSON

class SpotifyTrackModelQuickTests: QuickSpec
{
    override func spec()
    {
        describe("SpotifyTrack Model Tests")
        {
            var spotifyTrackInfo:JSON = []
            
            beforeEach
                {
                    spotifyTrackInfo = [
                        "album" : [
                            "album_type" : "single",
                            "artists" : [ [
                                "external_urls" : [
                                    "spotify" : "https://open.spotify.com/artist/21451j1KhjAiaYKflxBjr1"
                                ],
                                "href" : "https://api.spotify.com/v1/artists/21451j1KhjAiaYKflxBjr1",
                                "id" : "21451j1KhjAiaYKflxBjr1",
                                "name" : "Zion & Lennox",
                                "type" : "artist",
                                "uri" : "spotify:artist:21451j1KhjAiaYKflxBjr1"
                                ]
                            ],
                            "available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TR", "TW", "UY" ],
                            "external_urls" : [
                                "spotify" : "https://open.spotify.com/album/5GjKG3Y8OvSVJO55dQTFyD"
                            ],
                            "href" : "https://api.spotify.com/v1/albums/5GjKG3Y8OvSVJO55dQTFyD",
                            "id" : "5GjKG3Y8OvSVJO55dQTFyD",
                            "images" : [ [
                                "height" : 640,
                                "url" : "https://i.scdn.co/image/b16064142fcd2bd318b08aab0b93b46e87b1ebf5",
                                "width" : 640
                                ], [
                                    "height" : 300,
                                    "url" : "https://i.scdn.co/image/9f05124de35d807b78563ea2ca69550325081747",
                                    "width" : 300
                                ], [
                                    "height" : 64,
                                    "url" : "https://i.scdn.co/image/863c805b580a29c184fc447327e28af5dac9490b",
                                    "width" : 64
                                ] ],
                            "name" : "Otra Vez (feat. J Balvin)",
                            "type" : "album",
                            "uri" : "spotify:album:5GjKG3Y8OvSVJO55dQTFyD"
                        ],
                        "artists" : [ [
                            "external_urls" : [
                                "spotify" : "https://open.spotify.com/artist/21451j1KhjAiaYKflxBjr1"
                            ],
                            "href" : "https://api.spotify.com/v1/artists/21451j1KhjAiaYKflxBjr1",
                            "id" : "21451j1KhjAiaYKflxBjr1",
                            "name" : "Zion & Lennox",
                            "type" : "artist",
                            "uri" : "spotify:artist:21451j1KhjAiaYKflxBjr1"
                            ], [
                                "external_urls" : [
                                    "spotify" : "https://open.spotify.com/artist/1vyhD5VmyZ7KMfW5gqLgo5"
                                ],
                                "href" : "https://api.spotify.com/v1/artists/1vyhD5VmyZ7KMfW5gqLgo5",
                                "id" : "1vyhD5VmyZ7KMfW5gqLgo5",
                                "name" : "J Balvin",
                                "type" : "artist",
                                "uri" : "spotify:artist:1vyhD5VmyZ7KMfW5gqLgo5"
                            ] ],
                        "available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TR", "TW", "UY" ],
                        "disc_number" : 1,
                        "duration_ms" : 209453,
                        "explicit" : false,
                        "external_ids" : [
                            "isrc" : "USWL11600423"
                        ],
                        "external_urls" : [
                            "spotify" : "https://open.spotify.com/track/7pk3EpFtmsOdj8iUhjmeCM"
                        ],
                        "href" : "https://api.spotify.com/v1/tracks/7pk3EpFtmsOdj8iUhjmeCM",
                        "id" : "7pk3EpFtmsOdj8iUhjmeCM",
                        "name" : "Otra Vez (feat. J Balvin)",
                        "popularity" : 85,
                        "preview_url" : "https://p.scdn.co/mp3-preview/79c8c9edc4f1ced9dbc368f24374421ed0a33005",
                        "track_number" : 1,
                        "type" : "track",
                        "uri" : "spotify:track:7pk3EpFtmsOdj8iUhjmeCM"
                    ]
            }
            
            it ("can be initialized with a JSON object")
            {
                let spotifyTrack = SpotifyTrack(JSON: spotifyTrackInfo)
                expect(spotifyTrack.title).to(equal("Otra Vez (feat. J Balvin)"))
                expect(spotifyTrack.album).to(equal("Otra Vez (feat. J Balvin)"))
                expect(spotifyTrack.artist).to(equal("Zion & Lennox"))
                expect(spotifyTrack.duration).to(equal(209453))
                expect(spotifyTrack.isrc).to(equal("USWL11600423"))
            }
            
            it ("stores and retrieves albumArtUrl")
            {
                let spotifyTrack = SpotifyTrack(JSON: spotifyTrackInfo)
                expect(spotifyTrack.albumImageURLString()).to(equal("https://i.scdn.co/image/b16064142fcd2bd318b08aab0b93b46e87b1ebf5"))
            }
        }
    }
}
