import SwiftUI
import FirebaseCore

@main
struct DuLichApp: App {
    @StateObject private var authState = AuthState()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authState)
        }
    }
}
