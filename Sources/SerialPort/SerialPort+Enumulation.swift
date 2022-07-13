//
//  SerialPort+Enumulation.swift
//  
//
//  Created by psksvp on 13/7/2022.
//

import Foundation
import libSerial

public extension SerialPort
{
  class var availablePorts: [String]
  {
    buildSerialPortList()
    guard serialPortCount() > 0 else {return [String]()}
    return  (0 ..< serialPortCount()).map{String(cString: serialPortName(Int32($0)))}
  }
}
