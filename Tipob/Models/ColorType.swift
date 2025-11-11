import Foundation
import SwiftUI

/// Represents the four colors used in Stroop Color-Swipe gesture
/// Each Stroop instance randomly assigns these colors to swipe directions
enum ColorType: String, Codable, Equatable, CaseIterable {
    case red
    case blue
    case green
    case yellow

    /// Returns the SwiftUI Color for this color type (Toy Box Classic palette)
    var uiColor: Color {
        switch self {
        case .red: return .toyBoxLeft      // Toy Red
        case .blue: return .toyBoxUp       // Toy Blue
        case .green: return .toyBoxDown    // Toy Green
        case .yellow: return .toyBoxTap    // Toy Yellow
        }
    }

    /// Returns the capitalized display name (e.g., "RED", "BLUE")
    var displayName: String {
        return rawValue.uppercased()
    }
}
