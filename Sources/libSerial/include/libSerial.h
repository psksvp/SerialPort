//
//  libSerial.h
//
//
//  Created by psksvp on 13/7/2022.
//

#ifndef __LIB_SERIAL_PORT__
#define __LIB_SERIAL_PORT__
#include "../libserialport.h"
#include "../libserialport_internal.h"

int serialPortCount();
const char* serialPortName(int i);
void buildSerialPortList();

#endif
