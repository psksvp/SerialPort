import Foundation
import SerialPort

print("helloworld")
//try readGPS("/dev/cu.usbserial-2140")

//try arduio("/dev/cu.usbserial-2130")

print(SerialPort.availablePorts)


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

func arduio(_ portPath: String) throws
{
  struct SensorValue : Codable
  {
    public let id: UUID
    public let moisture: Float
    public let temperature: Float
    public let humidity: Int
    public let light: Float
  }

  class GrowModule
  {
    let port: SerialPort
    let ready: Bool
    
    var alive: Bool
    {
      guard let s = self.sendRequest("alive") else {return false}
      return "ready" == s
    }
    
    var id: String?
    {
      sendRequest("id")
    }
    
    var sensor: SensorValue?
    {
      guard let s = self.sendRequest("sensor") else {return nil}
      do
      {
        let v = try JSONDecoder().decode(SensorValue.self, from: s.data(using: .utf8)!)
        return v
      }
      catch
      {
        return nil
      }
    }
    
    init(port: String) throws
    {
      let cfg = SerialPort.Config(baud: .b9600, mode: .readWrite)
      self.port = try SerialPort(portName: port, config: cfg)
      let s = try self.port.readLine(timeout: .infinite)
      print(s)
      Thread.sleep(forTimeInterval: 1)
      self.ready = s == "ready"
      
    }
    
    func sendRequest(_ cmd: String) -> String?
    {
      do
      {
        try self.port.writeLine(cmd, timeout: .infinite)
        return try self.port.readLine(timeout: .infinite)
      }
      catch
      {
        print(error)
        return nil
      }
    }
    
  }


  let g = try GrowModule(port: "/dev/cu.usbserial-2130")
  while(!g.ready)
  {
    print("waiting ...")
    Thread.sleep(forTimeInterval: 1)
  }

  print(">", terminator: "")
  while let cmd = readLine()
  {
    if cmd == "quit"
    {
      break;
    }
    
    switch cmd
    {
      case "quite"  : break
      case "alive"  : print(g.alive)
      case "sensor" : print(g.sensor)
      case "id"     : print(g.id)
      default       : print("cmd??")
    }
    
    print(">", terminator: "")
  }

  print("done")
}
