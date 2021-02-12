//
//  OnboardingView.swift
//  Toast Pusher (iOS)
//
//  Created by Eric Lambrecht on 12.02.21.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var instanceId: String = ""
    @State var interest: String = ""
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120.0, height: 120.0)
                        .fixedSize()
                        .padding(10)
                    Text("Toast Pusher").font(.system(size: 24)).padding(16)
                    VStack(alignment: .leading) {
                        Form {
                            Section(header: Text("Pusher Beam Settings").padding(.top, 12)) {
                                TextField("Instance ID", text: $instanceId).font(.body)
                                TextField("interest", text: $interest).font(.body)
                            }
                        }
                        .frame(maxHeight: 140)
                        Text("In order to use this app, you have to specify the Pusher Beam instance you want to connect to and also an interest you want to receive notifications for.")
                            .font(.caption)
                            .padding(.horizontal, 20)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("You can create a Pusher Beam instance")
                                .font(.caption)
                                .padding(.top, 6)
                                .padding(.leading, 20)
                                .foregroundColor(.gray)
                            Link("here", destination: URL(string: "https://dashboard.pusher.com/beams")!)
                                .font(.caption)
                                .padding(.top, 6)
                        }
                        Spacer()
                    }
                    .background(Color.init(UIColor.secondarySystemBackground))
                    .ignoresSafeArea()
                    .frame(maxHeight: geometry.size.height/2)
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Finish Setup") {
                        onAdd()
                    }
                }
            }
        }
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
