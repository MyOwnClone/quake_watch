//
//  net_watch.c
//  qwatch WatchKit Extension
//
//  Created by Tomas Vymazal on 15.04.2022.
//
// based on https://github.com/Izhido/Quake_For_OSX
// Quake Apple Watch port does not really use real networking, but demo and some other code need to have a semblance of network code to function properly

#include "quakedef.h"
#include "net_loop.h"
#include "net_dgrm.h"

// just stubs to make compiler happy

net_driver_t net_drivers[MAX_NET_DRIVERS] =
{
    {
        "Loopback",
        false,
        Loop_Init,
        Loop_Listen,
        Loop_SearchForHosts,
        Loop_Connect,
        Loop_CheckNewConnections,
        Loop_GetMessage,
        Loop_SendMessage,
        Loop_SendUnreliableMessage,
        Loop_CanSendMessage,
        Loop_CanSendUnreliableMessage,
        Loop_Close,
        Loop_Shutdown
    },
    {
        "Datagram",
        false,
        Datagram_Init,
        Datagram_Listen,
        Datagram_SearchForHosts,
        Datagram_Connect,
        Datagram_CheckNewConnections,
        Datagram_GetMessage,
        Datagram_SendMessage,
        Datagram_SendUnreliableMessage,
        Datagram_CanSendMessage,
        Datagram_CanSendUnreliableMessage,
        Datagram_Close,
        Datagram_Shutdown
    }
};

int net_numdrivers = 2;

#include "net_udp.h"

net_landriver_t    net_landrivers[MAX_NET_DRIVERS] =
{
    {
        "UDP",
        false,
        0,
        UDP_Init,
        UDP_Shutdown,
        UDP_Listen,
        UDP_OpenSocket,
        UDP_CloseSocket,
        UDP_Connect,
        UDP_CheckNewConnections,
        UDP_Read,
        UDP_Write,
        UDP_Broadcast,
        UDP_AddrToString,
        UDP_StringToAddr,
        UDP_GetSocketAddr,
        UDP_GetNameFromAddr,
        UDP_GetAddrFromName,
        UDP_AddrCompare,
        UDP_GetSocketPort,
        UDP_SetSocketPort
    }
};

int net_numlandrivers = 1;
