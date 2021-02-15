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
    var date: Date?
    
    init(publishId: String, body: String, title: String, url: URL? = nil, date: Date? = nil) {
        self.id = publishId
        self.publishId = publishId
        self.body = body
        self.title = title
        self.url = url
        self.date = date
    }
}

class EventState: ObservableObject {
    @Published var events = [ToastPusherNotificationEvent]()
    @Published var highlightedEventPublishId: String? = nil
    @Published var newEventPublishIds: [String] = []
    
    func highlightEvent(by publishId: String) -> Void {
        highlightedEventPublishId = publishId
    }
    
    func removeHighlight() -> Void {
        highlightedEventPublishId = nil
    }
    
    func markAllEventsAsOld() -> Void {
        newEventPublishIds = []
    }
    
    func markEventAsOld(by publishId: String) {
        newEventPublishIds.removeAll(where: { $0 == publishId })
    }
    
    func markEventAsNew(by publishId: String) {
        if !newEventPublishIds.contains(publishId) {
            newEventPublishIds.append(publishId)
        }
    }
    
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
        state.highlightEvent(by: "publishid3")
        state.newEventPublishIds = ["publishid1","publishid2","publishid3","publishid4"]
        return state
    }()
}
