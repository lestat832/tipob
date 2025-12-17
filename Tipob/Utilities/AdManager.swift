//
//  AdManager.swift
//  Tipob
//
//  Created on 2025-11-11
//  Google AdMob Integration - PRODUCTION
//

import Foundation
import UIKit
import GoogleMobileAds

/// Manages interstitial ad loading and presentation
class AdManager: NSObject {

    // MARK: - Environment Detection

    /// Detects runtime environment: Debug, TestFlight, or App Store
    /// Used to determine which ad unit ID to use
    private enum AppEnvironment {
        case debug
        case testFlight
        case appStore

        static var current: AppEnvironment {
            #if DEBUG
            // Local development builds compiled with DEBUG flag
            return .debug
            #else
            // Check for TestFlight by examining receipt URL
            // TestFlight receipts contain "sandboxReceipt" in the path
            // App Store receipts have a different path structure
            if let receiptURL = Bundle.main.appStoreReceiptURL,
               receiptURL.lastPathComponent == "sandboxReceipt" {
                return .testFlight
            }
            // Default to App Store for production release builds
            return .appStore
            #endif
        }

        /// Returns true for environments that should use test ads
        var isTestEnvironment: Bool {
            switch self {
            case .debug, .testFlight:
                return true
            case .appStore:
                return false
            }
        }
    }

    // MARK: - Singleton

    static let shared = AdManager()

    // MARK: - Properties

    /// Google AdMob Interstitial Ad Unit ID
    /// Uses test ad for Debug and TestFlight, production ad for App Store only
    /// Test ad units are universal - they work with any App ID and always have fill
    private var interstitialAdUnitID: String {
        if AppEnvironment.current.isTestEnvironment {
            // Google's universal test interstitial ad unit
            // Guaranteed to always have ad fill for testing
            return "ca-app-pub-3940256099942544/4411468910"
        } else {
            // Production ad unit - only used in App Store releases
            return "ca-app-pub-8372563313053067/2149863647"
        }
    }

    /// Currently loaded interstitial ad
    private var interstitialAd: InterstitialAd?

    /// Timestamp of last ad shown
    private var lastAdShownTime: Date?

    /// Number of games completed since last ad
    private var gamesCompletedSinceLastAd: Int = 0

    /// Completion handler to call after ad dismissal
    private var adCompletionHandler: (() -> Void)?

    /// App launch time (to prevent ads in first 30 seconds)
    private let appLaunchTime: Date

    /// Flag to prevent duplicate load requests
    private var isLoading = false

    // MARK: - Configuration

    // REMOVED COOLDOWN RESTRICTIONS FOR TESTING
    // All timing and frequency restrictions disabled
    // Ad shows every time if loaded

    // MARK: - Initialization

    private override init() {
        self.appLaunchTime = Date()
        super.init()

        // Preload first ad
        loadInterstitialAd()

        // Log which environment was detected
        let env = AppEnvironment.current
        switch env {
        case .debug:
            print("✅ AdManager: DEBUG mode - using test ads")
        case .testFlight:
            print("✅ AdManager: TESTFLIGHT mode - using test ads")
        case .appStore:
            print("✅ AdManager: APP STORE mode - using production ads")
        }
    }

    // MARK: - Public Methods

    /// Check if an ad should be shown at end of game
    /// Returns true if ad is loaded (all cooldowns removed for testing)
    func shouldShowEndOfGameAd() -> Bool {
        // Only check: Ad is loaded and ready
        guard interstitialAd != nil else {
            print("⏭️ Skipping ad - not loaded yet")
            return false
        }

        print("✅ Ad loaded - ready to show")
        return true
    }

    /// Show interstitial ad from the given view controller
    /// - Parameters:
    ///   - viewController: The presenting view controller
    ///   - completion: Handler called after ad dismisses or if ad unavailable
    func showInterstitialAd(from viewController: UIViewController, completion: @escaping () -> Void) {
        // Store completion handler
        self.adCompletionHandler = completion

        guard let ad = interstitialAd else {
            print("❌ No interstitial ad loaded - continuing without ad")
            completion()
            return
        }

        print("📺 Presenting interstitial ad...")
        ad.present(from: viewController)
        // Note: Next ad is preloaded when new game starts via preloadIfNeeded()
    }

    /// Increment the completed games counter (no-op - cooldowns removed)
    func incrementGameCount() {
        // No-op: Game counting disabled for testing
    }

    /// Preload an ad if one isn't already loaded or loading
    /// Call this when a new game starts to ensure ad is ready for game over
    func preloadIfNeeded() {
        if interstitialAd == nil && !isLoading {
            print("🔄 Preloading ad for next game over...")
            loadInterstitialAd()
        }
    }

    // MARK: - Private Methods

    /// Load a new interstitial ad
    private func loadInterstitialAd() {
        guard !isLoading else {
            print("⏳ Ad load already in progress, skipping duplicate request")
            return
        }

        isLoading = true
        let request = Request()

        InterstitialAd.load(
            with: interstitialAdUnitID,
            request: request
        ) { [weak self] ad, error in
            guard let self = self else { return }

            self.isLoading = false

            if let error = error {
                print("❌ Interstitial ad failed to load: \(error.localizedDescription)")
                self.interstitialAd = nil

                // Retry loading after 30 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
                    self.loadInterstitialAd()
                }
                return
            }

            self.interstitialAd = ad

            // Assign delegate on main thread (required for @MainActor conformance)
            DispatchQueue.main.async {
                self.interstitialAd?.fullScreenContentDelegate = self
            }

            print("✅ Interstitial ad loaded successfully")
        }
    }
}

// MARK: - FullScreenContentDelegate

@MainActor
extension AdManager: FullScreenContentDelegate {

    /// Ad failed to present
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Ad failed to present: \(error.localizedDescription)")

        // Call completion handler to continue game flow
        adCompletionHandler?()
        adCompletionHandler = nil

        // Reload ad
        loadInterstitialAd()
    }

    /// Ad dismissed by user
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Ad dismissed - resuming game flow")

        // Call completion handler to continue game flow
        adCompletionHandler?()
        adCompletionHandler = nil

        // Interstitial is a one-time use object, clear reference
        interstitialAd = nil
    }
}
