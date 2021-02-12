//
//  AppState.swift
//  Toast Pusher
//
//  Created by Eric Lambrecht on 12.02.21.
//

import Foundation

class AppState: ObservableObject {
    @Published var showOnboardingScene: Bool = false
    @Published var isLoading: Bool = true
}
