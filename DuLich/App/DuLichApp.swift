import SwiftUI
import FirebaseCore

@main
struct DuLichApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RootView()
            }
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithTopOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
