//
//  EventListRow.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 12.02.21.
//

import SwiftUI

struct EventListRow: View {
    var event: ToastPusherNotificationEvent
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(event.body)
                    .font(.subheadline)
                    .lineLimit(getBodyLineLimit())
                    .truncationMode(.tail)
                Spacer()
            }
            .padding(.leading, getLeadingPadding())
            Spacer()
            if event.url != nil {
                Link("Open", destination: event.url!)
                    .padding()
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            }
        }
        .frame(height: getRowHeight())
        .frame(minWidth: 200)
    }
    
    func getLeadingPadding() -> CGFloat {
        #if os(iOS)
        return 16
        #else
        return 4.5
        #endif
    }
    
    func getRowHeight() -> CGFloat {
        #if os(iOS)
        return 87
        #else
        return 50
        #endif
    }
    
    func getBodyLineLimit() -> Int {
        #if os(iOS)
        return 2
        #else
        return 1
        #endif
    }
}

struct EventListRow_Previews: PreviewProvider {
    static var previews: some View {
        EventListRow(event: ToastPusherNotificationEvent(publishId: "id", body: "Message Body that is extremely long and I dont know", title: "The Title", url: URL(string: "https://google.de")))
            .previewLayout(.sizeThatFits)
    }
}
