//
//  PusherConfigItemForm.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct PusherConfigItemForm_Legacy: View {
    let clusterNames = ["us", "eu"]
        
    @Binding var selectedClusterIndex: Int
    @Binding var appKey: String
    @Binding var channelName: String
    @Binding var eventName: String
    var onAdd: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Pusher App Settings")) {
                TextField("App key", text: $appKey).font(.body)
                Picker(selection: $selectedClusterIndex, label: Text("App cluster")) {
                    ForEach(0 ..< clusterNames.count) {
                            Text(self.clusterNames[$0]).tag($0)
                    }
                }.font(.body)
            }
            
            #if os(macOS)
            VStack{}.padding(2)
            #endif
            
            Section(header: Text("Event Settings")) {
                TextField("Channel name", text: $channelName).font(.body)
                TextField("Event name", text: $eventName).font(.body)
            }
            
        }
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onAdd) {
                    Text("Add")
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                Button(action: onCancel) {
                    Text("Cancel")
                }
            }
        }
    }
}

struct PusherConfigItemForm_Previews: PreviewProvider {
    static var previews: some View {
        PusherConfigItemForm_Legacy(selectedClusterIndex: .constant(1), appKey: .constant("ahadh2i7qzei7gids"), channelName: .constant("my_channel"), eventName: .constant("my_event"), onAdd: { print("saved") }, onCancel: { print("cancelled") })
    }
}
