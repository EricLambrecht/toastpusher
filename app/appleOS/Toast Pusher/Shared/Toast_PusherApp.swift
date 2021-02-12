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
        print("app did finish launching - macos")
        self.initializePusherBeamsFromAppSettings()
    }
    
    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("app token registered - macos")
        self.pushNotifications.registerDeviceToken(deviceToken)
    }

    private func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        self.pushNotifications.handleNotification(userInfo: userInfo)
    }
}
#else
class AppDelegate: ToastPusherAppDelegate, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("app did finish launching - ios")
        self.initializePusherBeamsFromAppSettings()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("app token registered - ios")
        self.pushNotifications.registerDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.pushNotifications.handleNotification(userInfo: userInfo)
    }
}
#endif

@main
struct Toast_PusherApp: App {
    let persistenceController = PersistenceController.shared
    let pushNotifications = PushNotifications.shared
    let appState = AppState()
    @StateObject var pusherController = PusherInstanceManager.shared
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #else
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(pusherController)
                .environmentObject(appState)
        }
    }
}
