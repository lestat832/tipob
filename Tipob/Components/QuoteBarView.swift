import SwiftUI

// MARK: - QuoteBarView

/// Displays daily quote pinned at bottom of home screen
struct QuoteBarView: View {
    @ObservedObject private var quoteManager = QuoteManager.shared

    var body: some View {
        if let quote = quoteManager.todayQuote {
            // Inline format: "[quote]" — [author] (minimizes vertical space)
            Text("\"\(quote.text)\" — \(quote.author)")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                .allowsHitTesting(false)
        }
        // If no quote available, render nothing (graceful degradation)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()

        VStack {
            Spacer()
            QuoteBarView()
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
    }
}
