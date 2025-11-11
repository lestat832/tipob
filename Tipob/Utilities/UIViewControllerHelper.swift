//
//  UIViewControllerHelper.swift
//  Tipob
//
//  Created on 2025-11-11
//  Bridge between SwiftUI and UIKit for presenting ads
//

import UIKit
import SwiftUI

/// Helper to get the top-most view controller for presenting ads from SwiftUI
struct ViewControllerHolder {
    weak var value: UIViewController?
}

/// Extension to find the top-most view controller in the hierarchy
extension UIViewController {
    /// Recursively find the top-most presented view controller
    func topMostViewController() -> UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController()
        }

        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }

        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }

        return self
    }
}

/// Extension to get the top view controller from anywhere in the app
extension UIApplication {
    /// Get the top-most view controller in the app
    /// Returns nil if no view controller is available
    static func topViewController() -> UIViewController? {
        // Get the active window scene
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            print("⚠️ No active window scene found")
            return nil
        }

        // Get the key window
        guard let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            print("⚠️ No key window found")
            return nil
        }

        // Get root view controller
        guard let rootViewController = keyWindow.rootViewController else {
            print("⚠️ No root view controller found")
            return nil
        }

        // Return the top-most view controller
        return rootViewController.topMostViewController()
    }
}

/// SwiftUI View Modifier to capture hosting view controller
struct ViewControllerReader: UIViewControllerRepresentable {
    let content: (UIViewController) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            self.content(controller)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

/// Extension to make it easier to get view controller from SwiftUI
extension View {
    /// Capture the hosting view controller
    func onViewControllerAvailable(_ handler: @escaping (UIViewController) -> Void) -> some View {
        self.background(
            ViewControllerReader(content: handler)
                .frame(width: 0, height: 0)
        )
    }
}
