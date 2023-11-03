//
//  AddNewDeviceView.swift
//  Wake-on-LAN_iOS
//
//  Created by DarkAssassin23 on 11/1/23.
//

import SwiftUI

struct AddNewDeviceView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isPresented: Bool
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State private var name:String = ""
    @State private var mac:String = ""
    @State private var ip:String = ""
    @State private var showingAlert:Bool = false
    @State private var alertMessageType = AddDeviceStatusCode.unknown
    
    var body: some View {
        VStack()
        {
            Text("Add Device")
                .font(.largeTitle)
            Spacer()
            Grid(alignment:.leading)
            {
                GridRow
                {
                    Text("Name:")
                    TextField("Server", text: $name, prompt: Text("Server"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.blue)
                        .keyboardType(.default)
                    
                }
                .padding(.horizontal)
                GridRow
                {
                    Text("MAC Address:")
                    TextField("aa:bb:cc:dd:ee:ff",text: $mac, prompt: Text("aa:bb:cc:dd:ee:ff"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.blue)
                        .keyboardType(.default)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal)
                GridRow
                {
                    Text("IP Address:")
                    TextField("192.168.1.5",text: $ip, prompt: Text("192.168.1.5"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .border(Color.blue)
                        .keyboardType(.decimalPad)
                }
                .padding(.horizontal)

            }
            .padding()
            Button(action: addDevice)
            {
                Text("Save")
            }.alert(isPresented: $showingAlert)
            {
                switch alertMessageType
                {
                case AddDeviceStatusCode.success:
                    return Alert(title: Text("Success"), message: Text("Your device was added successfully"),dismissButton: .default(Text("ok"), action: {isPresented = false}))
                case AddDeviceStatusCode.noName:
                    return Alert(title: Text("Failed add the device"),message: Text("No name was provided"), dismissButton: .default(Text("ok")))
                case AddDeviceStatusCode.badMac:
                    return Alert(title: Text("Failed add the device"),message: Text("The MAC Address for the device is invalid"), dismissButton: .default(Text("ok")))
                case AddDeviceStatusCode.invalidIP:
                    return Alert(title: Text("Failed add the device"),message: Text("The IP Address for the device is invalid"), dismissButton: .default(Text("ok")))
                case AddDeviceStatusCode.failedSave:
                    return Alert(title: Text("Failed to add the device"),message: Text("An error occured trying to save your new device to CoreData"), dismissButton: .default(Text("ok"), action: {isPresented = false}))
                default:
                    return Alert(title: Text("Error"), message: Text("An unknown error has occured"),dismissButton: .default(Text("ok"), action: {isPresented = false}))
                }
            }
            Spacer()
        }.onTapGesture {
            hideKeyboard()
        }
    }
    private func addDevice()
    {
        showingAlert = true
        if(name == "")
        {
            alertMessageType = AddDeviceStatusCode.noName
            return
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
        
        let addSuccess = addToCoreData(name: name, mac: mac, ip: ip, context: viewContext)
        
        if(addSuccess)
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
    AddNewDeviceView(isPresented: .constant(true)).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
