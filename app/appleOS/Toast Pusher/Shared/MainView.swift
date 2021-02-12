//
//  ContentView.swift
//  Shared
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI
import CoreData
import PusherSwift

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            #if os(macOS)
            VStack {
                List {
                    NavigationLink(destination: PusherEventListView()) {
                        Label("Events", systemImage: "captions.bubble")
                    }
                    NavigationLink(destination: SettingsView(viewContext: viewContext)) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                .listStyle(SidebarListStyle())               
            }
            #endif
            PusherEventListView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
