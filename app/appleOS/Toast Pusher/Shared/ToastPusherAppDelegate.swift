//
//  ToastPusherAppDelegate.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 11.02.21.
//

import Foundation
import PushNotifications
import SwiftUI
import CoreData
import UserNotifications
import Combine
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ApsAlertData {
    var body: String
    var title: String
}

struct ApsData {
    var alert: ApsAlertData
}

struct PusherBeamData {
    var instanceId: String
    var publishId: String
    var userShouldIgnore: Int
}

struct PusherBeamDataWrapper {
    var pusher: PusherBeamData
    var url: String?
}

class ToastPusherAppDelegate: NSObject {
    let pushNotifications = PushNotifications.shared
    let persistenceController = PersistenceController.shared
    lazy var viewContext = persistenceController.container.viewContext
    lazy var appState = AppState()
    lazy var eventState = EventState()
    var onboardingSceneSubscription: AnyCancellable?
    
    // TODO: React to onboarding finished change in AppState and initialize pusher beam then.
    
    internal func initApp() {
        print("APP: Initializing app")
        checkNotificationsAccess() {
            let validConfigs = self.getValidPusherBeamSettings()
            if (validConfigs.count == 0) {
                self.redirectToOnboardingScreen()
                print("APP: Waiting for user to leave onboarding scene...")
                self.onboardingSceneSubscription = self.appState.$showOnboardingScene.receive(on: DispatchQueue.main).sink { value in
                    // Try again after onboarding scene was left
                    if value == false {
                        print("APP: ...onboarding scene was left!")
                        self.initApp()
                    }
                }
            } else {
                self.onboardingSceneSubscription?.cancel()
                self.intializePusherBeams(fromSettings: validConfigs)
            }
            self.appState.isLoading = false
        }
    }
    
    internal func getValidPusherBeamSettings() -> [PusherBeamConfig] {
        let fetchRequest: NSFetchRequest<PusherBeamConfig> = PusherBeamConfig.fetchRequest()
        let objects = try? viewContext.fetch(fetchRequest)
        if let configList: [PusherBeamConfig] = objects {
            if (configList.count == 0) {
                return []
            }
            
            let validConfigs = configList.filter { config in config.instanceID != nil && !config.interests!.isEmpty }
            if (validConfigs.count == 0) {
                return []
            }
            
            return validConfigs
        }
        print("APP: Fetch request failed, because the list is not even there: ask user to try again later!")
        return []
    }
    
    internal func intializePusherBeams(fromSettings configList: [PusherBeamConfig]) {
        print("APP: Initializing Pusher Beams")
        for config in configList {
            self.pushNotifications.start(instanceId: config.instanceID!)
            self.pushNotifications.registerForRemoteNotifications()
            
            for interest in config.interests! {
                try? self.pushNotifications.addDeviceInterest(interest: interest)
            }
        }
        appState.pusherInitialized = true
    }
    
    internal func checkNotificationsAccess(_ onCompletion: @escaping () -> Void) {
        print("APP: Checking notifications access")
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
          if settings.authorizationStatus == .authorized {
            // Notifications are allowed
            print("APP: Notifications are allowed")
            DispatchQueue.main.async {
                self.appState.notificationsPermitted = true
                onCompletion()
            }
          }
          else {
            // Either denied or notDetermined
            print("APP: Notifications are disabled! Asking...")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted == true && error == nil {
                    print("APP: Notifications permitted")
                    DispatchQueue.main.async {
                        self.appState.notificationsPermitted = true
                        onCompletion()
                    }
                } else {
                    print("APP: Notifications not permitted, \(error.debugDescription)")
                    DispatchQueue.main.async {
                        self.appState.notificationsPermitted = false
                        onCompletion()
                    }
                }
            }
          }
        }
    }
    
    internal func registerDeviceToken(deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken)
        print("APP: did register device token")
    }
    
    internal func handleIncomingPushNotification(userInfo: [AnyHashable: Any], highlight: Bool = false) {
        self.pushNotifications.handleNotification(userInfo: userInfo)
        guard
            let apsData = userInfo["aps"] as? [String: Any],
            let alertData = apsData["alert"] as? [String: Any],
            let pusherData = userInfo["data"] as? [String: Any],
            let pusherBeamData = pusherData["pusher"] as? [String: Any],
            let publishId = pusherBeamData["publishId"] as? String,
            let title = alertData["title"] as? String,
            let body = alertData["body"] as? String
        else { return }
        
        print("APP: userinfo \(userInfo)")
        var event = ToastPusherNotificationEvent(
            publishId: publishId,
            body: body,
            title: title)
        if let url = pusherData["url"] as? String {
            event.url = URL(string: url)
        }
        if let dateString = pusherData["date"] as? String {
            print("found date \(dateString)")
            let formatter = ISO8601DateFormatter()
            event.date = formatter.date(from: dateString)
        }
        
        let existingEventIndex = eventState.events.firstIndex(of: event)
        if existingEventIndex != nil {
            event = eventState.events[existingEventIndex!]
        } else {
            eventState.events.insert(event, at: 0)
        }
        
        eventState.markEventAsNew(by: event.publishId)
        if highlight {
            eventState.highlightEvent(by: event.publishId)
        }
    }
    
    private func redirectToOnboardingScreen() {
        // TODO: implement
        print("APP: redirecting to onboarding scene")
        appState.isLoading = false
        appState.showOnboardingScene = true
    }
}
