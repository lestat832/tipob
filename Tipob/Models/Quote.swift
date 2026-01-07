import Foundation

// MARK: - Quote Model

/// Individual quote with text and author
struct Quote: Codable, Identifiable {
    let id: String
    let text: String
    let author: String
    let enabled: Bool
    let verified: Bool
    let source: String?
}

// MARK: - Quote File Container

/// Container for quotes JSON file
struct QuoteFile: Codable {
    let version: Int
    let name: String
    let quotes: [Quote]
}
