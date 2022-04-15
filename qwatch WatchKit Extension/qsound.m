//
//  qsynth.m
//  qsynth WatchKit Extension
//
//  Created by Tomas Vymazal on 20.06.2022.
//

// audio related code for Apple Watch port

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <pthread/pthread.h>
#include "id1/quakedef.h"
#import "qsound.h"
#import "InterfaceController.h"

extern pthread_mutex_t snd_lock;

AVAudioEngine *audioEngine = NULL;
AVAudioPlayerNode *audioPlayer = NULL;
AVAudioMixerNode *audioMixer = NULL;
AVAudioPCMBuffer *audioBuffer = NULL;
AVAudioFormat *audioFormat = NULL;

extern int snd_current_sample_pos;

void OnAudioCompletion(AVAudioPlayerNodeCompletionCallbackType callbackType);
void AudioTickWithCallback(void);
void OnDataNeeded(AVAudioPCMBuffer *buffer);
void StartPlayback(void);
void OnDataNeeded(AVAudioPCMBuffer *buffer);
void OnAudioCompletion(AVAudioPlayerNodeCompletionCallbackType callbackType);
void IncreaseSamplePos(void);

// =================================
// following methods (setparams() & highpass()) from: https://dsp.stackexchange.com/questions/73523/low-frequency-1hz-high-pass-filter
#include <math.h>
#define state_t double
#define input_t short

static state_t state = 0;
static state_t cutoff_frequency = 1.0;
state_t sampling_rate = 0;
static state_t gain = 0;


void setparams(state_t samplingRate, state_t cutoffFrequency)
{
    sampling_rate = samplingRate;
    cutoff_frequency = cutoffFrequency;
    gain = cutoff_frequency / (2 * M_PI * sampling_rate);
}

input_t highpass(input_t input) {
    input_t retval = input - state;
    state += gain * retval;
    return retval;
}

// =================================

int GetFrameBufferSizeInBytes(void)
{
    return shm->samples >> 2;
}

int GetSampleRate(void)
{
    return shm->speed;
}

void AudioInit(void)
{
    audioEngine = [[AVAudioEngine alloc] init];
    audioPlayer = [[AVAudioPlayerNode alloc] init];
    audioMixer = audioEngine.mainMixerNode;
    
    audioFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32 sampleRate:22050 channels:2 interleaved:false];
    
    audioBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFormat frameCapacity:GetFrameBufferLength()];
    audioBuffer.frameLength = GetFrameBufferLength();
    
    AVAudioFormat* audioMixerFormat = [audioMixer outputFormatForBus:0];
    
    [audioEngine attachNode:audioPlayer];
    [audioEngine connect:audioPlayer to:audioMixer format:audioMixerFormat];   // !!! format has influence on speed of playback !!!
    [audioEngine startAndReturnError:nil];
    [audioPlayer play];
    
    /*
     emulator:
     
     2022-06-28 18:35:30.378092+0200 qwatch WatchKit Extension[37454:964842] AVAudioFormat: <AVAudioFormat 0x600002f5e210:  2 ch,  44100 Hz, Float32, non-inter>
     2022-06-28 18:35:30.378233+0200 qwatch WatchKit Extension[37454:964842] audioBuffer: <AVAudioPCMBuffer@0x600000c69220: 16384/16384 bytes>
     
     device:
     
     2022-06-28 18:39:15.536624+0200 qwatch WatchKit Extension[8184:9207580] AVAudioFormat: <AVAudioFormat 0x17d4bcd0:  2 ch,  48000 Hz, Float32, non-inter>
     2022-06-28 18:39:15.538453+0200 qwatch WatchKit Extension[8184:9207580] audioBuffer: <AVAudioPCMBuffer@0x17e42490: 16384/16384 bytes>
     
     difference:
     emulator: 44100 Hz
     device: 48000 Hz
     
     emulator:
     
     Quake sound vars: sample rate=22050, framebuffer length=4096, framebuffer size in bytes=8192
    2022-08-17 16:20:28.454447+0200 qwatch WatchKit Extension[52598:1281557] AVAudioFormat: <AVAudioFormat 0x6000000f9ea0:  2 ch,  22050 Hz, Float32, non-inter>
    2022-08-17 16:20:28.454525+0200 qwatch WatchKit Extension[52598:1281557] audioBuffer: <AVAudioPCMBuffer@0x60000239db80: 16384/16384 bytes>
    2022-08-17 16:20:28.454603+0200 qwatch WatchKit Extension[52598:1281557] audioMixerFormat AVAudioFormat: <AVAudioFormat 0x6000000fa3f0:  2 ch,  44100 Hz, Float32, non-inter>
     
     
     device:
    2022-08-17 16:29:02.985481+0200 qwatch WatchKit Extension[587:403219] Quake sound vars: sample rate=22050, framebuffer length=4096, framebuffer size in bytes=8192
    2022-08-17 16:29:02.985666+0200 qwatch WatchKit Extension[587:403219] AVAudioFormat: <AVAudioFormat 0x15d502a0:  2 ch,  22050 Hz, Float32, non-inter>
    2022-08-17 16:29:02.985733+0200 qwatch WatchKit Extension[587:403219] audioBuffer: <AVAudioPCMBuffer@0x15d502f0: 16384/16384 bytes>
    2022-08-17 16:29:02.985778+0200 qwatch WatchKit Extension[587:403219] audioMixerFormat AVAudioFormat: <AVAudioFormat 0x15e460b0:  2 ch,  44100 Hz, Float32, non-inter>
     
     */
    
