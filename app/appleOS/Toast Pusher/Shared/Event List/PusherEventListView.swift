//
//  PusherEventListView.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct PusherEventListView: View {
    @EnvironmentObject var pusherManager: PusherInstanceManager
    @State var selection: ToastPusherNotificationEvent? = nil
    @State var showInfo = false
    var body: some View {
        List(selection: $selection) {
            ForEach(pusherManager.events, id: \.self) { event in
                VStack(alignment: .leading) {
                    Text("\(event.headline ?? "NO HEADLINE")")
                        .font(.headline)
                    Text(event.message)
                        .font(.subheadline)
                }
                .padding(10)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.gray, lineWidth: 1)
                        .offset(x: 1, y: 0)
                )
            }
        }
        .navigationTitle("Events")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .automatic) {
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                }
            }
            ToolbarItem(placement: .navigation) {
                Button(action: { showInfo = true }) {
                    Label("About", systemImage: "info.circle")
                }.disabled(showInfo == true)
            }
            #else
            ToolbarItem(placement: .status) {
                Button(action: { showInfo = true }) {
                    Label("About", systemImage: "info.circle")
                }.disabled(showInfo == true)
            }
            #endif
            ToolbarItem(placement: .status) {
                HStack {
                    Text("Pusher Connection:")
                    Text(pusherManager.connectionStatus)
                }.foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showInfo) {
            AboutView(onClose: { showInfo = false })
        }
    }
}

struct PusherEventListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            #if os(macOS)
            Text("sidebar")
            #endif
            PusherEventListView()
        }.environmentObject(PusherInstanceManager.preview)
    }
}
