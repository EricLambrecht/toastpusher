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
    
    // TODO: React to onboarding finished change in AppState and initialize pusher beam then.
    
    internal func initializePusherBeamsFromAppSettings() {
        let fetchRequest: NSFetchRequest<PusherBeamConfig> = PusherBeamConfig.fetchRequest()
        let objects = try? viewContext.fetch(fetchRequest)
        if let configList: [PusherBeamConfig] = objects {
            if (configList.count == 0) {
                redirectToOnboardingScreen()
                return
            }
            
            let validConfigs = configList.filter { config in config.instanceID != nil && !config.interests!.isEmpty }
            if (validConfigs.count == 0) {
                redirectToOnboardingScreen()
                return
            }
            
            for config in configList {
                self.pushNotifications.start(instanceId: config.instanceID!)
                self.pushNotifications.registerForRemoteNotifications()
                
                for interest in config.interests! {
                    try? self.pushNotifications.addDeviceInterest(interest: interest)
                }
            }
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
              if settings.authorizationStatus == .authorized {
                // Notifications are allowed
                print("APP: Notifications are allowed")
                DispatchQueue.main.async {
                    self.appState.notificationsPermitted = true
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
                        }
                    } else {
                        print("APP: Notifications not permitted, \(error.debugDescription)")
                        DispatchQueue.main.async {
                            self.appState.notificationsPermitted = false
                        }
                    }
                }
              }
            }
            appState.pusherInitialized = true
        } else {
            print("APP: Fetch request failed, because the list is not even there: ask user to try again later!")
        }
        appState.isLoading = false
    }
    
    internal func registerDeviceToken(deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken)
        print("APP: did register device token")
    }
    
    internal func handleIncomingPushNotification(userInfo: [AnyHashable: Any]) {
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
        eventState.events.append(event)
    }
    
    private func redirectToOnboardingScreen() {
        // TODO: implement
        print("APP: redirecting to onboarding scene")
        appState.isLoading = false
        appState.showOnboardingScene = true
    }
}
