import SwiftUI

/// Reusable toggle row component with frosted glass styling
/// Supports optional emoji, subtitle, and disabled state
struct SettingToggleRow: View {
    @Binding var isOn: Bool
    let title: String
    var subtitle: String? = nil
    var emoji: String? = nil
    var iconName: String? = nil
    var isDisabled: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            // Leading icon (decorative, hidden from VoiceOver)
            if let iconName = iconName {
                Image(iconName)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 56, height: 56)
                    .accessibilityHidden(true)
            } else if let emoji = emoji {
                Text(emoji)
                    .font(.system(size: 24))
                    .accessibilityHidden(true)
            }

            // Title and subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(isDisabled ? .white.opacity(0.4) : .white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(isDisabled ? .white.opacity(0.3) : .white.opacity(0.6))
                }
            }

            Spacer()

            // Custom frosted toggle
            FrostedToggle(isOn: $isOn, isDisabled: isDisabled)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .opacity(isDisabled ? 0.5 : 1.0)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title)\(subtitle.map { ", \($0)" } ?? "")")
        .accessibilityValue(isOn ? "On" : "Off")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isDisabled ? "Disabled" : "Double tap to toggle")
    }
}

/// Custom toggle with frosted glass track and neon accent
struct FrostedToggle: View {
    @Binding var isOn: Bool
    var isDisabled: Bool = false

    private let trackWidth: CGFloat = 51
    private let trackHeight: CGFloat = 31
    private let thumbSize: CGFloat = 27
    private let thumbPadding: CGFloat = 2

    // Neon accent color when ON
    private var accentColor: Color {
        Color(red: 0.4, green: 0.8, blue: 1.0) // Cyan neon
    }

    var body: some View {
        ZStack {
            // Track background
            Capsule()
                .fill(isOn ? accentColor.opacity(0.3) : Color.white.opacity(0.15))
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isOn ? accentColor.opacity(0.6) : Color.white.opacity(0.2),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isOn ? accentColor.opacity(0.4) : .clear,
                    radius: 8,
                    x: 0,
                    y: 0
                )

            // Thumb
            Circle()
                .fill(isOn ? .white : Color.white.opacity(0.85))
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                .frame(width: thumbSize, height: thumbSize)
                .offset(x: isOn ? (trackWidth - thumbSize) / 2 - thumbPadding : -(trackWidth - thumbSize) / 2 + thumbPadding)
        }
        .frame(width: trackWidth, height: trackHeight)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        .opacity(isDisabled ? 0.5 : 1.0)
        .onTapGesture {
            guard !isDisabled else { return }
            isOn.toggle()
        }
    }
}

// MARK: - Convenience Initializers

extension SettingToggleRow {
    /// Creates a toggle row with dynamic emoji based on state
    /// Used for Discreet Mode where emoji changes based on ON/OFF
    static func withDynamicEmoji(
        isOn: Binding<Bool>,
        title: String,
        subtitle: String? = nil,
        emojiOn: String,
        emojiOff: String,
        isDisabled: Bool = false
    ) -> SettingToggleRow {
        SettingToggleRow(
            isOn: isOn,
            title: title,
            subtitle: subtitle,
            emoji: isOn.wrappedValue ? emojiOn : emojiOff,
            isDisabled: isDisabled
        )
    }
}

// MARK: - Compact Discreet Mode Toggle

/// Compact toggle pill for Discreet Mode in menu bar
/// Features dynamic emoji (🤫 when ON, 🤪 when OFF) and info button
struct DiscreetModeCompactToggle: View {
    @Binding var isOn: Bool
    var onInfoTapped: () -> Void

    // Neon accent color when ON
    private var accentColor: Color {
        Color(red: 0.4, green: 0.8, blue: 1.0) // Cyan neon
    }

    var body: some View {
        HStack(spacing: 8) {
            // Dynamic emoji based on state
            Text(isOn ? "🤫" : "🤪")
                .font(.system(size: 18))
                .accessibilityHidden(true)
                .animation(.easeInOut(duration: 0.2), value: isOn)

            // Custom compact frosted toggle
            CompactFrostedToggle(isOn: $isOn)

            // Info button
            Button(action: onInfoTapped) {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.8))
            }
            .accessibilityLabel("Discreet Mode Info")
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isOn ? accentColor.opacity(0.4) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: isOn ? accentColor.opacity(0.3) : .clear,
            radius: 6,
            x: 0,
            y: 0
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Discreet Mode")
        .accessibilityValue(isOn ? "On, touch gestures only" : "Off, all gestures enabled")
        .accessibilityHint("Double tap to toggle")
    }
}

/// Smaller toggle variant for compact pill layouts
struct CompactFrostedToggle: View {
    @Binding var isOn: Bool

    private let trackWidth: CGFloat = 44
    private let trackHeight: CGFloat = 26
    private let thumbSize: CGFloat = 22
    private let thumbPadding: CGFloat = 2

    // Neon accent color when ON
    private var accentColor: Color {
        Color(red: 0.4, green: 0.8, blue: 1.0) // Cyan neon
    }

    var body: some View {
        ZStack {
            // Track background
            Capsule()
                .fill(isOn ? accentColor.opacity(0.4) : Color.white.opacity(0.15))
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isOn ? accentColor.opacity(0.6) : Color.white.opacity(0.2),
                            lineWidth: 1
                        )
                )

            // Thumb
            Circle()
                .fill(isOn ? .white : Color.white.opacity(0.85))
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                .frame(width: thumbSize, height: thumbSize)
                .offset(x: isOn ? (trackWidth - thumbSize) / 2 - thumbPadding : -(trackWidth - thumbSize) / 2 + thumbPadding)
        }
        .frame(width: trackWidth, height: trackHeight)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        .onTapGesture {
            isOn.toggle()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .purple, .pink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 16) {
            // Normal toggle
            SettingToggleRow(
                isOn: .constant(true),
                title: "Sound Effects",
                subtitle: "Play sounds during gameplay"
            )

            // Toggle with emoji
            SettingToggleRow(
                isOn: .constant(false),
                title: "Haptics",
                subtitle: "Vibration feedback",
                emoji: "📳"
            )

            // Disabled toggle
            SettingToggleRow(
                isOn: .constant(true),
                title: "Coming Soon",
                subtitle: "This feature is not available yet",
                isDisabled: true
            )

            // Discreet mode example (ON)
            SettingToggleRow(
                isOn: .constant(true),
                title: "Discreet Mode",
                subtitle: "Touch gestures only",
                emoji: "🤫"
            )

            // Discreet mode example (OFF)
            SettingToggleRow(
                isOn: .constant(false),
                title: "Discreet Mode",
                subtitle: "All gestures enabled",
                emoji: "🤪"
            )

            Divider()
                .background(Color.white.opacity(0.3))
                .padding(.vertical, 8)

            // Compact toggle examples
            HStack(spacing: 12) {
                DiscreetModeCompactToggle(
                    isOn: .constant(true),
                    onInfoTapped: {}
                )

                DiscreetModeCompactToggle(
                    isOn: .constant(false),
                    onInfoTapped: {}
                )
            }
        }
        .padding()
    }
}
