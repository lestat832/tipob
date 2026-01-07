import Foundation
import StoreKit
import UIKit

// MARK: - AppStoreReviewManager

/// Handles App Store review requests with StoreKit + fallback logic
final class AppStoreReviewManager {
    static let shared = AppStoreReviewManager()
    private init() {}

    /// Method used to request review
    enum ReviewMethod: String {
        case storeKit = "storekit"
        case appStore = "app_store"
        case unavailable = "unavailable"
    }

    /// Request a review using StoreKit in-app prompt, with App Store fallback
    /// - Returns: The method used to request the review
    @discardableResult
    func requestReview() -> ReviewMethod {
        // Try StoreKit in-app review first
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            return .storeKit
        }

        // Fallback: Open App Store review page if appStoreID is configured
        if let reviewURL = AppConfig.appStoreReviewURL {
            UIApplication.shared.open(reviewURL)
            return .appStore
        }

        // No method available (dev build without appStoreID)
        return .unavailable
    }
}
