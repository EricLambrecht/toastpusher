//
//  EventListRow.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 12.02.21.
//

import SwiftUI

struct EventListRow: View {
    var event: ToastPusherNotificationEvent
    var new: Bool
    var highlighted: Bool
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Spacer()
                HStack(alignment: .bottom) {
                    Text(event.title)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if event.date != nil {
                        Text(event.date!.timeAgoDisplay())
                            .foregroundColor(.gray)
                            .font(.caption)
                            .padding(.bottom, 1)
                    }
                }
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
        .overlay(
            new ?
                getNewMarker()
            : nil
            , alignment: .topLeading)
        .overlay(
            highlighted ? Rectangle()
                .foregroundColor(.clear)
            .border(Color.blue, width: 2) : nil
        )
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
    
    func getNewMarker() -> some View {
        #if os(iOS)
        return Rectangle()
            .frame(width: 4, height: getRowHeight() - 8)
        .padding(4)
            .foregroundColor(.green)
        #else
        return Rectangle()
            .frame(width: 2, height: getRowHeight() - 8)
            .padding(.vertical, 4)
            .foregroundColor(.green)
        #endif
    }
}

struct EventListRow_Previews: PreviewProvider {
    static var previews: some View {
        EventListRow(event: ToastPusherNotificationEvent(publishId: "id", body: "Message Body that is extremely long and I dont know", title: "eBay Kleinanzeigen", url: URL(string: "https://google.de"), date: Date()), new: true, highlighted: false)
            .previewLayout(.sizeThatFits)
    }
}
