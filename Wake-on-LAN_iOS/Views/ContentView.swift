//
//  ContentView.swift
//  Wake-on-LAN_iOS
//
//  Created by DarkAssassin23 on 11/1/23.
//

import SwiftUI
import CoreData
import Network

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var showAddDevice:Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        
                        Text("\(item.name!): \(item.macaddress!)")
                        Button(action: {
                            let network = Network()
                            network.connect(host: item.ip!)
                            network.send(mac: item.macaddress!)
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

                        
                    } label: {
                        Text(item.name!)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem()
                {
                    Button(action:{self.showAddDevice.toggle()})
                    {
                        Label("Add Device", systemImage: "plus")
                    }.sheet(isPresented: $showAddDevice, content: {
                        AddNewDeviceView(isPresented: $showAddDevice)
                            .environment(\.managedObjectContext, self.viewContext)
                    })
                }
            }
            .navigationTitle(Text("Device List"))
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
