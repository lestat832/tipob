import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Local state synced with UserSettings
    @State private var showGestureNames: Bool = UserSettings.showGestureNames
    @State private var soundEnabled: Bool = UserSettings.soundEnabled
    @State private var hapticsEnabled: Bool = UserSettings.hapticsEnabled

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient (matches GameModeSheet)
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple, .pink]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 25) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 30)

                    VStack(spacing: 15) {
                        // Show Gesture Names (disabled - Coming soon)
                        SettingsRow(
                            title: "Show Gesture Names",
                            description: "Coming soon",
                            isOn: $showGestureNames,
                            isDisabled: true
                        )

                        // Sound Effects
                        SettingsRow(
                            title: "Sound Effects",
                            description: "Play sounds during gameplay",
                            isOn: $soundEnabled,
                            isDisabled: false
                        )

                        // Haptics
                        SettingsRow(
                            title: "Haptics",
                            description: "Vibration feedback for gestures",
                            isOn: $hapticsEnabled,
                            isDisabled: false
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                }
            }
        }
        .onChange(of: showGestureNames) { _, newValue in
            UserSettings.showGestureNames = newValue
        }
        .onChange(of: soundEnabled) { _, newValue in
            UserSettings.soundEnabled = newValue
            HapticManager.shared.impact()
        }
        .onChange(of: hapticsEnabled) { _, newValue in
            UserSettings.hapticsEnabled = newValue
            // Play haptic feedback if enabling haptics
            if newValue {
                HapticManager.shared.impact()
            }
        }
    }
}

struct SettingsRow: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    let isDisabled: Bool

    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(isDisabled ? .primary.opacity(0.5) : .primary)

                Text(description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(isDisabled ? .secondary.opacity(0.5) : .secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
                .disabled(isDisabled)
                .opacity(isDisabled ? 0.5 : 1.0)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    SettingsView()
}
