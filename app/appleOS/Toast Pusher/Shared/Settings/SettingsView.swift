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
//        if $model.isFetchingSettings.wrappedValue { ProgressView()
//        } else {
            VStack() {
                #if os(macOS)
                VStack(alignment: .trailing) {
                    PusherBeamConfigForm(instanceId: $model.instanceId, interest: $model.interest)
                    Button("Apply Settings", action: apply)
                        .keyboardShortcut(.defaultAction)
                    if $model.moreThanOneConfigFound.wrappedValue {
                        Text("Warning: Settings are corrupted. You should reset the settings and restart the app.").font(.callout)
                    }
                    Spacer()
                }
                .frame(width: 400, height: 180, alignment: .center)
                #else
                PusherBeamConfigForm(instanceId: $model.instanceId, interest: $model.interest)
                if $model.moreThanOneConfigFound.wrappedValue {
                    Text("Warning: Settings are corrupted. You should reset the settings and restart the app.")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .frame(width: 250, height: 300)
                }
                #endif
            }
            .toolbar{
                    #if os(macOS)
                    ToolbarItem(placement: .cancellationAction) {
                        Button(action: deleteSettings) {
                            Text("Reset Settings")
                        }
                        .keyboardShortcut(.cancelAction)
                        .foregroundColor(.red)
                    }
                    #else
                    ToolbarItem(placement: .automatic) {
                        HStack(spacing: 20) {
                            if $model.moreThanOneConfigFound.wrappedValue {
                                Button(action: deleteSettings) {
                                    Text("Reset Settings")
                                }
                                .keyboardShortcut(.cancelAction)
                                .foregroundColor(.red)
                            }
                            Button("Apply", action: apply)
                                .keyboardShortcut(.defaultAction)
                        }
                    }
                    #endif
            }
            .background(getBackgroundColor())
            .ignoresSafeArea()
            .navigationTitle("Settings")
        //}
    }
    
    func getBackgroundColor() -> Color {
        var color: Color
        #if os(iOS)
        color = Color(UIColor.secondarySystemBackground)
        #else
        color = Color(Color.RGBColorSpace.sRGB, white: 0, opacity: 0)
        #endif
        return color
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
