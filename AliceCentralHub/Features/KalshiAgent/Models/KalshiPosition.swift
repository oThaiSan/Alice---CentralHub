import Foundation

struct KalshiPosition: Identifiable, Hashable {
    enum Side: String, CaseIterable, Codable {
        case yes
        case no

        var displayName: String {
            rawValue.uppercased()
        }
    }

    enum Status: String, CaseIterable, Codable {
        case open
        case reducing
        case closed

        var displayName: String {
            rawValue.capitalized
        }
    }

    let id: UUID
    let marketTicker: String
    let side: Side
    let contracts: Int
    let entryPrice: Double
    let currentPrice: Double
    let unrealizedPnL: Double
    let status: Status
}
