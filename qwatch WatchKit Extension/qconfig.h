//
//  config.h
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 20.04.2022.
//

#ifndef config_h
#define config_h

// g_QW -- global Quake Watch

extern uint g_QWVidScreenWidth;
extern uint g_QWVidScreenHeight;

extern const float kQWMovementSpeed;
extern const float kQWMovementSpeedGyroMultiplier;

extern float g_QWBrightnessMultiplier;

extern float g_QWUpdateInterval;

struct RuntimeConfig
{
    float updateInterval;
    int width;
    int height;
};

extern const struct RuntimeConfig kQWRuntimeConfigs[];
extern const int kQWActiveConfigIdx;

#define QW_TMP_BUFFER_SIZE 256
#define QW_PALETTE_SIZE 256
#define QW_PALETTE_CHANNELS 3

#endif /* config_h */
