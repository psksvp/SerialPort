//
//  Serial+ReadWrite.swift
//  
//
//  Created by psksvp on 13/7/2022.
//

import Foundation
import libSerial

public extension SerialPort
{
  func read(timeout: Timeout) throws -> UInt8
  {
    var buf: UInt8 = 0
    let v = sp_blocking_read(self.port, &buf, 1, timeout.value)
    if(0 < v.rawValue)
    {
      return buf
    }
    else
    {
      throw PortError.readError(v.rawValue)
    }
  }
  
  func read(size: UInt, timeout: Timeout) throws -> [UInt8]
  {
    let rawBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(size))
    defer { rawBuffer.deallocate() }
    
    let v = sp_blocking_read(self.port, rawBuffer, Int(size), timeout.value)
    if(0 < v.rawValue)
    {
      return Array(UnsafeBufferPointer(start: rawBuffer, count: Int(v.rawValue)))
    }
    else
    {
//      let err = [ 0 : "read success",
//                 -1 : "invalid argument",
//                 -3 : "memory allocation fail",
//                 -2 : "system error",
//                 -4 : "requested operation is not supported"]
      throw PortError.readError(v.rawValue)
    }
  }
  
  func write(data: [UInt8], timeout: Timeout) throws -> Int32
  {
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
    var d = data // the feak below wants a fucking var.
    buffer.initialize(from: &d, count: data.count)
    defer { buffer.deallocate() }
    let v = sp_blocking_write(self.port, buffer, data.count, timeout.value)
    if(v.rawValue < 0)
    {
      throw PortError.writeError(v.rawValue)
    }
    else
    {
      return v.rawValue
    }
  }
  
  var bytesAvailableForRead: UInt32
  {
    let v = sp_input_waiting(self.port)
    
    guard v.rawValue > 0 else {return 0}
    
    return UInt32(v.rawValue)
  }
  
  func readAvailable(timeout t: SerialPort.Timeout) throws -> [UInt8]
  {
    
    let a = self.bytesAvailableForRead
    return  try self.read(size: UInt(a), timeout: t)
  }
  
  
  func readLine(timeout t: SerialPort.Timeout, lineEnd: String = "\n", lineMax: UInt32 = 1000) throws -> String
  {
    // need a rewrite
    var line = ""
    var count = 0
    while count <= lineMax
    {
      let c = try read(timeout: t)
      line += String(Character(Unicode.Scalar(c)))
      if line.contains(lineEnd)
      {
        break;
      }
      count = count + 1
    }
    return line.trimmingCharacters(in: .newlines)
  }
  
  func writeLine(_ s: String, timeout t: SerialPort.Timeout) throws
  {
    let a: [UInt8] = Array((s.last == "\n" ? s : "\(s)\n").utf8)
    let _ = try self.write(data: a, timeout: t)
  }
}
