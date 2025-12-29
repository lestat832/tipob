import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Local state synced with UserSettings
    @State private var showGestureNames: Bool = UserSettings.showGestureNames
    @State private var soundEnabled: Bool = UserSettings.soundEnabled
    @State private var hapticsEnabled: Bool = UserSettings.hapticsEnabled
    @State private var showingShareSheet = false

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

                    VStack(spacing: 12) {
                        // Show Gesture Names
                        SettingToggleRow(
                            isOn: $showGestureNames,
                            title: "Gesture Names",
                            subtitle: "Show helper text below icons",
                            iconName: "icon_chat_default"
                        )

                        // Sound Effects
                        SettingToggleRow(
                            isOn: $soundEnabled,
                            title: "Sound Effects",
                            subtitle: "Play sounds during gameplay",
                            iconName: "icon_sound_default"
                        )

                        // Haptics
                        SettingToggleRow(
                            isOn: $hapticsEnabled,
                            title: "Haptics",
                            subtitle: "Vibration feedback for gestures",
                            iconName: "gesture_shake_default"
                        )
                    }
                    .padding(.horizontal, 20)

                    // Share section (visual separation)
                    VStack(spacing: 12) {
                        Button {
                            HapticManager.shared.impact()
                            showingShareSheet = true
                        } label: {
                            SettingActionRow(
                                title: "Share Out of Pocket",
                                iconName: "icon_share_default"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

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
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [ShareContent.defaultMessage])
        }
    }
}

#Preview {
    SettingsView()
}
