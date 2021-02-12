//
//  PusherBeamConfigForm.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 11.02.21.
//

import SwiftUI

struct PusherBeamConfigForm: View {
    @Binding var instanceId: String
    @Binding var interest: String
    
    var body: some View {
        Form {
            Section(header: Text("Pusher Beam Settings")) {
                HStack {
                    Text("Instance ID")
                        .foregroundColor(.gray)
                        .frame(width: 90, alignment: .leading)
                    TextField("12345678-5abc32-...", text: $instanceId).font(.body)
                }
                HStack {
                    Text("Interest")
                        .foregroundColor(.gray)
                        .frame(width: 90, alignment: .leading)
                    TextField("my-interest", text: $interest).font(.body)
                }
            }
        }
    }
}

struct PusherBeamConfigForm_Previews: PreviewProvider {
    static var previews: some View {
        PusherBeamConfigForm(instanceId: .constant("12345678-5abc32-ahadh2i7qzei7gids"), interest: .constant("my_interest"))
    }
}
