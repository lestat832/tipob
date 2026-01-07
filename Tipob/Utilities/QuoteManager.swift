import Foundation
import Combine

// MARK: - QuoteManager

/// Manages loading quotes from bundle and selecting daily quote
class QuoteManager: ObservableObject {
    static let shared = QuoteManager()

    @Published private(set) var todayQuote: Quote?

    private var enabledQuotes: [Quote] = []

    private init() {
        loadQuotes()
        selectTodayQuote()
    }

    // MARK: - Load Quotes from Bundle

    private func loadQuotes() {
        guard let url = Bundle.main.url(forResource: "quotes.demo.v1", withExtension: "json") else {
            print("QuoteManager: quotes.demo.v1.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let quoteFile = try JSONDecoder().decode(QuoteFile.self, from: data)
            enabledQuotes = quoteFile.quotes.filter { $0.enabled }
            print("QuoteManager: Loaded \(enabledQuotes.count) enabled quotes")
        } catch {
            print("QuoteManager: Failed to decode quotes - \(error.localizedDescription)")
            enabledQuotes = []
        }
    }

    // MARK: - Daily Quote Selection

    /// Selects today's quote deterministically based on local calendar day
    private func selectTodayQuote() {
        guard !enabledQuotes.isEmpty else {
            todayQuote = nil
            return
        }

        // Get start of today (local timezone)
        let dayKey = Calendar.current.startOfDay(for: Date())

        // Calculate days since Unix epoch
        let daysSinceEpoch = Int(dayKey.timeIntervalSince1970 / 86400)

        // Deterministic selection: same quote for entire day
        let index = daysSinceEpoch % enabledQuotes.count
        todayQuote = enabledQuotes[index]
    }

    // MARK: - Manual Refresh (for testing)

    /// Force refresh quote selection (useful for testing or date change)
    func refreshTodayQuote() {
        selectTodayQuote()
    }
}
