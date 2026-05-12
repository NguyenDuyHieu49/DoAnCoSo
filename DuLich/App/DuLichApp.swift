// DuLichApp.swift
import SwiftUI
import FirebaseCore

@main
struct DuLichApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authState = AuthState()
    // DON'T initialize from UserDefaults here; we'll set initial value in init properly
    @State private var hasSeenWelcome: Bool

    init() {
        FirebaseApp.configure()
        UserDefaults.standard.removeObject(forKey: "hasSeenWelcome") // DEBUG only
        _hasSeenWelcome = State(initialValue: false)
        print("DEBUG: removed hasSeenWelcome")
    }


    var body: some Scene {
        WindowGroup {
            if hasSeenWelcome {
                RootView().environmentObject(authState)
            } else {
                WelcomeView {
                    hasSeenWelcome = true
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                }
                .environmentObject(authState)
            }
        }
    }
}

