# Swift Remote File Cache Manager

This package is used for managing a cache of remotely downloaded files.  When the folder reaches it's max size, the RemoteFileCacheManager makes room by deleting the "lowest priority" files, first.

My use-case is to locally store a cache of audio files.  I keep or delete files based on the likelihood that the user will play them.

## Installation via Cocoapods

Add this to the appropriate target in your Podfile
```
    pod 'SwiftRemoteFileCacheManager'
```
## Usage




License
----

MIT