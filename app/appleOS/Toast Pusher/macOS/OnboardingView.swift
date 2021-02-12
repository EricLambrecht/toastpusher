//
//  OnboardingView.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 11.02.21.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var instanceId: String = ""
    @State var interest: String = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 140.0, height: 140.0)
                .fixedSize()
                .padding(25)
            VStack {
                Text("Toast Pusher").font(.system(size: 24)).padding(16)
                Form {
                    Section(header: Text("Pusher Beam Settings")) {
                        TextField("Instance ID", text: $instanceId).font(.body)
                        TextField("interest", text: $interest).font(.body)
                    }
                }
                HStack {
                    Spacer()
                    Button("Finish setup") {
                        onAdd()
                    }.keyboardShortcut(.defaultAction)
                }
            }
            .frame(minWidth: 400, maxWidth: 400)
            .fixedSize()
            .padding(20)
        }
        .frame(width: 660, height: 350)
        .fixedSize()
    }
    
    func onAdd() {
        let newItem = PusherBeamConfig(context: viewContext)
        newItem.id = UUID()
        newItem.creationDate = Date()
        newItem.instanceID = instanceId
        newItem.interests = [interest]

        do {
            print("saving onboarding config")
            try viewContext.save()
            appState.showOnboardingScene = false
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error during onboarding \(nsError), \(nsError.userInfo)")
        }
    }
    
    func onCancel() {
        
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
