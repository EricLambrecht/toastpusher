//
//  EditPusherConfigItemSheet.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct EditPusherConfigItemSheet: View {
    var body: some View {
        Text("Hello World")
    }
}

struct EditPusherConfigItemSheet_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        NavigationView {
            EditPusherConfigItemSheet()
        }
        #endif
        EditPusherConfigItemSheet()
    }
}
