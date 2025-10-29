import SwiftUI

@main
struct TipobApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .defaultSize(width: 393, height: 852)  // iPhone 14 Pro dimensions
    }
}

// Lock orientation to portrait
extension UIDevice {
    static var isPortrait: Bool {
        UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == .unknown
    }
}

// AppDelegate for orientation locking
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait  // Lock to portrait only
    }
}