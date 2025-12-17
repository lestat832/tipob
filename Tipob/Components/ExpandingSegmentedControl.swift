import SwiftUI

/// A segmented control where the selected item expands to show icon + label,
/// while unselected items show icon only. Creates a smooth "expanding pill" effect.
struct ExpandingSegmentedControl<T: Hashable & Identifiable>: View {
    @Binding var selection: T
    let items: [T]
    let emoji: (T) -> String
    let label: (T) -> String

    @Namespace private var animation

    var body: some View {
        HStack(spacing: 4) {
            ForEach(items) { item in
                let isSelected = selection.id == item.id

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selection = item
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(emoji(item))
                            .font(.system(size: 18))

                        if isSelected {
                            Text(label(item))
                                .font(.system(size: 14, weight: .semibold))
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                    .padding(.horizontal, isSelected ? 14 : 10)
                    .padding(.vertical, 10)
                    .frame(minWidth: 44, minHeight: 44)
                    .background {
                        if isSelected {
                            Capsule()
                                .fill(Color.accentColor)
                                .matchedGeometryEffect(id: "selection", in: animation)
                        }
                    }
                    .foregroundColor(isSelected ? .white : .primary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(label(item))
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color(.systemGray5))
        )
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selection: GameMode = .classic
        let modes: [GameMode] = [.classic, .memory, .gameVsPlayerVsPlayer, .playerVsPlayer]

        var body: some View {
            VStack(spacing: 40) {
                ExpandingSegmentedControl(
                    selection: $selection,
                    items: modes,
                    emoji: { $0.emoji },
                    label: { $0.shortName }
                )

                Text("Selected: \(selection.rawValue)")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
