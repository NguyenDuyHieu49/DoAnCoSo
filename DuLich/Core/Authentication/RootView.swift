//
//  RootView.swift
//  DuLich
//
//  Created by Macbook Pro on 6/5/26.
//

import SwiftUI
struct RootView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if auth.isAuthenticated {
                MainTabView()
            } else {
                if appState.hasSeenWelcome {
                    LoginView()
                } else {
                    WelcomeView()
                }
            }
        }
    }
}
