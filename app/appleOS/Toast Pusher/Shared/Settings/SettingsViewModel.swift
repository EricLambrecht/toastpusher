//
//  AppSettings.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 11.02.21.
//

import Foundation
import CoreData
#if os(macOS)
import AppKit
#else
import UIKit
#endif

class SettingsViewModel: ObservableObject {
    var viewContext: NSManagedObjectContext
    var configList: [PusherBeamConfig] = []
    
    @Published var instanceId: String = ""
    @Published var interest: String = ""
    @Published var isFetchingSettings = true
    @Published var moreThanOneConfigFound = false
    @Published var error: String? = nil
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        let fetchRequest: NSFetchRequest<PusherBeamConfig> = PusherBeamConfig.fetchRequest()
        do {
            configList = try self.viewContext.fetch(fetchRequest)
            if configList.count == 0 {
                self.error = "Error: config is empty"
                return
            }
            self.instanceId = configList.first!.instanceID ?? ""
            self.interest = configList.first!.interests?.first ?? ""
            self.moreThanOneConfigFound = configList.count > 1
        } catch {
            self.error = "Error: could not fetch config"
        }
        self.isFetchingSettings = false
    }
    
    func applyCurrentSettings() {
        guard let currentSettings = configList.first else { return }
        currentSettings.instanceID = instanceId
        currentSettings.interests = [interest]
        print("model: \(instanceId), \(interest)")

        do {
            print("saving settings config")
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error during onboarding \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteSettings() {
        do {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PusherBeamConfig.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try self.viewContext.execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
        print("deleted everything!")
    }
}
