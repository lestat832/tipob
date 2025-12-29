import SwiftUI

/// A tappable settings row for actions (not toggles)
/// Visually matches SettingToggleRow for UI consistency
struct SettingActionRow: View {
    let title: String
    var subtitle: String? = nil
    var systemIcon: String? = nil
    var iconName: String? = nil

    var body: some View {
        HStack(spacing: 14) {
            // Leading icon (SF Symbol or custom image)
            if let systemIcon = systemIcon {
                Image(systemName: systemIcon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
            } else if let iconName = iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }

            // Title and optional subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            // Trailing chevron indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple, .pink]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 12) {
            SettingActionRow(
                title: "Share Out of Pocket",
                iconName: "icon_share_default"
            )

            SettingActionRow(
                title: "Rate Us",
                subtitle: "Leave a review on the App Store",
                systemIcon: "star.fill"
            )
        }
        .padding(.horizontal, 20)
    }
}
