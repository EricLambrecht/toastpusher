//
//  Toast_PusherApp.swift
//  Shared
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

@main
struct Toast_PusherApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
