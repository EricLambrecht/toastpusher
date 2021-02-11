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

typealias AppKeyClusterString = String
typealias CallbackID = String

class PusherInstanceManager: PusherDelegate, ObservableObject {
    var pusherRefs = [AppKeyClusterString: Pusher]()
    var subscribedChannels = [String: PusherChannel]()
    var boundEventCallbacks = [String: CallbackID]()
    
    @Published var events = [ToastPusherNotificationEvent]()
    @Published var connectionStatus = ""
    
    static let shared = PusherInstanceManager()
    
    static let preview: PusherInstanceManager = {
        let previewInstance = PusherInstanceManager()
        previewInstance.events.append(ToastPusherNotificationEvent(message: "Message with headline", headline: "The headline"))
        previewInstance.events.append(ToastPusherNotificationEvent(message: "Message without headline"))
        previewInstance.events.append(ToastPusherNotificationEvent(message: "Message with url: https://google.de", headline: "With URL"))
        return previewInstance
    }()
    
    init() {
        // ...
    }
    
    public func subscribe(to item: PusherConfigItem) {
        guard let appKey = item.appKey, let appCluster = item.appCluster, let channelName = item.channelName, let eventName = item.eventName, let id = item.id
        else { return }
        
        let appKeyClusterString = getAppKeyClusterString(appKey: appKey, appCluster: appCluster)
        
        print("subscribing to \(appKey), \(channelName), \(eventName), \(appCluster), UUID: \(id)")
        let options = PusherClientOptions(
            host: .cluster(appCluster)
        )
        let pusher: Pusher
        if let existingRef = pusherRefs[appKeyClusterString] {
            pusher = existingRef
        } else {
            pusher = Pusher(key: appKey, options: options)
            pusher.connection.delegate = self
            pusher.connect()
            pusherRefs[appKeyClusterString] = pusher
        }
        
        let channel: PusherChannel
        if let existingChannel = subscribedChannels[channelName] {
            channel = existingChannel
        } else {
            channel = pusher.subscribe(channelName)
            subscribedChannels[channel.name] = channel
        }
        
        let callbackId = channel.bind(eventName: eventName, eventCallback: { event in
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
        boundEventCallbacks[eventName] = callbackId
    }
    
    public func unsubscribe(from item: PusherConfigItem) {
        guard let appKey = item.appKey, let appCluster = item.appCluster, let channelName = item.channelName, let eventName = item.eventName, let id = item.id
        else { return }
        
        print("unsubscribing from \(appKey), \(channelName), \(eventName), \(appCluster), UUID: \(id)")
                
        guard let subscribedChannel = subscribedChannels[channelName] else { return }
        guard let boundEventCallbackId = boundEventCallbacks[eventName] else { return }
        subscribedChannel.unbind(eventName: eventName, callbackId: boundEventCallbackId)
    }
    
    private func getAppKeyClusterString(appKey: String, appCluster: String) -> AppKeyClusterString {
        return "\(appKey)-\(appCluster)"
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
        connectionStatus = getConnectionStateString(new)
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
