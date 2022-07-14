//
//  File.swift
//  
//
//  Created by psksvp on 14/7/2022.
//

import Foundation

public extension Sequence where Element == UInt8
{
  var utf8String: String?
  {
    String(bytes: self, encoding: .utf8)
  }
}

extension String
{
  func write(toSerialPort p:SerialPort, timeout t: SerialPort.Timeout = .milliseconds(10000)) throws
  {
    try p.writeLine(self, timeout: t)
  }
}
