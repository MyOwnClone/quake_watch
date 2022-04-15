//
//  in_watch.c
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 15.04.2022.
//

#include "quakedef.h"

extern float g_QWRotateSpeed;
extern float g_QWForwardSpeed;
extern float g_QWGyroRotateSpeed;
extern float g_QWGyroForwardSpeed;

// most of this file's code is copied over from Quake_OSX, thanks a lot!!!

//
//  in_osx.c
//  Quake_OSX
//
//  Created by Heriberto Delgado on 1/30/16.
//
//

float   mouse_x, mouse_y;
float    old_mouse_x, old_mouse_y;
int        mx, my;

float   in_forwardmove;
float   in_sidestepmove;

float   in_pitchangle;
float   in_rollangle;

cvar_t    m_filter = {"m_filter","1"};
cvar_t    in_anglescaling = {"in_anglescaling","0.1"};

void IN_Init (void)
{
    Cvar_RegisterVariable (&m_filter);
    Cvar_RegisterVariable (&in_anglescaling);
}

void IN_Shutdown (void)
{
}

void IN_Commands (void)
{
}

void IN_Move (usercmd_t *cmd)
{
    in_forwardmove = g_QWForwardSpeed + g_QWGyroForwardSpeed;
    
    if (m_filter.value)
    {
        mouse_x = (mx + old_mouse_x) * 0.5f;
        mouse_y = (my + old_mouse_y) * 0.5f;
    }
    else
    {
        mouse_x = mx;
        mouse_y = my;
    }
    old_mouse_x = mx;
    old_mouse_y = my;
    mx = my = 0; // clear for next update
    
    mouse_x = g_QWRotateSpeed + g_QWGyroRotateSpeed;
    
    mouse_x *= sensitivity.value*100;
    mouse_y *= sensitivity.value*100;
        
    cl.viewangles[YAW] -= m_yaw.value * mouse_x;
    
    if (in_mlook.state & 1)
        V_StopPitchDrift ();
    
    if ( (in_mlook.state & 1) && !(in_strafe.state & 1))
    {
        cl.viewangles[PITCH] += m_pitch.value * mouse_y;
        if (cl.viewangles[PITCH] > 80)
            cl.viewangles[PITCH] = 80;
        if (cl.viewangles[PITCH] < -70)
            cl.viewangles[PITCH] = -70;
    }
    else
    {
        if ((in_strafe.state & 1) && noclip_anglehack)
            cmd->upmove -= m_forward.value * mouse_y;
        else
            cmd->forwardmove -= m_forward.value * mouse_y;
    }
    
    if (in_rollangle != 0.0 || in_pitchangle != 0.0)
    {
        cl.viewangles[YAW] -= in_rollangle * in_anglescaling.value * 90;
        
        V_StopPitchDrift();
        
        cl.viewangles[PITCH] += in_pitchangle * in_anglescaling.value * 90;

        if (cl.viewangles[PITCH] > 80)
            cl.viewangles[PITCH] = 80;
        if (cl.viewangles[PITCH] < -70)
            cl.viewangles[PITCH] = -70;
    }
    if (key_dest == key_game && (in_forwardmove != 0.0 || in_sidestepmove != 0.0))
    {
        float speed;
        
        if (in_speed.state & 1)
            speed = cl_movespeedkey.value;
        else
            speed = 1;
        
        //cmd->sidemove += in_forwardmove * speed * cl_forwardspeed.value;
        //cmd->forwardmove += in_sidestepmove * speed * cl_sidespeed.value;
        
        cmd->forwardmove += in_forwardmove * speed * cl_sidespeed.value;
    }
}


