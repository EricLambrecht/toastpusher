//
//  PusherEventListView.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct PusherEventListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var eventState: EventState
    @EnvironmentObject var appState: AppState
    @State var selection: ToastPusherNotificationEvent? = nil
    @State var showInfo = false
    var body: some View {
        VStack {
            if eventState.events.count > 0 {
                List(selection: $selection) {
                    ForEach(eventState.events, id: \.self) { event in
                        EventListRow(
                            event: event,
                            new: eventState.newEventPublishIds.contains(event.publishId),
                            highlighted: event.publishId == eventState.highlightedEventPublishId)
                            .listRowInsets(EdgeInsets())
                        #if os(macOS)
                        Divider()
                        #endif
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                if appState.notificationsPermitted {
                    Text("Waiting for incoming events...")
                        .foregroundColor(.gray)
                } else {
                    Text("You have to allow notifications in otder to use this app!")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Events")
        .toolbar {
            ToolbarItem(placement: .status) {
                HStack {
                    Text("Pusher Connection:")
                    Circle()
                        .fill(getConnectionCircleColor())
                        .frame(width: 12, height: 12)
                }.foregroundColor(.gray)
            }
            #if os(iOS)
            ToolbarItem(placement: .automatic) {
                NavigationLink(destination: SettingsView(viewContext: viewContext)) {
                    Label("Settings", systemImage: "gearshape")
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
        }
        .sheet(isPresented: $showInfo) {
            AboutView(onClose: { showInfo = false })
        }
    }
    
    func getConnectionCircleColor() -> Color {
        var red: Color, green: Color, yellow: Color
        #if os(iOS)
        green = Color(UIColor.systemGreen)
        red = Color(UIColor.systemRed)
        yellow = Color.yellow
        #else
        green = Color.green
        red = Color.red
        yellow = Color.yellow
        #endif
        if (!self.appState.pusherInitialized) {
            return red
        }
        if (!self.appState.notificationsPermitted) {
            return yellow
        }
        return green
    }
}

struct PusherEventListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            #if os(macOS)
            Text("sidebar")
            #endif
            PusherEventListView()
        }
        .environmentObject(EventState.previewFilled)
        .environmentObject(AppState.preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