#if 0
    NSLog(@"Quake sound vars: sample rate=%d, framebuffer length=%d, framebuffer size in bytes=%d\n", GetSampleRate(), GetFrameBufferLength(), GetFrameBufferSizeInBytes());
    NSLog(@"AVAudioFormat: %s", [[audioFormat description] UTF8String]);
    NSLog(@"audioBuffer: %s", [[audioBuffer description] UTF8String]);
    NSLog(@"audioMixerFormat AVAudioFormat: %s", [[audioMixerFormat description] UTF8String]);    
#endif
}

void StartPlayback(void)
{
    AudioTickWithCallback();
}

void AudioTickWithCallback(void)
{
    OnDataNeeded(audioBuffer);
    
    [audioPlayer scheduleBuffer:audioBuffer atTime:nil options:AVAudioPlayerNodeBufferInterrupts completionCallbackType:AVAudioPlayerNodeCompletionDataConsumed completionHandler:^(AVAudioPlayerNodeCompletionCallbackType callbackType)
    {
        OnAudioCompletion(callbackType);
    }];
}

void OnAudioCompletion(AVAudioPlayerNodeCompletionCallbackType callbackType)
{
    AudioTickWithCallback();
}

AVAudioFrameCount GetFrameBufferLength(void)
{
    return (AVAudioFrameCount) (shm->samples >> 3);
}

void IncreaseSamplePos(void)
{
    int stepIncrement = (shm->samples >> 3);
    
    snd_current_sample_pos += stepIncrement;
    
    if(snd_current_sample_pos >= shm->samples)
    {
        snd_current_sample_pos = 0;
    }
}

void OnDataNeeded(AVAudioPCMBuffer *buffer)
{
    pthread_mutex_lock(&snd_lock);
    
    float *const *floatChannelData = buffer.floatChannelData;
        
    short * quakeAudioBuffer = (short *) (shm->buffer + (snd_current_sample_pos << 1));
    
    const float normValue = 32768;
    
    int quakeFrameBufferLength = GetFrameBufferLength();
    
    state_t cutoffFrequency = 22050.0f;
    state_t cutoffDivider = 1.75f; // this is just empirically chosen by actually hearing the sound on my Watch
    
    // setparams(state_t samplingRate, state_t cutoffFrequency)
    setparams(22050, cutoffFrequency / cutoffDivider);
        
    for (int avItemIdx = 0, quakeDataItemIdx = 0; quakeDataItemIdx < quakeFrameBufferLength; avItemIdx++, quakeDataItemIdx+=1)
    {
        // quakeAudioBuffer has 4 bytes per sample, 2 for left and 2 for right channel
        
        short sValue = quakeAudioBuffer[quakeDataItemIdx];  // idx = n => left channel, idx = n + 1 => right channel
        
        // watch speaker does not like too low frequencies which occur in some Quake samples => they can heard as "clicking", high pass should filter them
        // this can be completely skipped if running just on Mac Simulator as desktop speakers are OK :-)
        sValue = highpass(sValue);
        
        float fValue = (float) sValue;
        
        if (!isfinite(fValue) || isnan(fValue) )
        {
            fValue = 0;
        }
        
        float normFValue = (fValue / normValue);
        
        for (int avChannelNumber = 0; avChannelNumber < audioFormat.channelCount ; avChannelNumber++)
        {
            float * const fChannelBuffer = floatChannelData[avChannelNumber];
            
            fChannelBuffer[avItemIdx] = normFValue;
        }
    }
    
    // how to copy from debugger
    /*
          
     lldb
     
     (lldb) po [offlineBufferEncoded UTF8String]
     0x0000000163000000

     (lldb) po [offlineBufferEncoded length]
     1649324

     (lldb) memory read --force --binary --outfile ~/datadump2secs.bin --count 1649324 0x0000000163000000
     1649324 bytes written to '/Users/tomas/datadump2secs.bin'
     
     ===
     
     (lldb) po [offlineAudioBuffer bytes]
     0x0000000144000000

     (lldb) po [offlineAudioBuffer length]
     3702784

     (lldb) memory read --force --binary --outfile ~/datadump30secsraw.bin --count 3702784 0x0000000144000000
     3702784 bytes written to '/Users/tomas/datadump30secsraw.bin'
     
     */
    
    IncreaseSamplePos();
    
    pthread_mutex_unlock(&snd_lock);
}
