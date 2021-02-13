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
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120.0, height: 120.0)
                .fixedSize()
                .padding(10)
            Text("Toast Pusher").font(.title)
            Text("Version 0.1.2")
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.top, 2)
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
