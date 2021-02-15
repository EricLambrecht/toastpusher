//
//  Toast_PusherApp.swift
//  Shared
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI
import PushNotifications
import UserNotifications
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
class AppDelegate: ToastPusherAppDelegate, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    // TODO:
    // Inherit from a common class in iOS/macOS delegates that contains the pushNotifications code
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("APP: did finish launching - macos")
        UNUserNotificationCenter.current().delegate = self
        self.initApp()
        if notification.userInfo != nil {
            self.handleIncomingPushNotification(userInfo: notification.userInfo!)
        }
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APP: device token registered - macos")
        self.registerDeviceToken(deviceToken: deviceToken)
    }

    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        print("APP: did receive remote notification - macos")
        self.handleIncomingPushNotification(userInfo: userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("APP: did receive remote notification in foreground, playing sound - macos")
        print(notification.request.content)
        self.handleIncomingPushNotification(userInfo: notification.request.content.userInfo)
        // Decide how the notification (that was received in the foreground)
        // should be presented to the user
        completionHandler(UNNotificationPresentationOptions.sound)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the user interaction with the notification
        print("APP: user interacted with notification - macos")
        self.handleIncomingPushNotification(userInfo: response.notification.request.content.userInfo, highlight: true)
        completionHandler()
    }
}
#else
class AppDelegate: ToastPusherAppDelegate, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("APP: did finish launching - ios")
        UNUserNotificationCenter.current().delegate = self
        self.initApp()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APP: device token registered - ios")
        self.registerDeviceToken(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("APP: did receive remote notification - ios")
        self.handleIncomingPushNotification(userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Decide how the notification (that was received in the foreground)
        // should be presented to the user
        print("APP: did receive remote notification in foreground - ios")
        print(notification.request.content)
        self.handleIncomingPushNotification(userInfo: notification.request.content.userInfo)
        completionHandler(UNNotificationPresentationOptions.sound)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the user interaction with the notification
        print("APP: user interacted with notification - ios")
        self.handleIncomingPushNotification(userInfo: response.notification.request.content.userInfo, highlight: true)
        completionHandler()
    }
}
#endif

@main
struct Toast_PusherApp: App {
    @Environment(\.scenePhase) var scenePhase
    let persistenceController = PersistenceController.shared
    let pushNotifications = PushNotifications.shared
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            EntryGuard()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appDelegate.appState)
                .environmentObject(appDelegate.eventState)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .background:
                        print("APP: moving to background")
                        appDelegate.eventState.markAllEventsAsOld()
                        return
                    case .inactive:
                        print("APP: becoming inactive")
                        return
                    case .active:
                        print("APP: becoming active")
                        return
                    @unknown default:
                        return
                    }
                }
        }
    }
}
