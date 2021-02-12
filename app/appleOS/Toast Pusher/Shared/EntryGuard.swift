//
//  AppView.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 11.02.21.
//

import SwiftUI

struct EntryGuard: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.isLoading {
            NavigationView {
                #if os(macOS)
                Text("")
                #endif
                ProgressView()
            }
        } else {
            if appState.showOnboardingScene {
                OnboardingView()
            } else {
                MainView()
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        EntryGuard().environmentObject(AppState())
    }
}
