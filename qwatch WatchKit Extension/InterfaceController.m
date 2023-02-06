//
//  InterfaceController.m
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 15.04.2022.
//

// interface between Watchkit and Quake code for Apple Watch port

#import "InterfaceController.h"
#include "qwatch.h"
#include "qsound.h"

@implementation InterfaceController

- (void)QWRenderStats
{
    g_QWFrameCounter++;
    
    if (g_QWLastMeasurementTimestamp == -1)
    {
        g_QWLastMeasurementTimestamp = QWGetCurrentTimeMillis();
    }
    else
    {
        double now = QWGetCurrentTimeMillis();
        
        if ((now - g_QWLastMeasurementTimestamp) >= 1.0)
        {
            char fpsTextBuffer[QW_TMP_BUFFER_SIZE];
            
            double meanFrametime = ((g_QWFrametimeAggregate / g_QWFrameCounter) * 1000);
            
            sprintf(fpsTextBuffer, "Qwatch, FPS: %d, CPU: %.2fms, %dx%d", g_QWFrameCounter, meanFrametime, g_QWVidScreenWidth, g_QWVidScreenHeight);
            
            [[self fpsLabel] setText:[NSString stringWithUTF8String:fpsTextBuffer]];
            
            g_QWLastMeasurementTimestamp = now;
            
            g_QWFrameCounter = 1;
            g_QWFrametimeAggregate = 0;
        }
    }
}

- (void)QWSlowdownMovement
{
    if (g_QWForwardSpeed > 0)
    {
        g_QWForwardSpeed -= 0.01;
    }
}

- (void)QWFrameUpdate:(id)context
{
    QWUpdate([self imageView]);
    [self QWRenderStats];
       
    
    [_leftButton setHidden:g_QWGyroEnabled];
    [_rightButton setHidden:g_QWGyroEnabled];
    [_upButton setHidden:g_QWGyroEnabled];
    [_gyroLabel setHidden:!g_QWGyroEnabled];
}

- (void)QWControlPlayerMovement:(double)rotationalDelta {
    if (rotationalDelta > 0)
    {
        QWMoveForwardCommand(1);
    }
    else if (rotationalDelta < 0)
    {
        QWTurnLeftCommand(1);
    }
}

- (void)crownDidRotate:(WKCrownSequencer *)crownSequencer rotationalDelta:(double)rotationalDelta
{
    if (rotationalDelta < 0)
    {
        int step_count = (int)ceil(fabs(rotationalDelta));
        
        QWLoopUpCommand(step_count);
    }
    else if (rotationalDelta > 0)
    {
        int step_count = (int)ceil(rotationalDelta);
        
        QWLoopDownCommand(step_count);
    }
}

- (void)crownDidBecomeIdle:(nullable WKCrownSequencer *)crownSequencer
{
    QWStopMovementDirect();
}

- (IBAction)QWScreenLongPress:(id)sender
{
    g_QWGyroEnabled = !g_QWGyroEnabled;
}

- (IBAction)QWScreenDoubleTap:(id)sender
{
    WKTapGestureRecognizer* gestureRecognizer = (WKTapGestureRecognizer*)sender;
    
    CGPoint location = gestureRecognizer.locationInObject;
    
    // tap on left side
    if (location.x < gestureRecognizer.objectBounds.size.width/2)
    {
        g_QWGyroEnabled = !g_QWGyroEnabled;
        if (g_QWGyroEnabled == false)
        {
            QWStopGyroTranslationMovement();
        }
    }
    // tap on right side
    else
    {
        g_QWModeGameplay = !g_QWModeGameplay;
        
        [_chooseLevel setHidden: false];
        [_confirmLevel setHidden: false];
    }
}

- (IBAction)levelChanged:(NSInteger)idx {
    self.level = idx;
}

- (IBAction)QWLevelConfirmPressed:(id)sender
{
    [_chooseLevel setHidden: true];
    [_confirmLevel setHidden: true];
    if (self.level == 0)
    {
        QWStartDemo();
    }
    else {
        QWStartGameplay(self.level);
    }
}

- (IBAction)QWLeftLongPressAction:(id)sender
{
    WKLongPressGestureRecognizer *recognizer = (WKLongPressGestureRecognizer *)sender;
    
    if (recognizer.state == WKGestureRecognizerStateBegan)
    {
        QWTurnLeftDirect();
    }
    else if (recognizer.state == WKGestureRecognizerStateEnded)
    {
        QWStopMovementDirect();
    }
}

