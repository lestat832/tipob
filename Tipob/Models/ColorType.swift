import Foundation
import SwiftUI

/// Represents the four colors used in Stroop Color-Swipe gesture
/// Each Stroop instance randomly assigns these colors to swipe directions
enum ColorType: String, Codable, Equatable, CaseIterable {
    case red
    case blue
    case green
    case yellow

    /// Returns the SwiftUI Color for this color type
    var uiColor: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        }
    }

    /// Returns the capitalized display name (e.g., "RED", "BLUE")
    var displayName: String {
        return rawValue.uppercased()
    }
}
