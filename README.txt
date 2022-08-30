Quake 1 port to Apple Watch

Youtube video: https://www.youtube.com/watch?v=cPC2o262TfQ

Some features:
* uses Quake SW renderer + blitting to WatchKit surface (~60 fps, 640x480, larger res can run on lower framerate, tested up until 1024x768) 
* touch + gyro + digital crown controls
* new AVFoundation audio backend (quake to Watchkit audio buffer copy logic), as Watchkit does not support CoreAudio
* high pass audio filter to remove clicking on Watch speaker for some of the low frequency quake .wav samples
* some smaller modifications and code updates to glue Quake 1 c code to Objective C and Watchkit

made by Tomas MyOwnClone Vymazal (building on the shoulders of giants)

based on id software open source release and open source ports to Mac and iOS
see "qwatch WatchKit Extension/CREDITS.txt" for full details

following GPLv2, full source of the port is relased here

How to build:
You cannot get the build on App Store, but you can build this yourself, having a Mac and Xcode
this release does not contain any assets as they are copyrighted with non permissive licence (as opposed to the code),
but you can use download_shareware_assets.sh to download and extract pak0.pak from zip of shareware release of Quake1.

Than, you need to have Apple Watch Simulator or connected Apple Watch (via the iPhone) to your Mac and you can build the game yourself.

For know issues, see "qwatch WatchKit Extension/ISSUES.txt".
For a TODO list for a Watch port, see "qwatch WatchKit Extension/TODO.txt", but I consider most of the essential stuff to be done.

Tested on WatchKit simulator for Apple Watch Series 5 and watchOS 8.6, Xcode 13.4.1
Tested on real device - Apple Watch Series 5, watchOS 8.6, iOS 15.6