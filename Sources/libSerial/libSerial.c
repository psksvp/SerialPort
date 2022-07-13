//
//  libSerial.c
//
//
//  Created by psksvp on 13/7/2022.
//


#include "include/libSerial.h"
#include <stdio.h>
#include <string.h>

#define MAXPORT 255
#define MAXNAME 255

int portCount = 0;
char portNames[MAXPORT][MAXNAME];


int serialPortCount()
{
  return portCount;
}

const char* serialPortName(int i)
{
  if(i >= MAXPORT)
  {
    return NULL;
  }
  
  return portNames[i];
}


void buildSerialPortList()
{
  portCount = 0;
  struct sp_port** ports;
  if(SP_OK == sp_list_ports(&ports))
  {
    int i = 0;
    while(ports[i] != NULL && i < MAXPORT)
    {
      char* name = sp_get_port_name(ports[i]);
      if(NULL != name)
      {
        strncpy(portNames[portCount], name, MAXNAME);
        portCount = portCount + 1;
      }
      i = i + 1;
    }
    sp_free_port_list(ports);
  }
}
