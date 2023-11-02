//
//  Wake_on_LAN_iOSApp.swift
//  Wake-on-LAN_iOS
//
//  Created by DarkAssassin23 on 11/1/23.
//

import SwiftUI

@main
struct Wake_on_LAN_iOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
