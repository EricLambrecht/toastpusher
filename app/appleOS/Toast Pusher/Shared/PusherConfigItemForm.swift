//
//  PusherConfigItemForm.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct PusherConfigItemForm: View {
    let clusterNames = ["us", "eu"]
        
    @Binding var selectedClusterIndex: Int
    @Binding var appKey: String
    @Binding var channelName: String
    @Binding var eventName: String
    var onAdd: () -> Void
    
    var body: some View {
        Form {
            Section(header: Text("Pusher App Settings")) {
                TextField("App key", text: $appKey)
                Picker(selection: $selectedClusterIndex, label: Text("App cluster")) {
                    ForEach(0 ..< clusterNames.count) {
                            Text(self.clusterNames[$0]).tag($0)
                    }
                }
            
            }
            
            Section(header: Text("Event Settings")) {
                TextField("Channel name", text: $channelName)
                TextField("Event name", text: $eventName)
            }
            
            Button(action: onAdd) {
                Text("Save Event Config")
            }
        }
    }
}

struct PusherConfigItemForm_Previews: PreviewProvider {
    static var previews: some View {
        PusherConfigItemForm(selectedClusterIndex: .constant(1), appKey: .constant("ahadh2i7qzei7gids"), channelName: .constant("my_channel"), eventName: .constant("my_event"), onAdd: { print("saved") })
    }
}
