//
//  qwatch.c
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 22.04.2022.
//

// main unit for Apple Watch port, GFX and controls

#include "qwatch.h"
#include <sys/time.h>

const int kQWWatchChannelCount = 4; // r g b + alpha
const int kQWRedIdx = 0;
const int kQWGreenIdx = 1;
const int kQWBlueIdx = 2;

int g_QWFrameCounter;
double g_QWFrametimeAggregate;
UIImage* g_QWDeviceImage;
double g_QWLastMeasurementTimestamp;

float g_QWRotateSpeed = 0;
float g_QWForwardSpeed = 0;
float g_QWGyroRotateSpeed = 0;
float g_QWGyroForwardSpeed = 0;

CGColorSpaceRef g_QWColorSpaceRef;
unsigned char *g_QWPixels;
CGContextRef g_QWContext;
CGImageRef g_QWImageRef;

bool g_QWGyroEnabled = false;
bool g_QWModeGameplay = true;

double CACurrentMediaTime(void)
{
    struct timeval tv;
    gettimeofday(&tv,NULL);
    return tv.tv_sec + tv.tv_usec * 0.000001;
}

void QWLoadPaletteFromPPMFile(const char *path)
{
    FILE *paletteFile = fopen(path, "r");

    char buffer[QW_PALETTE_SIZE];

    // skip the header
    fgets(buffer, QW_TMP_BUFFER_SIZE, paletteFile);
    fgets(buffer, QW_TMP_BUFFER_SIZE, paletteFile);
    fgets(buffer, QW_TMP_BUFFER_SIZE, paletteFile);
    fgets(buffer, QW_TMP_BUFFER_SIZE, paletteFile);


    for (int idx = 0; idx < QW_PALETTE_SIZE; idx++)
    {
        unsigned int r, g, b;

        fgets(buffer, QW_TMP_BUFFER_SIZE, paletteFile);

        sscanf(buffer, "%d\n", &r);

        fgets(buffer, QW_TMP_BUFFER_SIZE, paletteFile);
        sscanf(buffer, "%d\n", &g);

        fgets(buffer, QW_TMP_BUFFER_SIZE, paletteFile);
        sscanf(buffer, "%d\n", &b);

        g_QWPalette[idx][kQWRedIdx] = (unsigned char)r;
        g_QWPalette[idx][kQWGreenIdx] = (unsigned char)g;
        g_QWPalette[idx][kQWBlueIdx] = (unsigned char)b;
    }

    fclose(paletteFile);
}

