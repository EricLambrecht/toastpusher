//
//  AboutView.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 09.02.21.
//

import SwiftUI

struct AboutView: View {
    var onClose: () -> Void
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/).font(.headline)
            Text("This is Toast Pusher")
        }
        .padding(40)
        .navigationTitle("About Toast Pusher")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: onClose) {
                    Text("Close")
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView(onClose: {})
    }
}
