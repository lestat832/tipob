//
//  AdManager.swift
//  Tipob
//
//  Created on 2025-11-11
//  Google AdMob Integration - TEST MODE ONLY
//

import Foundation
import UIKit
import GoogleMobileAds

/// Manages interstitial ad loading and presentation
/// IMPORTANT: Uses TEST Ad Unit IDs only - never uses production IDs
class AdManager: NSObject {

    // MARK: - Singleton

    static let shared = AdManager()

    // MARK: - Properties

    /// Google AdMob TEST Interstitial Ad Unit ID
    /// WARNING: This is a TEST ID - do NOT use in production
    private let testAdUnitID = "ca-app-pub-3940256099942544/4411468910"

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

    /// Minimum seconds between ads (cooldown)
    private let minimumTimeBetweenAds: TimeInterval = 30.0

    /// Show ad every N completed games
    private let gamesPerAd: Int = 2

    /// Minimum seconds after app launch before showing first ad
    private let minimumTimeSinceLaunch: TimeInterval = 30.0

    // MARK: - Initialization

    private override init() {
        self.appLaunchTime = Date()
        super.init()

        // Preload first ad
        loadInterstitialAd()

        print("✅ AdManager initialized with TEST ID: \(testAdUnitID)")
    }

    // MARK: - Public Methods

    /// Check if an ad should be shown at end of game
    /// Returns true if cooldown conditions are satisfied
    func shouldShowEndOfGameAd() -> Bool {
        // Check 1: Minimum time since app launch
        let timeSinceLaunch = Date().timeIntervalSince(appLaunchTime)
        guard timeSinceLaunch >= minimumTimeSinceLaunch else {
            print("⏭️ Skipping ad - app launched \(Int(timeSinceLaunch))s ago (need \(Int(minimumTimeSinceLaunch))s)")
            return false
        }

        // Check 2: Minimum time since last ad
        if let lastAdTime = lastAdShownTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastAdTime)
            if timeSinceLastAd < minimumTimeBetweenAds {
                let remainingTime = Int(minimumTimeBetweenAds - timeSinceLastAd)
                print("⏭️ Skipping ad - cooldown active (\(remainingTime)s remaining)")
                return false
            }
        }

        // Check 3: Games completed frequency
        guard gamesCompletedSinceLastAd >= gamesPerAd else {
            print("⏭️ Skipping ad - games completed: \(gamesCompletedSinceLastAd)/\(gamesPerAd)")
            return false
        }

        // Check 4: Ad is loaded and ready
        guard interstitialAd != nil else {
            print("⏭️ Skipping ad - not loaded yet")
            return false
        }

        print("✅ Ad conditions satisfied - ready to show")
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

        // Reset counters
        lastAdShownTime = Date()
        gamesCompletedSinceLastAd = 0

        // Preload next ad
        loadInterstitialAd()
    }

    /// Increment the completed games counter
    /// Call this at the end of each game session
    func incrementGameCount() {
        gamesCompletedSinceLastAd += 1
        print("🎮 Games completed: \(gamesCompletedSinceLastAd)/\(gamesPerAd)")
    }

    // MARK: - Private Methods

    /// Load a new interstitial ad
    private func loadInterstitialAd() {
        let request = Request()

        InterstitialAd.load(
            with: testAdUnitID,
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
