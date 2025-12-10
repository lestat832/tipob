import Foundation
import FirebaseCrashlytics

/// Utility for logging non-fatal errors to Crashlytics
enum ErrorLogger {
    /// Log a custom message to Crashlytics
    static func logNonFatal(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }

    /// Record an error to Crashlytics
    static func record(_ error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
}
