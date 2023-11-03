//
//  Utils.swift
//  Wake-on-LAN_iOS
//
//  Created by DarkAssassin23 on 11/1/23.
//

import Foundation
import SwiftUI
import CoreData

enum AddDeviceStatusCode
{
    case success
    case noName
    case badMac
    case invalidIP
    case failedSave
    case unknown
}

enum SaveType
{
    case update
    case add
}

extension Int
{
    static func parse(from string: String) -> Int?
    {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

extension Collection
{
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence,Index> 
    {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
}

extension StringProtocol
{
    var byte: UInt8? { UInt8(self, radix: 16) }
    var hexToBytes: [UInt8] { unfoldSubSequences(limitedTo: 2).compactMap(\.byte) }
}

extension View
{
    func hideKeyboard()
    {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}


/// Check to see if the given MAC Address is valid
/// - Parameter mac: The MAC Address to check the validity of
/// - Returns: If the MAC Address is valid
func isValidMAC(mac: String) -> Bool
{
    let octets = mac.components(separatedBy: ":")
    if(octets.count != 6)
    {
        return false
    }
    for octet in octets
    {
        if let num = Int(octet, radix: 16)
        {
            if(num < UInt8.min || num > UInt8.max)
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    return true
}

/// Make sure the IP is a valid IP
/// - Parameter ip: The IP address to validate
/// - Returns: If the IP address is valid
func isValidIP(ip: String) -> Bool
{
    let octets = ip.components(separatedBy: ".")
    if(octets.count != 4)
    {
        return false
    }
    for octet in octets
    {
        if let num = Int.parse(from: octet)
        {
            if(num < UInt8.min || num >= UInt8.max)
            {
                return false
            }
        }
        else
        {
            return false
        }
    }
    return true
}

/// Get the given MAC address as a hex string
/// - Parameter mac: The MAC Address formated as aa:bb:cc:dd:ee:ff
/// - Returns: The clean MAC Address as hex
func getMac(mac: String) -> String
{
    let octets = mac.components(separatedBy: ":")
    var cleanHex:String = ""
    for octet in octets
    {
        let segment = Int(octet, radix: 16)
        cleanHex += String(format: "%02x", segment!)
    }
    return cleanHex
}

/// Add a new entry to CoreData
/// - Parameters:
///   - name: The name of the new connection to be added
///   - mac: The MAC Address of the new connection
///   - ip: IP of the device
///   - context: NSManagedObjectContext to allow the CoreData to be written
/// - Returns: If the new entry was added successfuly
func addToCoreData(name: String, mac: String, ip: String, context: NSManagedObjectContext) -> Bool
{
    let temp = Item(context: context)
    temp.ip = ip
    temp.name = name
    temp.macaddress = mac
    temp.id = UUID()

    do
    {
        try context.save()
    }
    catch let error
    {
        print(error)
        return false
    }
    return true
}

/// Update an existing entry in CoreData
/// - Parameters:
///   - item: The device to update
///   - data: All of the current devices
///   - context: NSManagedObjectContext to allow the CoreData to be written
/// - Returns: If the new entry was updated successfuly
func updateCoreData(item: Item, data: FetchedResults<Item>, context: NSManagedObjectContext) -> Bool
{
    for i in data
    {
        if(item.id == i.id)
        {
            i.name = item.name
            i.macaddress = item.macaddress
            i.ip = item.ip
            do
            {
                try context.save()
            }
            catch let error
            {
                print(error)
                return false
            }
            return true
        }
    }
    return false
}
