//
//  qsynth.h
//  qsynth WatchKit Extension
//
//  Created by Tomas Vymazal on 20.06.2022.
//

// audio related code for Apple Watch port

#ifndef qsound_h
#define qsound_h

#import <AVFoundation/AVFoundation.h>

AVAudioFrameCount GetFrameBufferLength(void);
void AudioInit(void);
void AudioTickWithCallback(void);
void StartPlayback(void);


#endif /* qsound_h */
