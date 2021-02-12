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
                TextField("Instance ID", text: $instanceId).font(.body)
                TextField("interest", text: $interest).font(.body)
            }
        }
    }
}

struct PusherBeamConfigForm_Previews: PreviewProvider {
    static var previews: some View {
        PusherBeamConfigForm(instanceId: .constant("ahadh2i7qzei7gids"), interest: .constant("my_interest"))
    }
}
