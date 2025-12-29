import SwiftUI

/// Native iOS share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

/// Share content constants
enum ShareContent {
    static let appStoreURL = "https://apps.apple.com/app/out-of-pocket/id[PLACEHOLDER]"
    static let defaultMessage = """
        I've been playing Out of Pocket 😈
        You should try it and see if you can beat me.
        \(appStoreURL)
        """
}
