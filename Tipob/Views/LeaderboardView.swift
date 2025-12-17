import SwiftUI

struct LeaderboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: GameMode = .classic

    // Only show modes that have leaderboards
    private let leaderboardModes: [GameMode] = [.classic, .memory, .gameVsPlayerVsPlayer, .playerVsPlayer]

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                Color.toyBoxMenuGradient.opacity(0.3)
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Mode Selector - Expanding pill control
                    ExpandingSegmentedControl(
                        selection: $selectedMode,
                        items: leaderboardModes,
                        emoji: { $0.emoji },
                        label: { $0.shortName }
                    )
                    .padding()

                    // Leaderboard Content
                    leaderboardContent
                        .animation(.easeInOut, value: selectedMode)
                }
            }
            .navigationTitle("🏆 High Scores")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var leaderboardContent: some View {
        let entries = LeaderboardManager.shared.topScores(for: selectedMode, limit: 10)

        if entries.isEmpty {
            emptyStateView
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    // Leaderboard entries
                    ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                        LeaderboardRow(rank: index + 1, entry: entry)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No scores yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Play a game to set your first record!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry

    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)

                Text("#\(rank)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            // Score
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Score:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(entry.score)")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                // Date
                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Trophy for top 3
            if rank <= 3 {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(trophyColor)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }

    private var trophyColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
}

#Preview {
    LeaderboardView()
}
