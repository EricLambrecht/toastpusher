//
//  SettingsView.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 11.02.21.
//

import SwiftUI
import CoreData
import Combine

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var model: SettingsViewModel
    
    init(viewContext: NSManagedObjectContext) {
        model = SettingsViewModel(context: viewContext)
    }
    
    var body: some View {
        if $model.isFetchingSettings.wrappedValue { ProgressView()
        } else {
            VStack {
                #if os(macOS)
                PusherBeamConfigForm(instanceId: $model.instanceId, interest: $model.interest).padding(20)
                #else
                PusherBeamConfigForm(instanceId: $model.instanceId, interest: $model.interest)
                #endif
                Button("Apply Settings", action: apply).keyboardShortcut(.defaultAction)
                if $model.moreThanOneConfigFound.wrappedValue {
                    Text("Warning: Settings are corrupted. You should reset the settings and restart the app.").font(.callout)
                }
            }
            .toolbar{
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: deleteSettings) {
                        Text("Reset Settings")
                    }
                    .keyboardShortcut(.cancelAction)
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    func apply() {
        print("view: \($model.instanceId.wrappedValue), \($model.interest.wrappedValue)")
        model.applyCurrentSettings()
    }
    
    func deleteSettings() {
        model.deleteSettings()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(macOS)
        NavigationView {
            Text("Sidebar")
            SettingsView(viewContext: PersistenceController.preview.container.viewContext)
        }
        #else
        NavigationView {
            SettingsView(viewContext: PersistenceController.preview.container.viewContext)
        }
        #endif
    }
}
