import SwiftUI

/// Slide-up gesture drawer showing all available gestures grouped by category
/// Supports discreet mode filtering and spring-animated dismiss
struct GestureDrawerView: View {
    @Binding var isExpanded: Bool
    let discreetMode: Bool
    let includeStroop: Bool

    @State private var dragOffset: CGFloat = 0

    private let drawerHeight: CGFloat = UIScreen.main.bounds.height * 0.5
    private let dismissThreshold: CGFloat = 80

    // Playful microcopy options
    private let headerTitles = [
        "Pick Your Poison 💀",
        "Your Move 🎯",
        "Choose Wisely 🎲",
        "Gesture Menu ✨"
    ]

    @State private var selectedTitle: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Dimmed background
                if isExpanded {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismissDrawer()
                        }
                        .transition(.opacity)
                }

                // Drawer content
                if isExpanded {
                    VStack(spacing: 0) {
                        // Drag handle
                        dragHandle

                        // Header with playful title
                        Text(selectedTitle)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 4)
                            .padding(.bottom, 12)

                        // Scrollable content
                        ScrollView {
                            VStack(alignment: .leading, spacing: 24) {
                                let categories = GestureCategory.filteredGestures(
                                    forDiscreetMode: discreetMode,
                                    includeStroop: includeStroop
                                )

                                ForEach(categories, id: \.category) { item in
                                    GestureCategorySection(
                                        category: item.category,
                                        gestures: item.gestures
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                    .frame(height: drawerHeight)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThickMaterial)
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -5)
                    )
                    .offset(y: max(0, dragOffset))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Only allow dragging down
                                if value.translation.height > 0 {
                                    dragOffset = value.translation.height
                                }
                            }
                            .onEnded { value in
                                if value.translation.height > dismissThreshold {
                                    dismissDrawer()
                                } else {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        dragOffset = 0
                                    }
                                }
                            }
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .allowsHitTesting(isExpanded)  // Only intercept touches when drawer is open
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isExpanded)
        .onAppear {
            selectedTitle = headerTitles.randomElement() ?? "Gestures"
        }
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 40, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    private func dismissDrawer() {
        HapticManager.shared.impact()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            isExpanded = false
            dragOffset = 0
        }
    }
}

// MARK: - Category Section

private struct GestureCategorySection: View {
    let category: GestureCategory
    let gestures: [GestureType]

    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 85), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Section header
            HStack(spacing: 8) {
                Text(category.emoji)
                    .font(.system(size: 16))
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Gesture grid
            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(gestures, id: \.symbol) { gesture in
                    GestureCellView(gesture: gesture, size: 64)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.toyBoxClassicGradient.ignoresSafeArea()
        GestureDrawerView(
            isExpanded: .constant(true),
            discreetMode: false,
            includeStroop: false
        )
    }
}
