//
//  SettingsViewMacOS.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct SettingsViewMacOS: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PusherConfigItem.creationDate, ascending: true)],
        animation: .default)
    private var pusherConfigItems: FetchedResults<PusherConfigItem>
    
    @State var selection: PusherConfigItem? = nil
    @State var showConfigItemSheet = false
    
    var body: some View {
        VStack {
            Text("Hello, Settings!")
            List(selection: $selection) {
                ForEach(pusherConfigItems, id: \.self) { item in
                    Text("\(item.channelName ?? "unknown"), \(item.eventName ?? "event")")
                }
                .onDelete(perform: deleteConfigItem)
            }
            .toolbar {
                #if os(iOS)
                EditButton()
                #endif

                Button(action: {
                    showConfigItemSheet = true
                }) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            .navigationTitle("Subscribed Pusher Events")
            
        }
        .sheet(isPresented: $showConfigItemSheet) {
            #if os(iOS)
            NavigationView {
                AddPusherConfigItemSheet(onAdd: { appKey, appCluster, channelName, eventName in
                    addConfigItem(appKey: appKey, appCluster: appCluster, channelName: channelName, eventName: eventName)
                    showConfigItemSheet = false
                })
            }
            #endif
            AddPusherConfigItemSheet(onAdd: { appKey, appCluster, channelName, eventName in
                addConfigItem(appKey: appKey, appCluster: appCluster, channelName: channelName, eventName: eventName)
                showConfigItemSheet = false
            })
        }
    }
    
    private func addConfigItem(appKey: String, appCluster: String, channelName: String, eventName: String) {
        withAnimation {
            let newItem = PusherConfigItem(context: viewContext)
            newItem.creationDate = Date()
            newItem.id = UUID()
            newItem.channelName = channelName
            newItem.eventName = eventName
            newItem.appKey = appKey
            newItem.appCluster = appCluster

            do {
                try viewContext.save()
                print("saved view context, added pusher config")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteConfigItem(offsets: IndexSet) {
        withAnimation {
            offsets.map { pusherConfigItems[$0] }.forEach(viewContext.delete)

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

struct SettingsViewMacOS_Previews: PreviewProvider {
    static var previews: some View {
        SettingsViewMacOS().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
