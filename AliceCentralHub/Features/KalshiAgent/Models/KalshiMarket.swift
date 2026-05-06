import Foundation

struct KalshiMarket: Identifiable, Hashable {
    enum Status: String, CaseIterable, Codable {
        case open
        case paused
        case closed

        var displayName: String {
            rawValue.capitalized
        }
    }

    let id: UUID
    let ticker: String
    let title: String
    let category: String
    let yesPrice: Double
    let noPrice: Double
    let volume: Double
    let closeDate: Date
    let status: Status
}
