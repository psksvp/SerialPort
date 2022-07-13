//
//  SerialPort.swift
//
//
//  Created by psksvp on 13/7/2022.
//

import Foundation
import libSerial

public class SerialPort
{
  public enum PortError: Error
  {
    case initFail(String)
    case configError(String)
    case readError(Int32)
    case writeError(Int32)
  }
  
  ///////
  public enum Baud
  {
    case b1200
    case b2400
    case b4800
    case b9600
    case b19200
    case b115200
    
    var value: Int32
    {
      get
      {
        switch self
        {
          case .b1200   : return 1200
          case .b2400   : return 2400
          case .b4800   : return 4800
          case .b9600   : return 9600
          case .b19200  : return 19200
          case .b115200 : return 115200
        }
      }
    }
  }
  
  public enum Timeout
  {
    case infinite
    case milliseconds(UInt32)
    
    var value: UInt32
    {
      switch(self)
      {
        case .infinite: return 0
        case .milliseconds(let m): return m
      }
    }
  }
  
  ///////
  public enum BitSize
  {
    case five
    case six
    case seven
    case eight
    
    var value: Int32
    {
      switch self
      {
        case .five  : return 5
        case .six   : return 6
        case .seven : return 7
        case .eight : return 8
      }
    }
  }
  
  ///////
  public enum Parity
  {
    case none
    case even
    case odd
    
    var value: sp_parity
    {
      switch self
      {
        case .none : return SP_PARITY_NONE
        case .even : return SP_PARITY_EVEN
        case .odd  : return SP_PARITY_ODD
      }
    }
  }
  
  public enum Mode
  {
    case read
    case write
    case readWrite
    
    var value: sp_mode
    {
      switch self
      {
        case .read: return SP_MODE_READ
        case .write: return SP_MODE_WRITE
        case .readWrite: return SP_MODE_READ_WRITE
      }
    }
  }
  
  ///////
  public struct Config
  {
    let baud: Baud
    let bitSize: BitSize
    let parity: Parity
    let mode: Mode
    
    public init(baud: Baud, mode: Mode, bitSize b: BitSize = .eight, parity p: Parity = .none)
    {
      self.baud = baud
      self.bitSize = b
      self.parity = p
      self.mode = mode
    }
    
    func set(port p: SerialPort) throws
    {
      guard SP_OK == sp_set_baudrate(p.port, baud.value) else
      {
        throw PortError.configError("fail to set Baud Rate to \(baud)")
      }
      
      guard SP_OK == sp_set_bits(p.port, bitSize.value) else
      {
        throw PortError.configError("fail to set BitSize to \(bitSize)")
      }
      
      guard SP_OK == sp_set_parity(p.port, parity.value) else
      {
        throw PortError.configError("fail to set Parity to \(parity)")
      }
    }
    
  }
  
  ///////
  public private (set) var port: UnsafeMutablePointer<sp_port>? = nil
 
  
  ///////
  public init(portName: String, config: Config) throws
  {
    guard SP_OK == sp_get_port_by_name(portName, &self.port),
          SP_OK == sp_open(self.port, config.mode.value)
    else
    {
      if let errMSG = sp_last_error_message()
      {
        defer
        {
          sp_free_error_message(errMSG)
        }
        throw PortError.initFail("fail to open port \(portName): \(String(cString: errMSG))")
      }
      else
      {
        throw PortError.initFail("fail to open port \(portName)")
      }
    }
    
    try config.set(port: self)
  }
  
  ///////
  deinit
  {
    guard nil != self.port else {return}
    
    sp_close(self.port)
    sp_free_port(self.port)
  }
  
}

