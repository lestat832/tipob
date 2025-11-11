//
//  Color+ToyBox.swift
//  Tipob
//
//  Created on 2025-11-10
//  Toy Box Classic Color Palette
//

import SwiftUI

extension Color {
    // MARK: - Hex Color Initializer

    /// Initialize a Color from a hex string (with or without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Toy Box Classic Gesture Colors (13 Gestures)

    /// Swipe Up ↑ - Toy Blue
    static let toyBoxUp = Color(hex: "0066FF")

    /// Swipe Down ↓ - Toy Green
    static let toyBoxDown = Color(hex: "00CC00")

    /// Swipe Left ← - Toy Red
    static let toyBoxLeft = Color(hex: "FF0000")

    /// Swipe Right → - Safety Orange
    static let toyBoxRight = Color(hex: "FF6600")

    /// Tap ⊙ - Toy Yellow
    static let toyBoxTap = Color(hex: "FFCC00")

    /// Double Tap ◎ - Purple Pop
    static let toyBoxDoubleTap = Color(hex: "9900FF")

    /// Long Press ⏺ - Bubble Pink
    static let toyBoxLongPress = Color(hex: "FF0099")

    /// Pinch 🤏 - Sky Blue
    static let toyBoxPinch = Color(hex: "0099FF")

    /// Shake 📳 - Mint Fresh
    static let toyBoxShake = Color(hex: "00FFCC")

    /// Tilt Left ◀ - Coral Red
    static let toyBoxTiltLeft = Color(hex: "FF3366")

    /// Tilt Right ▶ - Lime Blast
    static let toyBoxTiltRight = Color(hex: "66FF00")

    /// Raise ⬆️ - Electric Cyan
    static let toyBoxRaise = Color(hex: "00CCFF")

    /// Lower ⬇️ - Tangerine
    static let toyBoxLower = Color(hex: "FF9900")

    // MARK: - Toy Box Classic Background Gradient Colors

    /// Menu Gradient: Toy Blue → Toy Red → Toy Yellow
    static let toyBoxMenuGradient = LinearGradient(
        colors: [
            Color(hex: "0066FF"),
            Color(hex: "FF0000"),
            Color(hex: "FFCC00")
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Launch Screen Gradient: Purple Pop → Toy Blue → Mint Fresh
    static let toyBoxLaunchGradient = LinearGradient(
        colors: [
            Color(hex: "9900FF"),
            Color(hex: "0066FF"),
            Color(hex: "00FFCC")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Classic Mode Gradient: Toy Red → Toy Blue
    static let toyBoxClassicGradient = LinearGradient(
        colors: [
            Color(hex: "FF0000"),
            Color(hex: "0066FF")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Memory Mode Background: Bright Yellow
    static let toyBoxMemoryBackground = Color(hex: "FFCC00")

    /// Game Over Gradient: Safety Orange → Toy Red
    static let toyBoxGameOverGradient = LinearGradient(
        colors: [
            Color(hex: "FF6600"),
            Color(hex: "FF0000")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Toy Box Classic UI Element Colors

    /// Success Flash - Toy Green with 50% opacity
    static let toyBoxSuccess = Color(hex: "00CC00")

    /// Error Flash - Toy Red with 50% opacity
    static let toyBoxError = Color(hex: "FF0000")

    /// Button Background - Toy Blue
    static let toyBoxButtonBg = Color(hex: "0066FF")

    /// Button Text - White
    static let toyBoxButtonText = Color.white

    /// Countdown Ring Gradient: Toy Blue → Purple Pop
    static let toyBoxCountdownGradient = LinearGradient(
        colors: [
            Color(hex: "0066FF"),
            Color(hex: "9900FF")
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}
