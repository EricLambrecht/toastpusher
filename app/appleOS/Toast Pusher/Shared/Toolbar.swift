//
//  Toolbar.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI

struct Toolbar: View {
    var body: some View {
        ToolbarItem(placement: .primaryAction) {
            Button("Notifications") {
                self.showSettings = false
            }
        }
        ToolbarItem(placement: .bottomBar) {
            Button("Settings") {
                self.showSettings = true
            }
        }
    }
}

struct Toolbar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("da")
                .toolbar {
                    Toolbar()
                }
        }
    }
}
