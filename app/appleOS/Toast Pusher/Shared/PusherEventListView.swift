//
//  PusherEventListView.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct PusherEventListView: View {
    @EnvironmentObject var pusherManager: PusherInstanceManager
    var body: some View {
        List() {
            ForEach(pusherManager.events, id: \.self) { event in
                Text("\(event.headline ?? "NO HEADLINE"), \(event.message)")
            }
        }
    }
}

struct PusherEventListView_Previews: PreviewProvider {
    static var previews: some View {
        PusherEventListView()
    }
}
