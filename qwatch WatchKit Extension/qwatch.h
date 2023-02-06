//
//  qwatch.h
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 22.04.2022.
//

// main unit for Apple Watch port, GFX and controls

#ifndef qwatch_h
#define qwatch_h

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

#include "qcommon.h"
#include "qconfig.h"

extern int g_QWFrameCounter;
extern double g_QWFrametimeAggregate;
extern UIImage* g_QWDeviceImage;
extern double g_QWLastMeasurementTimestamp;

extern float g_QWRotateSpeed;
extern float g_QWForwardSpeed;
extern float g_QWGyroRotateSpeed;
extern float g_QWGyroForwardSpeed;

extern CGColorSpaceRef g_QWColorSpaceRef;
extern unsigned char *g_QWPixels;
extern CGContextRef g_QWContext;
extern CGImageRef g_QWImageRef;
extern byte* vid_buffer;

extern unsigned char g_QWPalette[QW_PALETTE_SIZE][QW_PALETTE_CHANNELS];

extern const int kQWWatchChannelCount; // r g b + alpha
extern const int kQWRedIdx;
extern const int kQWGreenIdx;
extern const int kQWBlueIdx;

extern bool g_QWGyroEnabled;
extern bool g_QWModeGameplay;

double CACurrentMediaTime(void);

#define QWGetCurrentTimeMillis() CACurrentMediaTime()

void QWLoadPaletteFromPPMFile(const char *path);
UIImage* QWGetDeviceImage(CGRect frame);
void QWBlitFramebuffer(WKInterfaceImage *uiImageContainer);
void QWInitializeConfig(void);
void QWInitializeGlobals(void);
void QWInitializeIdTech(void);
void QWPrepareBlitting(CGRect frame);
void QWMoveForwardDirect(void);
void QWMoveBackwardDirect(void);
void QWStopTranslationMovement(void);
void QWStopTurning(void);
void QWTurnLeftDirect(void);
void QWTurnRightDirect(void);
void QWStopMovementDirect(void);
void QWMoveForwardCommand(int repeatCount);
void QWTurnLeftCommand(int repeatCount);
void QWShootCommand(void);
void QWUpdate(WKInterfaceImage *);
void QWStopGyroTranslationMovement(void);
void QWStopGyroTurning(void);
void QWGyroTurnLeftDirect(void);
void QWGyroTurnRightDirect(void);
void QWGyroMoveBackwardDirect(void);
void QWGyroMoveForwardDirect(void);
void QWLoopDownCommand(int stepCount);
void QWLoopUpCommand(int stepCount);
void QWStartGameplay(NSInteger);
void QWStartDemo(void);

void Sys_Init(const char* resourcesDir, const char* documentsDir, const char* commandLine);

#endif /* qwatch_h */
