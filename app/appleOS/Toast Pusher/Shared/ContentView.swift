//
//  ContentView.swift
//  Shared
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI
import CoreData
import PusherSwift

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var pusherManager: PusherInstanceManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PusherConfigItem.creationDate, ascending: true)],
        animation: .default)
    private var pusherConfigItems: FetchedResults<PusherConfigItem>
    
    @ObservedObject var notificationManager = LocalNotificationManager()
    
    @State var pusherRefs = [UUID: Pusher]()
    
    var body: some View {
        NavigationView {
            #if os(macOS)
            VStack {
                List {
                    NavigationLink(destination: PusherEventListView()) {
                        Label("Events", systemImage: "list.bullet")
                    }
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                .listStyle(SidebarListStyle())
               
            }
            #endif
            PusherEventListView()
        }
        .font(.headline)
        .onAppear(perform: {
            for item in pusherConfigItems {
                pusherManager.subscribe(to: item)
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(PusherInstanceManager.shared)
            ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(PusherInstanceManager.shared)
        }
    }
}
