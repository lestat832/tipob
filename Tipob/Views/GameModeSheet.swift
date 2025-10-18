import SwiftUI

struct GameModeSheet: View {
    @Binding var selectedMode: GameMode
    @Environment(\.dismiss) var dismiss
    @State private var selectedCard: GameMode?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple, .pink]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 25) {
                Text("Select Game Mode")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 30)

                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(GameMode.allCases) { mode in
                            GameModeCard(
                                mode: mode,
                                isSelected: selectedMode == mode
                            ) {
                                selectMode(mode)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
    }

    private func selectMode(_ mode: GameMode) {
        HapticManager.shared.impact()
        selectedMode = mode

        // Dismiss after short delay for visual feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
        }
    }
}

struct GameModeCard: View {
    let mode: GameMode
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Text(mode.emoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 5) {
                    Text(mode.rawValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(mode.description)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 24))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}
