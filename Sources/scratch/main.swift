//
//  main.swift
//
//
//  Created by psksvp on 13/7/2022.
//


import Foundation
import SerialPort

print("helloworld")
print(SerialPort.availablePorts)
try readGPS("/dev/cu.usbserial-2140")

//try arduio("/dev/cu.usbserial-2130")



func readGPS(_ portPath: String) throws
{
  let cfg = SerialPort.Config(baud: .b4800, mode: .read)
  let p = try SerialPort(portName: portPath, config: cfg)
  print(p.name)
  print(p.description)
  print(p.product)
  while true
  {
    let l = try p.readLine(timeout: .milliseconds(10000))
    print(l)
  }
}

