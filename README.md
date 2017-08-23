![MacDown logo](http://static.playola.fm/playolaLogoWithName.png)

Create, program, and listen to your own internet radio station.

## Installation

### Via Cocoapods:
```
pod install 'playolaCore', '~>0.0.5'
```

## Usage
### Player:
##### Play a user's station:
```
import PlayolaCore

function playStation() {
   let player = PlayolaStationPlayer()
   player.loadUserAndPlay(userID: "59508b2eac42570400cdb67d")
      .then { (void) -> Void in
         print("starting!")
      }.catch { (error) -> Void in
        print("there was an error starting your station.")
        print(error)
      } 
}
```
#### Other commands:
```
	player.stop()      // stops a station
```
#### Events:
Playola events are stored as static properties on the class PlayolaEvents.  Listening and responding to events is easy:

```
NotificationCenter.default.addObserver(forName: PlayolaStationPlayerEvents.loadingStationProgress, object: nil, queue: .main) {           
   (notification) -> Void in
   if let userInfo = notification.userInfo {
      if let downloadProgress = userInfo["downloadProgress"] as? Double {
         print("\(downloadProgress * 100)% complete")
      }
   }
}
```
Available events are:

```
 .startedPlayingStation
 .stoppedPlayingStation
 .startedLoadingStation
 .loadingStationProgress
 .finishedLoadingStation 
```