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

    // MARK: - Singleton

    static let shared = AdManager()

    // MARK: - Properties

    /// Google AdMob Interstitial Ad Unit ID (Production)
    private let interstitialAdUnitID = "ca-app-pub-8372563313053067/2149863647"

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

        print("✅ AdManager initialized with production ID")
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

        // Preload next ad
        loadInterstitialAd()
    }

    /// Increment the completed games counter (no-op - cooldowns removed)
    func incrementGameCount() {
        // No-op: Game counting disabled for testing
    }

    // MARK: - Private Methods

    /// Load a new interstitial ad
    private func loadInterstitialAd() {
        let request = Request()

        InterstitialAd.load(
            with: interstitialAdUnitID,
            request: request
        ) { [weak self] ad, error in
            guard let self = self else { return }

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
