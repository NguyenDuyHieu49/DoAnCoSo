// DuLichApp.swift
import SwiftUI
import FirebaseCore

@main
struct DuLichApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authState = AuthState()
    @State private var hasSeenWelcome: Bool

    init() {
        FirebaseApp.configure()
        UserDefaults.standard.removeObject(forKey: "hasSeenWelcome") 
        _hasSeenWelcome = State(initialValue: false)
        print("DEBUG: removed hasSeenWelcome")
    }


    var body: some Scene {
        WindowGroup {
            Group {
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
            .onOpenURL { url in
                Task { @MainActor in
                    _ = PaymentCheckoutCoordinator.shared.handleReturnURL(url)
                }
            }
        }
    }
}

