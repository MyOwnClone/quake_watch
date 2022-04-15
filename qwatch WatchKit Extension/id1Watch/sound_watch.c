//
//  sound_watch.c
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 15.04.2022.
//
// based on https://github.com/Izhido/Quake_For_OSX

#include "quakedef.h"
#include <pthread/pthread.h>

pthread_mutex_t snd_lock;

volatile int snd_current_sample_pos = 0;

void SNDDMA_Submit(void)
{

}

void SNDDMA_Shutdown(void)
{
}

int SNDDMA_GetDMAPos(void)
{
    shm->samplepos = snd_current_sample_pos;
    
    return shm->samplepos;
}

// copied over from Quake_OSX
qboolean SNDDMA_Init(void)
{
    pthread_mutex_init(&snd_lock, NULL);
    
    pthread_mutex_lock(&snd_lock);

    shm = (void *) Hunk_AllocName(sizeof(*shm), "shm");
    shm->splitbuffer = 0;
    shm->samplebits = 16;
    shm->speed = 22050;//44100;//48000;//16000;//22050;//24000;;
    shm->channels = 2;
    shm->samples = 32768;   // mono samples in buffer
    shm->samplepos = 0;
    shm->soundalive = true;
    shm->gamealive = true;
    shm->submission_chunk = (shm->samples >> 3);
    shm->buffer = Hunk_AllocName(shm->samples * (shm->samplebits >> 3) * shm->channels, "shmbuf");  // 262144 bytes
    
    pthread_mutex_unlock(&snd_lock);
    
    return true;
}