UIImage* QWGetDeviceImage(CGRect frame)
{
    CGFloat scale = [[WKInterfaceDevice currentDevice] screenScale];
    
    UIGraphicsBeginImageContextWithOptions(frame.size, false, scale);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

void QWBlitFramebuffer(WKInterfaceImage *uiImageContainer)
{
    // copy palette data from Quake framebuffer (vid_buffer) and convert them to RGB, then store them in watchFramebuffer and set is as current image in uiImageContainer
    //https://gist.github.com/dinosaursarecool/3734441
    
    uint width = g_QWVidScreenWidth;
    uint height = g_QWVidScreenHeight;
    
    unsigned char color[QW_PALETTE_CHANNELS];
        
    for (int y=0;y<height;++y)
    {
        for (int x=0;x<width;++x)
        {
            int frameBufferIdx = (width*y+x);
            int pixelIdx = (width*y+x)*kQWWatchChannelCount; //the index of pixel(x,y) in the 1d array pixels
                
            //now that we have our index and array we can start manipulating the pixels!

            byte paletteIdx = vid_buffer[frameBufferIdx];
            
            memcpy(color, g_QWPalette[paletteIdx], QW_PALETTE_CHANNELS * sizeof(unsigned char));
            
            color[kQWRedIdx] = color[kQWRedIdx] * ((byte) g_QWBrightnessMultiplier);
            color[kQWGreenIdx] = color[kQWGreenIdx] * ((byte) g_QWBrightnessMultiplier);
            color[kQWBlueIdx] = color[kQWBlueIdx] * ((byte) g_QWBrightnessMultiplier);
            
            memcpy(g_QWPixels + pixelIdx, color, QW_PALETTE_CHANNELS * sizeof(unsigned char));
                                        
            //Please note that this assumes an image format with alpha stored in the least significant bit.
            //See kCGImageAlphaPremultipliedLast for more info.
            //Change if needed and also update bitmapInfo provided to CGBitmapContextCreate
        }
    }
        
    g_QWImageRef = CGBitmapContextCreateImage(g_QWContext); //create a CGIMageRef from our pixeldata

    // dunno what i am doing, just trying to fix memleaks and this site tells me to use autoreleasepool https://ddcode.net/2019/04/15/uiimage-of-uiimageview-memory-release-time-under-arc/
    @autoreleasepool
    {
        //load our new image
        UIImage* newImg = [UIImage imageWithCGImage:g_QWImageRef];
        [uiImageContainer setImage:newImg];
    }
    
    CGImageRelease(g_QWImageRef);
}

void QWPrepareBlitting(CGRect frame)
{
    // our quartz2d drawing env
    g_QWDeviceImage = QWGetDeviceImage(frame);
    
    g_QWImageRef = [g_QWDeviceImage CGImage]; //get the CGImageRef from our UIImage named 'img'
    
    uint width = g_QWVidScreenWidth;
    uint height = g_QWVidScreenHeight;
    
    g_QWPixels = malloc(height*width*kQWWatchChannelCount); //1d array with size for every pixel. Each pixel has the components: Red,Green,Blue,Alpha
    g_QWColorSpaceRef = CGColorSpaceCreateDeviceRGB(); //color space info which we need to create our drawing env
    
    /*
     
     free ^ this with:
     CGColorSpaceRelease(colorSpaceRef); //release the color space info
     
     */
    
    g_QWContext = CGBitmapContextCreate(g_QWPixels, width, height, /* bits per component */8, /* bytes per row */ kQWWatchChannelCount*width, g_QWColorSpaceRef, kCGImageAlphaPremultipliedLast);
    
    /*
     
     free ^ this with:
     
     //release the drawing env and pixel data
     CGContextRelease(context);
     
     */
}

void QWInitializeGlobals()
{
    g_QWFrameCounter = 0;
    g_QWFrametimeAggregate = 0;
    g_QWLastMeasurementTimestamp = -1;
}


#undef true
#undef false
typedef enum {false, true}    qboolean;
#include "id1/cmd.h"

void QWStartGameplay(void)
{
    // load playable map
    Cmd_ExecuteString("map \"e1m1\"" , src_command /* src_client */);
}

void QWStartDemo(void)
{
    // run demo
    Cmd_ExecuteString("playdemo demo1" , src_command /* src_client */);
}

void QWInitializeIdTech()
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* resourceDir = bundle.resourcePath;
    NSString* commandLine = [[NSUserDefaults standardUserDefaults] stringForKey:@"sys_commandline0"];
    
    if (commandLine == nil)
    {
        commandLine = @"";
    }
    
    // stored in Resource subfolder
    // actual game asset package
    NSString *pakFilename = [[NSBundle mainBundle] pathForResource:@"pak0" ofType:@"pak"];
    
    // stored in Resource subfolder
    NSString *paletteFilename = [[NSBundle mainBundle] pathForResource:@"Qpalette" ofType:@"ppm"];

    QWLoadPaletteFromPPMFile([paletteFilename UTF8String]);
    
    Sys_Init([resourceDir UTF8String], [pakFilename UTF8String], [commandLine UTF8String]);
    
    QWStartGameplay();
}

void QWInitializeConfig(void)
{
    g_QWUpdateInterval = kQWRuntimeConfigs[kQWActiveConfigIdx].updateInterval;
    g_QWVidScreenWidth = kQWRuntimeConfigs[kQWActiveConfigIdx].width;
    g_QWVidScreenHeight = kQWRuntimeConfigs[kQWActiveConfigIdx].height;
}