- (IBAction)QWRightLongPressAction:(id)sender
{
    WKLongPressGestureRecognizer *recognizer = (WKLongPressGestureRecognizer *)sender;
    
    if (recognizer.state == WKGestureRecognizerStateBegan)
    {
        QWTurnRightDirect();
    }
    else if (recognizer.state == WKGestureRecognizerStateEnded)
    {
        QWStopMovementDirect();
    }
}

- (void)willActivate
{
    [super willActivate];
    [self.crownSequencer focus];
}

- (IBAction)QWForwardLongPressAction:(id)sender
{
    WKLongPressGestureRecognizer *recognizer = (WKLongPressGestureRecognizer *)sender;
    
    if (recognizer.state == WKGestureRecognizerStateBegan)
    {
        QWMoveForwardDirect();
    }
    else if (recognizer.state == WKGestureRecognizerStateEnded)
    {
        QWStopMovementDirect();
    }
}

- (void)QWFireButtonPressed:(id)sender
{
    QWShootCommand();
}

- (void)awakeWithContext:(id)context
{
    [super awakeWithContext:context];
    
    // Configure interface objects here.
        NSMutableArray *gameLevels;
        gameLevels = [[NSMutableArray alloc] init];
        WKPickerItem *item = [[WKPickerItem alloc] init];
        item.title = @"Playdemo";
        [gameLevels addObject: item];
        item = [[WKPickerItem alloc] init];
        item.title = @"Map 1";
        [gameLevels addObject: item];
        item = [[WKPickerItem alloc] init];
        item.title = @"Map 2";
        [gameLevels addObject: item];
        item = [[WKPickerItem alloc] init];
        item.title = @"Map 3";
        [gameLevels addObject: item];
        item = [[WKPickerItem alloc] init];
        item.title = @"Map 4";
        [gameLevels addObject: item];
        item = [[WKPickerItem alloc] init];
        item.title = @"Map 5";
        [gameLevels addObject: item];
        item = [[WKPickerItem alloc] init];
        item.title = @"Map 6";
        [gameLevels addObject: item];
        item = [[WKPickerItem alloc] init];
        item.title = @"Map 7";
        [gameLevels addObject: item];
        
        [self.chooseLevel setItems:gameLevels];
    
    g_QWGyroEnabled = false;
    
    // https://stackoverflow.com/questions/50449384/how-to-implement-apple-watch-crown-delegate-using-objective-c
    // we need this to hook up the crownDid*() callbacks
    self.crownSequencer.delegate = self;
    
    self.motionManager = [CMMotionManager new];
        
    // https://stackoverflow.com/questions/3229311/cmmotionmanager-and-the-gyroscope-on-iphone-4
    self.motionManager.gyroUpdateInterval = 1.0/60.0f;
    
    self.motionManager.deviceMotionUpdateInterval = 1/10.0f;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                       withHandler: ^(CMDeviceMotion *deviceMotion, NSError *error)
                        {
                            if (!g_QWGyroEnabled)
                            {
                                return;
                            }
        
                            double pitch = deviceMotion.attitude.pitch;
                            double roll = deviceMotion.attitude.roll;
        
                            const float threshold = 0.2f;
        
                            if (pitch < threshold)
                            {
                                QWGyroMoveForwardDirect();
                            }
                            else if (pitch > (threshold + 0.4f))
                            {
                                QWGyroMoveBackwardDirect();
                            }
                            else
                            {
                                QWStopGyroTranslationMovement();
                            }
        
                            if (roll < -threshold)
                            {
                                QWGyroTurnLeftDirect();
                            }
                            else if (roll > threshold)
                            {
                                QWGyroTurnRightDirect();
                            }
                            else
                            {
                                QWStopGyroTurning();
                            }
                        }];

    QWInitializeConfig();
    QWInitializeGlobals();
    QWInitializeIdTech();
    QWPrepareBlitting([super contentFrame]);
        
    AudioInit();
    
    /*
     https://stackoverflow.com/questions/17414344/accuracy-of-nstimer
     Because of the various input sources a typical run loop manages, the effective resolution of the time interval for a timer is limited to on the order of 50-100 milliseconds. If a timer’s firing time occurs during a long callout or while the run loop is in a mode that is not monitoring the timer, the timer does not fire until the next time the run loop checks the timer. Therefore, the actual time at which the timer fires potentially can be a significant period of time after the scheduled firing time.
     */
    
    // timer which fires up update() each updateRate seconds
    [NSTimer scheduledTimerWithTimeInterval: g_QWUpdateInterval target: self selector:@selector(QWFrameUpdate:) userInfo: nil repeats:YES];
    
    StartPlayback();
}

@end



