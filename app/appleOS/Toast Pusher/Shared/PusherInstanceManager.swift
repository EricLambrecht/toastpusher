//
//  PusherInstanceManager.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 08.02.21.
//

import Foundation
import PusherSwift

struct ToastPusherNotificationEvent: Decodable, Hashable {
    var message: String
    var headline: String?
}

class PusherInstanceManager: PusherDelegate, ObservableObject {
    var pusherRefs = [UUID: Pusher]()
    
    @Published var events = [ToastPusherNotificationEvent]()
    
    static let shared = PusherInstanceManager()
    
    init() {
        // ...
    }
    
    public func subscribe(to item: PusherConfigItem) {
        guard let appKey = item.appKey, let appCluster = item.appCluster, let channelName = item.channelName, let eventName = item.eventName, let id = item.id
        else { return }
        
        print("subscribing to \(appKey), \(channelName), \(eventName), \(appCluster), UUID: \(id)")
        let options = PusherClientOptions(
            host: .cluster(appCluster)
        )
        let pusher = Pusher(key: appKey, options: options)
        pusher.connection.delegate = self
        pusher.connect()
        let channel = pusher.subscribe(channelName)
        channel.bind(eventName: eventName, eventCallback: { event in
            var notificationEvent: ToastPusherNotificationEvent
            guard let data = event.data else { return }
            do {
                notificationEvent = try JSONDecoder().decode(ToastPusherNotificationEvent.self, from: data.data(using: .utf8)!)
            } catch {
                notificationEvent = ToastPusherNotificationEvent(message: data)
            }
            print("event detected, data: \(data)")
            self.events.append(notificationEvent)
        })
        pusherRefs[id] = pusher
    }
    
    private func getConnectionStateString(_ state: ConnectionState) -> String {
        switch state {
        case .connected:
            return "connected"
        case .connecting:
            return "connecting"
        case .disconnecting:
            return "disconnecting"
        case .disconnected:
            return "disconnected"
        default:
            return "unknown"
        }
    }
    
    internal func subscribedToChannel(name: String) {
        print("subscribed to channel \(name)")
    }
    internal func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        print("changed connection state \(getConnectionStateString(old)), \(getConnectionStateString(new))")
    }
    internal func failedToSubscribeToChannel(name: String) {
        print("Failed to subscribe to channel \(name)")
    }
    internal func failedToDecryptEvent(eventName: String, channelName: String) {
        print("Failed to decrypt event \(eventName) (\(channelName))")
    }
    internal func receivedError(error: PusherError) {
        print("Received error: SORRY, MESSAGE IS STILL TO BE IMPLEMENTED")
    }
}
