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
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class ToastPusherAppDelegate: NSObject {
    let pushNotifications = PushNotifications.shared
    let persistenceController = PersistenceController.shared
    lazy var viewContext = persistenceController.container.viewContext
    lazy var appState = AppState()
    
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
            appState.isLoading = false
        } else {
            print("Fetch request failed, because the list is not even there: ask user to try again later!")
        }
    }
    
    private func redirectToOnboardingScreen() {
        // TODO: implement
        print("redirecting to onboarding scene")
        appState.isLoading = false
        appState.showOnboardingScene = true
    }
}
