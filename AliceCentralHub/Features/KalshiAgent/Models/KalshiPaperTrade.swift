import Foundation

struct KalshiPaperTrade: Identifiable, Hashable {
    enum Side: String, CaseIterable, Codable {
        case yes
        case no
    }

    enum Status: String, CaseIterable, Codable {
        case open
        case closed
        case cancelled
    }

    let id: UUID
    let marketTicker: String
    let side: Side
    let contracts: Int
    let fillPrice: Double
    let createdAt: Date
    let status: Status
}
