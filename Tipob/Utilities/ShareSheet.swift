import SwiftUI
import UIKit

/// Native iOS share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// Share content constants and generators
enum ShareContent {
    static let appStoreURL = "https://apps.apple.com/app/out-of-pocket/id6756274838"

    // MARK: - General App Share

    /// Default share message for Settings screen
    static let defaultMessage = """
        I've been playing Out of Pocket 😈
        You should try it and see if you can beat me.
        \(appStoreURL)
        """

    // MARK: - Score Text Generators

    /// Classic Mode share text
    static func classicModeText(score: Int) -> String {
        "I scored \(score) points in Out of Pocket! 🎮\n\nTry to beat my score:\n\(appStoreURL)"
    }

    /// Memory Mode share text
    static func memoryModeText(round: Int) -> String {
        "I reached Round \(round) in Out of Pocket Memory Mode! 🧠\n\nCan you beat me?\n\(appStoreURL)"
    }

    /// PvP Mode share text (winner + round)
    static func pvpModeText(winner: String, round: Int) -> String {
        "\(winner) won at Round \(round) in Out of Pocket! 👥\n\nChallenge your friends:\n\(appStoreURL)"
    }

    // MARK: - Branding

    /// App icon for branding in share sheet (loads from bundle Info.plist)
    static var appIcon: UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else {
            return nil
        }
        return UIImage(named: lastIcon)
    }
}