void QWGyroMoveBackwardDirect(void)
{
    g_QWGyroForwardSpeed = -kQWMovementSpeed;
}

void QWGyroMoveForwardDirect(void)
{
    g_QWGyroForwardSpeed = kQWMovementSpeed;
}

void QWMoveBackwardDirect(void)
{
    g_QWForwardSpeed = -kQWMovementSpeed;
}

void QWMoveForwardDirect(void)
{
    g_QWForwardSpeed = kQWMovementSpeed;
}

void QWGyroTurnLeftDirect(void)
{
    g_QWGyroRotateSpeed = -kQWMovementSpeed*kQWMovementSpeedGyroMultiplier;
}

void QWGyroTurnRightDirect(void)
{
    g_QWGyroRotateSpeed = +kQWMovementSpeed*kQWMovementSpeedGyroMultiplier;
}

void QWTurnLeftDirect(void)
{
    g_QWRotateSpeed = -kQWMovementSpeed;
}

void QWTurnRightDirect(void)
{
    g_QWRotateSpeed = +kQWMovementSpeed;
}

void QWStopMovementDirect(void)
{
    g_QWRotateSpeed = g_QWForwardSpeed = 0;
}

void QWStopTranslationMovement(void)
{
    g_QWForwardSpeed = 0;
}

void QWStopGyroTranslationMovement(void)
{
    g_QWGyroForwardSpeed = 0;
}

void QWStopGyroTurning(void)
{
    g_QWGyroRotateSpeed = 0;
}

void QWStopTurning(void)
{
    g_QWRotateSpeed = 0;
}

void QWMoveForwardCommand(int repeatCount)
{
    for (int i = 0; i < repeatCount; i++)
    {
        Cmd_ExecuteString("+forward 128", src_command);
    }

    for (int i = 0; i < repeatCount; i++)
    {
        Cmd_ExecuteString("-forward 128", src_command);
    }
}

void QWLoopDownCommand(int stepCount)
{
    char buffer[1024];
    
    stepCount *= 2500;
    
    sprintf(buffer, "+lookdown %d", stepCount);
    Cmd_ExecuteString(buffer, src_command);
    
    sprintf(buffer, "-lookdown %d", stepCount);
    Cmd_ExecuteString(buffer, src_command);
}

void QWLoopUpCommand(int stepCount)
{
    char buffer[1024];
    
    stepCount *= 2500;
    
    sprintf(buffer, "+lookup %d", stepCount);
    Cmd_ExecuteString(buffer, src_command);
    
    sprintf(buffer, "-lookup %d", stepCount);
    Cmd_ExecuteString(buffer, src_command);
}

void QWTurnLeftCommand(int repeatCount)
{
    for (int i = 0; i < repeatCount; i++)
    {
        Cmd_ExecuteString("+left 130", src_command);
        Cmd_ExecuteString("-left 130", src_command);
    }
}

void QWShootCommand(void)
{
    Cmd_ExecuteString ("+attack 133", src_command);
    Cmd_ExecuteString ("-attack 133", src_command);
}

void QWUpdate(WKInterfaceImage *imageView)
{
    const float desiredFrameTime = 1.0f / 60;
    double frametimeStart = QWGetCurrentTimeMillis();

    #include "sys_watch.h"

    Sys_FrameBeforeRender();
    Sys_FrameRender();
    Sys_FrameAfterRender();

    QWBlitFramebuffer(imageView);

    double frametimeEnd = QWGetCurrentTimeMillis();

    double frametime = (frametimeEnd - frametimeStart);

    g_QWFrametimeAggregate += frametime;
    
    double frametimeEmpiricFixS = 0.001f/2.0f;

    if (frametime < desiredFrameTime)
    {
        double waitForHowLongMS = (desiredFrameTime - frametime-frametimeEmpiricFixS)*1000.0f;

        double waitStart = QWGetCurrentTimeMillis();
        
        double diff = 0;

        while ((diff = ((QWGetCurrentTimeMillis() - waitStart))*1000.0f) < waitForHowLongMS)
        {
            ;
        }
    }
}
