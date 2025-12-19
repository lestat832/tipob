//
//  GestureVisualProvider.swift
//  Tipob
//
//  Created on 2025-12-19
//  Centralized provider for V1/V2 gesture visual switching
//

import SwiftUI

/// Provides gesture visual assets with V1/V2 switching capability
/// - Release: Always uses V2 images
/// - Debug/TestFlight: V2 by default, can toggle to V1 via DevPanel
struct GestureVisualProvider {

    /// Returns true if V2 images should be used
    /// - Release: Always true (V2 only)
    /// - Debug/TestFlight: true unless V1 fallback is enabled
    static var useV2Images: Bool {
        #if DEBUG || TESTFLIGHT
        return !DevConfigManager.shared.useV1GestureFallback
        #else
        return true  // Release ALWAYS uses V2
        #endif
    }

    /// Maps GestureType to V2 asset name in Assets2.xcassets
    /// Returns nil for gestures that use custom views (e.g., Stroop)
    static func v2AssetName(for gesture: GestureType) -> String? {
        switch gesture {
        case .tap:        return "gesture_tap_default"
        case .doubleTap:  return "gesture_double_tap_default"
        case .longPress:  return "gesture_long_press_default"
        case .pinch:      return "gesture_pinch_default"
        case .up:         return "gesture_swipe_up_default"
        case .down:       return "gesture_swipe_down_default"
        case .left:       return "gesture_swipe_left_default"
        case .right:      return "gesture_swipe_right_default"
        case .shake:      return "gesture_shake_default"
        case .tiltLeft:   return "gesture_tilt_left_default"
        case .tiltRight:  return "gesture_tilt_right_default"
        case .raise:      return "gesture_raise_phone_default"
        case .lower:      return "gesture_lower_phone_default"
        case .stroop:     return nil  // Uses StroopPromptView
        }
    }
}
