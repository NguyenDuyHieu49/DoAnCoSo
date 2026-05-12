import UIKit
import GoogleSignIn
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }

    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) {
            print("AppDelegate: Google handled URL:", url.absoluteString)
            return true
        }
        if Auth.auth().canHandle(url) {
            print("AppDelegate: Firebase handled URL:", url.absoluteString)
            return true
        }
        return false
    }
}
