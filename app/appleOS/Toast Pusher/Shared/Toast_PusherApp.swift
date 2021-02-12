//
//  Toast_PusherApp.swift
//  Shared
//
//  Created by Eric Lambrecht on 08.02.21.
//

import SwiftUI
import PushNotifications
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
class AppDelegate: ToastPusherAppDelegate, NSApplicationDelegate {
    // TODO:
    // Inherit from a common class in iOS/macOS delegates that contains the pushNotifications code
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("APP: did finish launching - macos")
        self.initializePusherBeamsFromAppSettings()
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APP: device token registered - macos")
        self.registerDeviceToken(deviceToken: deviceToken)
    }

    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String: Any]) {
        print("APP: did receive remote notification - macos")
        print(userInfo.keys)
        self.handleIncomingPushNotification(userInfo: userInfo)
    }
}
#else
class AppDelegate: ToastPusherAppDelegate, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("APP: did finish launching - ios")
        self.initializePusherBeamsFromAppSettings()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APP: device token registered - ios")
        self.registerDeviceToken(deviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("APP: did receive remote notification - ios")
        print(userInfo.keys)
        self.handleIncomingPushNotification(userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
}
#endif

@main
struct Toast_PusherApp: App {
    let persistenceController = PersistenceController.shared
    let pushNotifications = PushNotifications.shared
    @StateObject var pusherController = PusherInstanceManager.shared
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            EntryGuard()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(pusherController)
                .environmentObject(appDelegate.appState)
                .environmentObject(appDelegate.eventState)
        }
    }
}
