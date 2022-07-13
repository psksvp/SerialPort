//
//  SerialPort+DeviceInfo.swift
//  
//
//  Created by psksvp on 13/7/2022.
//

import Foundation
import libSerial

public extension SerialPort
{
  ///////
  var name: String
  {
    guard nil != self.port,
          let cs = sp_get_port_name(self.port) else {return ""}
    return String(cString: cs)
  }
  
  ///////
  var description: String
  {
    guard nil != self.port,
          let cs = sp_get_port_description(self.port) else {return ""}
    return String(cString: cs)
  }
  
  ///////
  var product: String
  {
    guard nil != self.port,
          let cs = sp_get_port_usb_product(self.port) else {return ""}
    return String(cString: cs)
  }
}
