//
//  config.c
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 20.04.2022.
//

// general config for Apple Watch port

#include "qcommon.h"
#include "qconfig.h"

const float kQWLowestPossibleTimeInterval = 1e-3;  //seconds

const float kQWMovementSpeed = 0.6;

const float kQWMovementSpeedGyroMultiplier = 0.25;

const struct RuntimeConfig kQWRuntimeConfigs[] = {
    /* refresh interval,          xres, yres */
    {kQWLowestPossibleTimeInterval,  320, 240}, // 0
    {kQWLowestPossibleTimeInterval,  640, 480},
    {kQWLowestPossibleTimeInterval,  800, 600},
    {kQWLowestPossibleTimeInterval, 1024, 768},
    {kQWLowestPossibleTimeInterval, 1280, 800}
};

const int kQWActiveConfigIdx = 1;

// actual values are assigned as runtimeConfigs[ACTIVE_CONFIG_IDX]
float g_QWUpdateInterval;  // in seconds
uint g_QWVidScreenWidth;
uint g_QWVidScreenHeight;

float g_QWBrightnessMultiplier = 1.5;
