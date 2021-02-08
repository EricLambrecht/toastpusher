//
//  ContentView.swift
//  Shared
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PusherConfigItem.creationDate, ascending: true)],
        animation: .default)
    private var pusherConfigItems: FetchedResults<PusherConfigItem>
    
    var body: some View {
        TabView {
            PusherEventListView()
                .tabItem {
                    Image(systemName: "1.square.fill")
                    Text("Notifications")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "2.square.fill")
                    Text("Settings")
                }
        }
        .font(.headline)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
