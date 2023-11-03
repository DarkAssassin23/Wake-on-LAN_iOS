//
//  CurrentDeviceView.swift
//  Wake-on-LAN_iOS
//
//  Created by Will Jones on 11/3/23.
//

import SwiftUI

struct CurrentDeviceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    let network = Network()
    
    @State var item:Item
    @State private var name:String = ""
    @State private var mac:String = ""
    @State private var ip:String = ""
    @State private var alertSend:Bool = false
    @State private var sendSuccess:Bool = true
    @State private var showingAlert:Bool = false
    @State private var alertMessageType = AddDeviceStatusCode.unknown
    
    var body: some View {
        VStack()
        {
            Text("Current Device")
                .font(.largeTitle)
            Spacer()
            Grid(alignment:.leading)
            {
                GridRow
                {
                    Text("Name:")
                    TextField("Server", text: $name, prompt: Text(item.name!))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.blue)
                        .keyboardType(.default)
                    
                }
                .padding(.horizontal)
                GridRow
                {
                    Text("MAC Address:")
                    TextField("MAC Address", text: $mac, prompt: Text(item.macaddress!))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.blue)
                        .keyboardType(.default)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal)
                GridRow
                {
                    Text("IP Address:")
                    TextField("IP Address",text: $ip, prompt: Text(item.ip!))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.blue)
                        .keyboardType(.decimalPad)
                }
                .padding(.horizontal)

            }
            .padding()
            Button(action: updateDevice)
            {
                Text("Update")
            }.alert(isPresented: $showingAlert)
            {
                switch alertMessageType
                {
                case AddDeviceStatusCode.success:
                    return Alert(title: Text("Success"), message: Text("Your device was updated successfully"),dismissButton: .default(Text("ok")))
                case AddDeviceStatusCode.noName:
                    return Alert(title: Text("Nothing to do"),message: Text("There were no changes made"), dismissButton: .default(Text("ok")))
                case AddDeviceStatusCode.badMac:
                    return Alert(title: Text("Failed update the device"),message: Text("The MAC Address for the device is invalid"), dismissButton: .default(Text("ok")))
                case AddDeviceStatusCode.invalidIP:
                    return Alert(title: Text("Failed update the device"),message: Text("The IP Address for the device is invalid"), dismissButton: .default(Text("ok")))
                case AddDeviceStatusCode.failedSave:
                    return Alert(title: Text("Failed to update the device"),message: Text("An error occured trying to save your updates to CoreData"), dismissButton: .default(Text("ok")))
                default:
                    return Alert(title: Text("Error"), message: Text("An unknown error has occured"),dismissButton: .default(Text("ok")))
                }
            }
            Spacer()
        }.onTapGesture {
            hideKeyboard()
        }
        .onAppear(){network.connect(host: item.ip!)}
        Button(action: {
            sendSuccess = network.send(mac: item.macaddress!)
            alertSend = true
        })
        {
            Text("Send WOL Packet")
            Image(systemName: "power")
        }
        // make the button pretty
        .padding(10)
        .background(Color.blue)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert(isPresented: $alertSend)
        {
            if(sendSuccess)
            {
                return Alert(title: Text("Success"), message: Text("The Wake-on-LAN Packet was sent successfully"), dismissButton: .default(Text("ok")))
            }
            return Alert(title: Text("Failure"), message: Text("The Wake-on-LAN Packet failed to send"), dismissButton: .default(Text("ok")))
        }
    }
    private func updateDevice()
    {
        showingAlert = true
        if(name == "" && mac == "" && ip == "")
        {
            alertMessageType = AddDeviceStatusCode.noName
            return
        }
        if(name == "")
        {
            name = item.name!
        }
        if(mac == "")
        {
            mac = item.macaddress!
        }
        if(ip == "")
        {
            ip = item.ip!
        }
        
        if(!isValidMAC(mac: mac))
        {
            alertMessageType = AddDeviceStatusCode.badMac
            return
        }
        if(!isValidIP(ip: ip))
        {
            alertMessageType = AddDeviceStatusCode.invalidIP
            return
        }
        item.name = name
        item.macaddress = mac
        item.ip = ip
        let updateSuccess = updateCoreData(item: item, data: items, context: viewContext)
        
        if(updateSuccess)
        {
            alertMessageType = AddDeviceStatusCode.success
        }
        else
        {
            alertMessageType = AddDeviceStatusCode.failedSave
        }
        hideKeyboard()
    }
}

#Preview {
    CurrentDeviceView(item: Item()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
