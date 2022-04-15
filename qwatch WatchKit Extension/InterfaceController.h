//
//  InterfaceController.h
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 15.04.2022.
//

// interface between Watchkit and Quake code for Apple Watch port

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface InterfaceController : WKInterfaceController
    @property IBOutlet WKInterfaceImage * imageView;
    @property IBOutlet WKInterfaceLabel * fpsLabel;
    @property (weak, nonatomic) IBOutlet WKInterfaceButton *upButton;
    @property (weak, nonatomic) IBOutlet WKInterfaceButton *rightButton;
    @property (weak, nonatomic) IBOutlet WKInterfaceButton *leftButton;
    @property (weak, nonatomic) IBOutlet WKInterfaceLabel *gyroLabel;

    @property CMMotionManager *motionManager;

    // sound related
    @property AVAudioEngine* audioEngine;
    @property AVAudioPlayerNode* audioPlayer;
    @property AVAudioPCMBuffer *audioBuffer;
    @property AVAudioFormat *format;
    @property AVAudioMixerNode* audioMixer;
    @property NSThread* audioThread;
@end
