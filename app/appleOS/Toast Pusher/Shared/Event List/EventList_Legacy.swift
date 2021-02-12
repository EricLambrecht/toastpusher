//
//  EventList.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 11.02.21.
//

import Foundation

class EventList_Legacy: ObservableObject {
    @Published var events: [ToastPusherNotificationEvent_Legacy] = []
}
