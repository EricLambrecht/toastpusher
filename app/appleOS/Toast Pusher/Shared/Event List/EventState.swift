//
//  EventState.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 12.02.21.
//

import Foundation

struct ToastPusherNotificationEvent: Hashable, Identifiable {
    var id: String
    var publishId: String
    var body: String
    var title: String
    var url: URL?
    
    init(publishId: String, body: String, title: String, url: URL? = nil) {
        self.id = publishId
        self.publishId = publishId
        self.body = body
        self.title = title
        self.url = url
    }
}

class EventState: ObservableObject {
    @Published var events = [ToastPusherNotificationEvent]()
    
    
    static var previewEmpty: EventState = {
        return EventState()
    }()
    static var previewFilled: EventState = {
        var state = EventState()
        for i in 1...10 {
            state.events.append(ToastPusherNotificationEvent(
                publishId: "publishid\(i)", body: "This is the message body \(i)", title: "Title \(i)", url: URL(string: "https://google.de")
            ))
        }
        return state
    }()
}
