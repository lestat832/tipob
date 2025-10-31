import Foundation

/// Date extension for consistent timestamp logging across gesture detection
extension Date {
    /// Returns formatted timestamp for logging: HH:mm:ss.SSS
    var logTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
