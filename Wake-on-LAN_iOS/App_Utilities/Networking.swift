//
//  Networking.swift
//  Wake-on-LAN_iOS
//
//  Created by DarkAssassin23 on 11/1/23.
//

import Foundation
import CoreData
import Network
import SwiftUI


/// Generate the Magic Packet required for Wake-on-LAN
/// - Parameter mac: The MAC Address of the machine
/// - Returns: The magic packet that will wake the machine
/// > Note: Info on how magic packets are created can be found
/// [here](https://en.wikipedia.org/wiki/Wake-on-LAN#Magic_packet)
func generateMagicPacket(mac: String) -> String
{
    let preamble = "ff"
    let strippedMac = getMac(mac: mac)
    let preambleLen = 6
    let reps:Int = 16 + preambleLen
    var magicPacket:String = ""
    for x in 1...reps
    {
        if(x <= preambleLen)
        {
            magicPacket += preamble
        }
        else
        {
            magicPacket += strippedMac
        }
    }
    return magicPacket
}

/// Class that handles sending of magic packets
///
/// > Warning: The class does not do any checking of IP addresses
/// numbers. Make sure you ensure they are valid before passing them
/// into the connect function
class Network : ObservableObject
{
    private var group:NWConnectionGroup?
    private var connection: NWConnection?
    private var port:NWEndpoint.Port
    private var host:NWEndpoint.Host
    /// Initialization constructor for the Network object
    init() {
        port = NWEndpoint.Port("9")!
        host = NWEndpoint.Host("255.255.255.255")
    }
    
    
    /// Set up the UDP connection with the hose
    /// - Parameter host: IP of the host
    /// > Note: Ideally this would be a NWConnectionGroup however you need
    /// special devleoper permissions to do that which I don't have, so in liue of that
    /// I'm requiring the IP
    func connect(host: String)
    {
//        guard let mulitcast = try? NWMulticastGroup(for: [.hostPort(host: self.host, port: self.port)])
//        else { fatalError() }
//        self.group = NWConnectionGroup(with: mulitcast, using: .udp)
//        self.group?.stateUpdateHandler = { (newState) in
//            print("Group entered state \(String(describing: newState))")
//        }
//        self.group?.start(queue: .main)
        
        self.connection = NWConnection(host: NWEndpoint.Host(host), port: port, using: .udp)
        self.connection?.stateUpdateHandler = { (newState) in
            switch (newState) {
            case .preparing:
                NSLog("Entered state: preparing")
            case .ready:
                NSLog("Entered state: ready")
            case .setup:
                NSLog("Entered state: setup")
            case .cancelled:
                NSLog("Entered state: cancelled")
            case .waiting:
                NSLog("Entered state: waiting")
            case .failed:
                NSLog("Entered state: failed")
            default:
                NSLog("Entered an unknown state")
            }
        }
        self.connection?.viabilityUpdateHandler = { (isViable) in
            if (isViable) {
                NSLog("Connection is viable")
            } else {
                NSLog("Connection is not viable")
            }
        }
                
        self.connection?.betterPathUpdateHandler = { (betterPathAvailable) in
            if (betterPathAvailable) {
                NSLog("A better path is availble")
            } else {
                NSLog("No better path is available")
            }
        }
        self.connection?.start(queue: .main)
    }
    
    func stop()
    {
        self.connection?.cancel()
        NSLog("Connection stopped")
    }
    
    /// Sends data to the server
    /// - Parameter mac: The MAC Address of the device to send the Wake-on-LAN packet to
    func send(mac: String)
    {
        let data = Data(generateMagicPacket(mac: mac).hexToBytes)
//        self.group?.send(content: data) { error in (error)
//            print("Send complete with error \(String(describing: error))")
//        }
        self.connection?.send(content: data, completion: .contentProcessed({ sendError in
            if let error = sendError {
                NSLog("Unable to process and send the data: \(error)")
            } else {
                NSLog("Data has been sent")
                }
            }
        ))
    }
}
