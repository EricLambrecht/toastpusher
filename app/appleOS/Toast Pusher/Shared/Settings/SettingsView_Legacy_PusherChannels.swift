//
//  SettingsView_Legacy_PusherChannels.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct SettingsView_Legacy_PusherChannels: View {
    @EnvironmentObject var pusherManager: PusherInstanceManager

    @Environment(\.managedObjectContext) private var viewContext

    #if os(iOS)
    @Environment(\.editMode) var editMode
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    #endif
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PusherConfigItem.creationDate, ascending: true)],
        animation: .default)
    private var pusherConfigItems: FetchedResults<PusherConfigItem>
    
    @State var selection: PusherConfigItem? = nil
    @State var showConfigItemSheet = false
    
    var body: some View {
        VStack {
            List(selection: $selection) {
                ForEach(pusherConfigItems, id: \.self) { item in
                    Text("\(item.channelName ?? "unknown"), \(item.eventName ?? "event")")
                }
                .onDelete(perform: deleteConfigItem)
            }
            .toolbar {
                ToolbarItem() {
                    HStack {
                        Button(action: {
                            if selection != nil {
                                guard let idx = pusherConfigItems.firstIndex(of: selection!) else { return }
                                deleteConfigItem(offsets: [idx])
                            }
                        }){
                            Label("Delete Item", systemImage: "trash")
                        }.disabled(selection == nil)
                        #if os(iOS)
                        Button(action: {
                            withAnimation {
                                editMode?.wrappedValue = isEditing ? .inactive : .active
                            }
                        }) {
                            Label("Edit Items", systemImage: isEditing ? "pencil.circle.fill" : "pencil.circle")
                        }
                        #endif
                        Button(action: {
                            showConfigItemSheet = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showConfigItemSheet) {
            AddPusherConfigItemSheet(onAdd: { appKey, appCluster, channelName, eventName in
                addConfigItem(appKey: appKey, appCluster: appCluster, channelName: channelName, eventName: eventName)
                showConfigItemSheet = false
            }, onCancel: { showConfigItemSheet = false })
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
                pusherManager.subscribe(to: newItem)
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


struct SettingsView_Legacy_PusherChannels_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        NavigationView {
            Text("sidebar")
            SettingsView_Legacy_PusherChannels()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.editMode, .constant(EditMode.inactive))
            .environmentObject(PusherInstanceManager.shared)
        }
        #else
        NavigationView {
            Text("sidebar")
            SettingsView_Legacy_PusherChannels()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(PusherInstanceManager.shared)
        }
        #endif
    }
}
