//
//  vid_osx.c
//  Quake_OSX
//
//  Created by Heriberto Delgado on 1/30/16.
//
//
// based on https://github.com/Izhido/Quake_For_OSX

#include "quakedef.h"
#include "d_local.h"
#include "../qconfig.h"

byte* vid_buffer = NULL;
short* zbuffer = NULL;
byte* surfcache = NULL;


unsigned char g_QWPalette[256][3] = {};

unsigned short d_8to16table[256];
unsigned* d_8to24table;

void VID_SetSize(int width, int height)
{
    D_FlushCaches();
    
    if (surfcache != NULL)
    {
        free(surfcache);
    }
    
    if (zbuffer != NULL)
    {
        free(zbuffer);
    }
    
    if (vid_buffer != NULL)
    {
        free(vid_buffer);
    }
    
    g_QWVidScreenWidth = width;
    
    if (g_QWVidScreenWidth < 320)
    {
        g_QWVidScreenWidth = 320;
    }
    
    if (g_QWVidScreenWidth > 1280)
    {
        g_QWVidScreenWidth = 1280;
    }

    g_QWVidScreenHeight = height;
    
    if (g_QWVidScreenHeight < 200)
    {
        g_QWVidScreenHeight = 200;
    }
    
    if (g_QWVidScreenHeight > 960)
    {
        g_QWVidScreenHeight = 960;
    }
    
    if (g_QWVidScreenHeight > g_QWVidScreenWidth)
    {
        g_QWVidScreenHeight = g_QWVidScreenWidth;
    }
    
    vid_buffer = malloc(g_QWVidScreenWidth * g_QWVidScreenHeight * sizeof(byte));

    zbuffer = malloc(g_QWVidScreenWidth * g_QWVidScreenHeight * sizeof(short));

    vid.width = vid.conwidth = g_QWVidScreenWidth;
    vid.height = vid.conheight = g_QWVidScreenHeight;
    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0f / 240.0f);

    vid.buffer = vid.conbuffer = vid_buffer;
    vid.rowbytes = vid.conrowbytes = g_QWVidScreenWidth;
    
    d_pzbuffer = zbuffer;
    
    int surfcachesize = D_SurfaceCacheForRes(g_QWVidScreenWidth, g_QWVidScreenHeight);
    
    surfcache = malloc(surfcachesize);
    
    D_InitCaches (surfcache, surfcachesize);

    vid.recalc_refdef = 1;
}

void    VID_SetPalette (unsigned char *palette)
{
    byte    *pal;
    unsigned r,g,b;
    unsigned v;
    unsigned short i;
    unsigned    *table;
    
    //
    // 8 8 8 encoding
    //
    pal = palette;
    table = d_8to24table;
    for (i=0 ; i<256 ; i++)
    {
        r = pal[0];
        g = pal[1];
        b = pal[2];
        pal += 3;
        
        v = (255 << 24) | (b << 16) | (g << 8) | r;
        *table++ = v;
    }
    d_8to24table[255] &= 0xFFFFFF;    // 255 is transparent
}

void    VID_ShiftPalette (unsigned char *palette)
{
    VID_SetPalette(palette);
}

void    VID_Init (unsigned char *palette)
{
    vid_buffer = malloc(g_QWVidScreenWidth * g_QWVidScreenHeight * sizeof(byte));
    zbuffer = malloc(g_QWVidScreenWidth * g_QWVidScreenHeight * sizeof(short));
    d_8to24table = malloc(256 * sizeof(unsigned));
    
    vid.maxwarpwidth = WARP_WIDTH;
    vid.maxwarpheight = WARP_HEIGHT;
    vid.width = vid.conwidth = g_QWVidScreenWidth;
    vid.height = vid.conheight = g_QWVidScreenHeight;
    vid.aspect = ((float)vid.height / (float)vid.width) * (320.0 / 240.0);
    vid.numpages = 1;
    vid.colormap = host_colormap;
    vid.fullbright = 256 - LittleLong (*((int *)vid.colormap + 2048));
    vid.buffer = vid.conbuffer = vid_buffer;
    vid.rowbytes = vid.conrowbytes = g_QWVidScreenWidth;
    
    d_pzbuffer = zbuffer;
    
    int surfcachesize = D_SurfaceCacheForRes(g_QWVidScreenWidth, g_QWVidScreenHeight);
    
    surfcache = malloc(surfcachesize);
    
    D_InitCaches (surfcache, surfcachesize);

    VID_SetPalette(palette);
}

void    VID_Shutdown (void)
{
    if (surfcache != NULL)
    {
        free(surfcache);
    }
    
    if (d_8to24table != NULL)
    {
        free(d_8to24table);
    }
    
    if (zbuffer != NULL)
    {
        free(zbuffer);
    }
    
    if (vid_buffer != NULL)
    {
        free(vid_buffer);
    }
}

void    VID_Update (vrect_t *rects)
{
}

/*
 ================
 D_BeginDirectRect
 ================
 */
void D_BeginDirectRect (int x, int y, byte *pbitmap, int width, int height)
{
}


/*
 ================
 D_EndDirectRect
 ================
 */
void D_EndDirectRect (int x, int y, int width, int height)
{
}
