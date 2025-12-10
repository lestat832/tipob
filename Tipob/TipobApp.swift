import SwiftUI
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import FirebaseCore
import FirebaseCrashlytics

@main
struct TipobApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        // Initialize Firebase
        FirebaseApp.configure()

        // Initialize Google Mobile Ads SDK
        MobileAds.shared.start()
        print("🎯 AdMob initialized - ready for interstitial ads")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    requestTrackingPermission()
                }
        }
        .defaultSize(width: 393, height: 852)  // iPhone 14 Pro dimensions
    }

    private func requestTrackingPermission() {
        // Only request if not already determined
        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    print("📊 ATT Status: \(status.rawValue)")
                }
            }
        }
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