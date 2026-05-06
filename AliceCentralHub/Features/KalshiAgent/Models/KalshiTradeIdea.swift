import Foundation

struct KalshiTradeIdea: Identifiable, Hashable {
    enum ProposedAction: String, CaseIterable, Codable {
        case buyYes
        case buyNo
        case hold

        var displayName: String {
            switch self {
            case .buyYes:
                return "Buy YES"
            case .buyNo:
                return "Buy NO"
            case .hold:
                return "Hold"
            }
        }
    }

    enum Status: String, CaseIterable, Codable {
        case watchlist
        case needsReview
        case rejected
        case paperTradeCandidate

        var displayName: String {
            switch self {
            case .watchlist:
                return "Watchlist"
            case .needsReview:
                return "Needs Review"
            case .rejected:
                return "Rejected"
            case .paperTradeCandidate:
                return "Paper Trade Candidate"
            }
        }
    }

    let id: UUID
    let marketTicker: String
    let marketTitle: String
    let proposedAction: ProposedAction
    let targetPrice: Double
    let confidence: Double
    let thesis: String
    let status: Status
}
