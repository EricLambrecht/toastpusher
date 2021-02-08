//
//  AddPusherConfigItemSheet.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

typealias OnAdd = ((_ appKey: String, _ appCluster: String, _ channelName: String, _ eventName: String) -> Void)

struct AddPusherConfigItemSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let clusterNames = ["us", "eu"]
    var onAdd: OnAdd
        
    @State var selectedClusterIndex = 1
    @State var appKey = ""
    @State var channelName = ""
    @State var eventName = ""
    
    var body: some View {
        PusherConfigItemForm(selectedClusterIndex: $selectedClusterIndex, appKey: $appKey, channelName: $channelName, eventName: $eventName, onAdd: {
            onAdd(appKey, clusterNames[selectedClusterIndex], channelName, eventName)
        })
        .navigationTitle("Add Event Config")
    }
}

struct AddPusherConfigItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        NavigationView {
            AddPusherConfigItemSheet()
        }
        #endif
        AddPusherConfigItemSheet(onAdd: { _,_,_,_ in print("saved") })
    }
}
